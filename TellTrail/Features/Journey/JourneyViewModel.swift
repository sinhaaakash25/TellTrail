import AVFoundation
import Combine
import Foundation
import SwiftUI

final class JourneyViewModel: NSObject, ObservableObject {
    @Published private(set) var stops: [JourneyStop] = []
    @Published private(set) var voiceDrops: [VoiceDrop] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var playingDropID: UUID?
    @Published private(set) var playbackProgress = 0.0
    @Published var selectedMode = "Map"
    @Published var selectedStopID: UUID?

    let modes = ["Map", "List"]

    private let dataSource: JourneyDataProviding
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var playbackTimer: Timer?
    private var hasLoadedJourney = false

    var selectedStop: JourneyStop? {
        guard let selectedStopID else { return stops.first }
        return stops.first { $0.id == selectedStopID } ?? stops.first
    }

    var selectedStopDrops: [VoiceDrop] {
        guard let selectedStop else { return [] }
        let stopTokens = selectedStop.place
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count > 2 }

        return voiceDrops.filter { drop in
            drop.locationName.localizedCaseInsensitiveContains(selectedStop.place)
                || selectedStop.place.localizedCaseInsensitiveContains(drop.locationName)
                || stopTokens.contains { drop.locationName.localizedCaseInsensitiveContains($0) }
        }
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
    }

    convenience init(stops: [JourneyStop]) {
        self.init(dataSource: StaticJourneyDataSource(stops: stops, voiceDrops: PreviewTrailData.drops))
    }

    deinit {
        playbackTimer?.invalidate()
        speechSynthesizer.stopSpeaking(at: .immediate)
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

    func selectMode(_ mode: String) {
        guard selectedMode != mode else { return }
        selectedMode = mode
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

    private func play(_ drop: VoiceDrop) {
        stopPlayback()
        playingDropID = drop.id
        playbackProgress = 0

        let utterance = AVSpeechUtterance(string: "\(drop.title). \(drop.caption)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IN") ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        speechSynthesizer.speak(utterance)
        startProgressTimer()
    }

    private func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
        playingDropID = nil
        playbackProgress = 0
    }

    private func startProgressTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            playbackProgress = min(playbackProgress + 0.018, 1)
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

extension JourneyViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playbackTimer?.invalidate()
        playbackTimer = nil
        playingDropID = nil
        playbackProgress = 0
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}
