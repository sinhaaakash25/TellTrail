import CoreLocation
import Foundation
import SwiftUI

enum TrailTab: String, CaseIterable, Identifiable {
    case feed = "Feed"
    case journey = "Explore"
    case record = "Record"
    case chat = "Chat"
    case profile = "Profile"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .feed: "waveform.path.ecg.rectangle"
        case .journey: "map"
        case .record: "mic.circle.fill"
        case .chat: "bubble.left.and.bubble.right"
        case .profile: "person.crop.circle"
        }
    }
}

struct VoiceDrop: Identifiable {
    let id = UUID()
    let creator: Creator
    let title: String
    let caption: String
    let locationName: String
    let distance: String
    let postedAgo: String
    let duration: String
    let progress: Double
    let likes: String
    let comments: String
    let range: String
    let isUnlocked: Bool
    let category: String
    let imageURL: URL?
    let mediaSymbol: String
    let gradientColors: [Color]
    let audioURL: URL?

    init(
        creator: Creator,
        title: String,
        caption: String,
        locationName: String,
        distance: String,
        postedAgo: String,
        duration: String,
        progress: Double,
        likes: String,
        comments: String,
        range: String,
        isUnlocked: Bool,
        category: String,
        imageURL: URL?,
        mediaSymbol: String,
        gradientColors: [Color],
        audioURL: URL? = nil
    ) {
        self.creator = creator
        self.title = title
        self.caption = caption
        self.locationName = locationName
        self.distance = distance
        self.postedAgo = postedAgo
        self.duration = duration
        self.progress = progress
        self.likes = likes
        self.comments = comments
        self.range = range
        self.isUnlocked = isUnlocked
        self.category = category
        self.imageURL = imageURL
        self.mediaSymbol = mediaSymbol
        self.gradientColors = gradientColors
        self.audioURL = audioURL
    }
}

struct Creator: Identifiable {
    let id = UUID()
    let name: String
    let handle: String
    let initials: String
    let isVerified: Bool
}

struct JourneyStop: Identifiable {
    let id = UUID()
    let place: String
    let detail: String
    let distance: String
    let count: Int
    let status: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
}

struct ChatThread: Identifiable {
    let id = UUID()
    let name: String
    let message: String
    let time: String
    let unreadCount: Int
    let isVoiceReply: Bool
}

struct CreatorMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let trend: String
}
