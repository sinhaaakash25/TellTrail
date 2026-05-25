import AVFoundation
import Combine
import CoreLocation
import Foundation
import SwiftUI

final class JourneyViewModel: NSObject, ObservableObject {
    @Published private(set) var stops: [JourneyStop] = []
    @Published private(set) var voiceDrops: [VoiceDrop] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var playingDropID: UUID?
    @Published private(set) var playbackProgress = 0.0
    @Published var locationQuery = ""
    @Published private(set) var currentLocationName = "Current Location"
    @Published private(set) var isResolvingCurrentLocation = false
    @Published var selectedStopID: UUID?

    private let dataSource: JourneyDataProviding
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    private var authorizationContinuation: CheckedContinuation<Void, Never>?
    private var storeCancellable: AnyCancellable?
    private var playbackTimer: Timer?
    private var hasLoadedJourney = false

    var visibleStops: [JourneyStop] {
        let query = locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return stops }

        let matchedStops = stops.filter { stop in
            stop.place.localizedCaseInsensitiveContains(query)
                || voiceDrops.contains { drop in
                    isDrop(drop, near: stop) && drop.locationName.localizedCaseInsensitiveContains(query)
                }
        }

        return matchedStops
    }

    var selectedStop: JourneyStop? {
        let availableStops = visibleStops
        guard let selectedStopID else { return availableStops.first }
        return availableStops.first { $0.id == selectedStopID } ?? availableStops.first
    }

    var selectedStopDrops: [VoiceDrop] {
        guard let selectedStop else { return [] }
        return voiceDrops.filter { isDrop($0, near: selectedStop) }
    }

    var nearbySummary: String {
        let count = voiceDrops.count
        let noteText = count == 1 ? "voice note" : "voice notes"
        return "\(count) \(noteText) across \(stops.count) stops"
    }

    init(dataSource: JourneyDataProviding = PreviewJourneyDataSource()) {
        self.dataSource = dataSource
        super.init()
        speechSynthesizer.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if let store = dataSource as? TrailDataStore {
            storeCancellable = store.$drops.combineLatest(store.$stops).sink { [weak self] drops, stops in
                self?.voiceDrops = drops
                self?.stops = stops
            }
        }
    }

    convenience init(stops: [JourneyStop]) {
        self.init(dataSource: StaticJourneyDataSource(stops: stops, voiceDrops: PreviewTrailData.drops))
    }

    deinit {
        playbackTimer?.invalidate()
        speechSynthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        locationContinuation?.resume(returning: nil)
        authorizationContinuation?.resume()
    }

    func loadIfNeeded() async {
        guard !hasLoadedJourney else { return }
        hasLoadedJourney = true
        await reload()
    }

    func reload() async {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await dataSource.fetchJourney()
            stops = snapshot.stops
            voiceDrops = snapshot.voiceDrops
            selectedStopID = snapshot.stops.first?.id
        } catch {
            stops = []
            voiceDrops = []
            errorMessage = "Could not load your journey."
        }

        isLoading = false
    }

    func refreshCurrentLocation() async {
        guard !isResolvingCurrentLocation else { return }
        guard hasUsageDescription("NSLocationWhenInUseUsageDescription") else { return }

        isResolvingCurrentLocation = true
        defer { isResolvingCurrentLocation = false }

        await requestLocationAuthorizationIfNeeded()
        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else { return }
        guard let location = await requestOneLocation() else { return }

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let title = formattedLocationName(from: placemarks.first) {
                currentLocationName = title
            }
        } catch {
            currentLocationName = "Current Location"
        }
    }

    func locationQueryDidChange() {
        if let selectedStopID, !visibleStops.contains(where: { $0.id == selectedStopID }) {
            self.selectedStopID = visibleStops.first?.id
        }
        stopPlayback()
    }

    func selectStop(_ stop: JourneyStop) {
        guard selectedStopID != stop.id else { return }
        selectedStopID = stop.id
        stopPlayback()
    }

    func togglePlayback(for drop: VoiceDrop) {
        guard drop.isUnlocked else { return }

        if playingDropID == drop.id {
            stopPlayback()
        } else {
            play(drop)
        }
    }

    private func isDrop(_ drop: VoiceDrop, near stop: JourneyStop) -> Bool {
        let stopTokens = stop.place
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count > 2 }

        return drop.locationName.localizedCaseInsensitiveContains(stop.place)
            || stop.place.localizedCaseInsensitiveContains(drop.locationName)
            || stopTokens.contains { drop.locationName.localizedCaseInsensitiveContains($0) }
    }

    private func requestLocationAuthorizationIfNeeded() async {
        guard locationManager.authorizationStatus == .notDetermined else { return }

        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func requestOneLocation() async -> CLLocation? {
        await withCheckedContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    private func formattedLocationName(from placemark: CLPlacemark?) -> String? {
        guard let placemark else { return nil }

        if let locality = placemark.locality, let area = placemark.subLocality, !area.isEmpty {
            return "\(area), \(locality)"
        }

        if let locality = placemark.locality {
            return locality
        }

        if let area = placemark.subLocality {
            return area
        }

        return placemark.name
    }

    private func hasUsageDescription(_ key: String) -> Bool {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return false }
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func play(_ drop: VoiceDrop) {
        stopPlayback()
        playingDropID = drop.id
        playbackProgress = 0

        if let audioURL = drop.audioURL, playRecordedAudio(from: audioURL) {
            return
        }

        let utterance = AVSpeechUtterance(string: "\(drop.title). \(drop.caption)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IN") ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        speechSynthesizer.speak(utterance)
        startProgressTimer(step: 0.018)
    }

    private func playRecordedAudio(from url: URL) -> Bool {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayer = player
            player.delegate = self
            player.prepareToPlay()
            player.play()
            startProgressTimer(step: 0.12 / max(player.duration, 1))
            return true
        } catch {
            audioPlayer = nil
            return false
        }
    }

    private func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        audioPlayer = nil
        playingDropID = nil
        playbackProgress = 0
    }

    private func startProgressTimer(step: Double) {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            playbackProgress = min(playbackProgress + step, 1)
            if playbackProgress >= 1 {
                stopPlayback()
            }
        }
    }
}

private struct StaticJourneyDataSource: JourneyDataProviding {
    let stops: [JourneyStop]
    let voiceDrops: [VoiceDrop]

    func fetchJourney() async throws -> JourneySnapshot {
        JourneySnapshot(stops: stops, voiceDrops: voiceDrops)
    }
}

extension JourneyViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationContinuation?.resume()
        authorizationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationContinuation?.resume(returning: locations.last)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
    }
}

extension JourneyViewModel: AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        finishPlayback()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }

    private func finishPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        audioPlayer = nil
        playingDropID = nil
        playbackProgress = 0
    }
}
