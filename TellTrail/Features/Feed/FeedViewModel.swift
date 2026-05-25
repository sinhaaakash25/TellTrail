//
//  FeedViewModel.swift
//  TellTrail
//
//  Created by Aakash Sinha on 12/05/26.
//

import AVFoundation
import Combine
import CoreLocation
import Foundation
import SwiftUI

final class FeedViewModel: NSObject, ObservableObject {
    @Published private(set) var drops: [VoiceDrop] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var selectedFilter = "Nearby"
    @Published var locationQuery = ""
    @Published private(set) var currentLocationName = "Current Location"
    @Published private(set) var isResolvingCurrentLocation = false
    @Published private(set) var playingDropID: UUID?
    @Published private(set) var playbackProgress = 0.0

    let filters = ["Nearby", "Trending", "Following"]

    private let dataSource: FeedDataProviding
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    private var authorizationContinuation: CheckedContinuation<Void, Never>?
    private var storeCancellable: AnyCancellable?
    private var playbackTimer: Timer?
    private var hasLoadedDrops = false

    var visibleDrops: [VoiceDrop] {
        let locationFilteredDrops = filteredByLocation(drops)

        switch selectedFilter {
        case "Trending":
            return locationFilteredDrops.sorted { numericCount($0.likes) > numericCount($1.likes) }
        case "Following":
            return locationFilteredDrops.filter { $0.creator.isVerified }
        default:
            return locationFilteredDrops
        }
    }

    init(dataSource: FeedDataProviding = PreviewFeedDataSource()) {
        self.dataSource = dataSource
        super.init()
        speechSynthesizer.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if let store = dataSource as? TrailDataStore {
            storeCancellable = store.$drops.sink { [weak self] drops in
                self?.drops = drops
            }
        }
    }

    convenience init(drops: [VoiceDrop]) {
        self.init(dataSource: StaticFeedDataSource(drops: drops))
    }

    deinit {
        playbackTimer?.invalidate()
        speechSynthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        locationContinuation?.resume(returning: nil)
        authorizationContinuation?.resume()
    }

    func loadIfNeeded() async {
        guard !hasLoadedDrops else { return }
        hasLoadedDrops = true
        await reload()
    }

    func reload() async {
        isLoading = true
        errorMessage = nil

        do {
            drops = try await dataSource.fetchVoiceDrops()
        } catch {
            drops = []
            errorMessage = "Could not load voice notes."
        }

        isLoading = false
    }

    func selectFilter(_ filter: String) {
        selectedFilter = filter
        stopPlayback()
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

    private func filteredByLocation(_ drops: [VoiceDrop]) -> [VoiceDrop] {
        let query = locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return drops }
        return drops.filter { $0.locationName.localizedCaseInsensitiveContains(query) }
    }

    private func numericCount(_ value: String) -> Double {
        let normalized = value.replacingOccurrences(of: ",", with: "")
        if normalized.localizedCaseInsensitiveContains("K") {
            return (Double(normalized.replacingOccurrences(of: "K", with: "", options: .caseInsensitive)) ?? 0) * 1_000
        }
        if normalized.localizedCaseInsensitiveContains("M") {
            return (Double(normalized.replacingOccurrences(of: "M", with: "", options: .caseInsensitive)) ?? 0) * 1_000_000
        }
        return Double(normalized) ?? 0
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

private struct StaticFeedDataSource: FeedDataProviding {
    let drops: [VoiceDrop]

    func fetchVoiceDrops() async throws -> [VoiceDrop] {
        drops
    }
}

extension FeedViewModel: CLLocationManagerDelegate {
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

extension FeedViewModel: AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
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
