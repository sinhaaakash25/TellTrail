import Foundation

struct JourneySnapshot {
    let stops: [JourneyStop]
    let voiceDrops: [VoiceDrop]
}

protocol JourneyDataProviding {
    func fetchJourney() async throws -> JourneySnapshot
}

struct PreviewJourneyDataSource: JourneyDataProviding {
    func fetchJourney() async throws -> JourneySnapshot {
        JourneySnapshot(stops: PreviewTrailData.stops, voiceDrops: PreviewTrailData.drops)
    }
}
