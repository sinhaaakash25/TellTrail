import SwiftUI

enum PreviewTrailData {
    static let aakash = Creator(name: "Aakash", handle: "@aakashtrails", initials: "AS", isVerified: true)
    static let meera = Creator(name: "Meera", handle: "@meeralocal", initials: "MR", isVerified: false)
    static let rahul = Creator(name: "Rahul", handle: "@rahulwalks", initials: "RK", isVerified: true)

    static let drops: [VoiceDrop] = [
        VoiceDrop(
            creator: aakash,
            title: "Hidden memory at MG Road",
            caption: "A short story from the metro exit where the street musicians play after sunset.",
            locationName: "MG Road Metro",
            distance: "120m away",
            postedAgo: "2h ago",
            duration: "0:45",
            progress: 0.48,
            likes: "240",
            comments: "31",
            range: "100m",
            isUnlocked: true,
            category: "City Story",
            mediaSymbol: "tram.fill",
            gradientColors: [TrailTheme.purple, TrailTheme.cyan]
        ),
        VoiceDrop(
            creator: meera,
            title: "Best chai spot near here",
            caption: "Order the ginger chai and stand by the old book wall. This one is worth the walk.",
            locationName: "Church Street",
            distance: "430m away",
            postedAgo: "5h ago",
            duration: "1:12",
            progress: 0.28,
            likes: "1.8K",
            comments: "96",
            range: "50m",
            isUnlocked: false,
            category: "Food Drop",
            mediaSymbol: "cup.and.saucer.fill",
            gradientColors: [TrailTheme.orange, TrailTheme.purple]
        ),
        VoiceDrop(
            creator: rahul,
            title: "Creator campaign: secret code",
            caption: "Walk into range to unlock the voice note and hear the launch-week discount code.",
            locationName: "Phoenix Mall",
            distance: "1.2km away",
            postedAgo: "1d ago",
            duration: "0:33",
            progress: 0.12,
            likes: "9.4K",
            comments: "420",
            range: "25m",
            isUnlocked: false,
            category: "Sponsored",
            mediaSymbol: "tag.fill",
            gradientColors: [TrailTheme.green, TrailTheme.cyan]
        )
    ]

    static let stops: [JourneyStop] = [
        JourneyStop(place: "Cubbon Park", detail: "3 notes unlocked", distance: "35m", count: 3, status: "Nearby", color: TrailTheme.green),
        JourneyStop(place: "MG Road", detail: "1 note played", distance: "120m", count: 1, status: "Unlocked", color: TrailTheme.cyan),
        JourneyStop(place: "Church Street", detail: "5 notes waiting", distance: "430m", count: 5, status: "Walk closer", color: TrailTheme.orange)
    ]

    static let chats: [ChatThread] = [
        ChatThread(name: "Rahul", message: "Voice reply on your MG Road drop", time: "2m", unreadCount: 2, isVoiceReply: true),
        ChatThread(name: "Meera", message: "That chai place is still open?", time: "18m", unreadCount: 0, isVoiceReply: false),
        ChatThread(name: "Trail Creators", message: "New sponsored drops campaign briefing", time: "1h", unreadCount: 5, isVoiceReply: false)
    ]

    static let metrics: [CreatorMetric] = [
        CreatorMetric(title: "Followers", value: "12.4K", trend: "+8.2%"),
        CreatorMetric(title: "Voice Drops", value: "92", trend: "+6"),
        CreatorMetric(title: "Total Plays", value: "1.2M", trend: "+18%"),
        CreatorMetric(title: "Unlock Rate", value: "42%", trend: "+3.1%")
    ]
}
