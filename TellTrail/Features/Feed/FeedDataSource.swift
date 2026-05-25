import Foundation

protocol FeedDataProviding {
    func fetchVoiceDrops() async throws -> [VoiceDrop]
}

struct PreviewFeedDataSource: FeedDataProviding {
    func fetchVoiceDrops() async throws -> [VoiceDrop] {
        PreviewTrailData.drops
    }
}
