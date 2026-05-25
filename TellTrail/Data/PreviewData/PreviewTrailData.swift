import CoreLocation
import SwiftUI

enum PreviewTrailData {
    static let aakash = Creator(name: "Aakash", handle: "@aakashtrails", initials: "AS", isVerified: true)
    static let prachi = Creator(name: "Prachi", handle: "@Prachi", initials: "PS", isVerified: false)
    static let medha = Creator(name: "Medha", handle: "@Medha", initials: "MS", isVerified: true)
    static let anu = Creator(name: "Anubhav", handle: "@absolut", initials: "AS", isVerified: true)
    static let abhay = Creator(name: "Abhay", handle: "@abhay", initials: "AS", isVerified: true)
    static let tara = Creator(name: "Tara", handle: "@taratrails", initials: "TT", isVerified: true)
    static let kabir = Creator(name: "Kabir", handle: "@kabirhikes", initials: "KH", isVerified: false)
    static let naina = Creator(name: "Naina", handle: "@nainavalley", initials: "NV", isVerified: true)

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
            imageURL: URL(string: "https://picsum.photos/seed/mg-road-metro/900/600"),
            mediaSymbol: "tram.fill",
            gradientColors: [TrailTheme.purple, TrailTheme.cyan]
        ),
        VoiceDrop(
            creator: prachi,
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
            imageURL: URL(string: "https://picsum.photos/seed/church-street-chai/900/600"),
            mediaSymbol: "cup.and.saucer.fill",
            gradientColors: [TrailTheme.orange, TrailTheme.purple]
        ),
        VoiceDrop(
            creator: medha,
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
            imageURL: URL(string: "https://picsum.photos/seed/phoenix-mall-campaign/900/600"),
            mediaSymbol: "tag.fill",
            gradientColors: [TrailTheme.green, TrailTheme.cyan]
        ),
        VoiceDrop(
            creator: anu,
            title: "Quiet bench behind the bookstore",
            caption: "A calm two-minute pause near Church Street when the crowd gets too loud.",
            locationName: "Church Street",
            distance: "380m away",
            postedAgo: "40m ago",
            duration: "0:58",
            progress: 0.36,
            likes: "684",
            comments: "42",
            range: "50m",
            isUnlocked: true,
            category: "Local Tip",
            imageURL: URL(string: "https://picsum.photos/seed/church-street-bookstore/900/600"),
            mediaSymbol: "book.closed.fill",
            gradientColors: [TrailTheme.cyan, TrailTheme.green]
        ),
        VoiceDrop(
            creator: abhay,
            title: "Metro exit shortcut",
            caption: "Use the east exit after 7 PM if you want the faster walk to Brigade Road.",
            locationName: "MG Road Metro",
            distance: "95m away",
            postedAgo: "1h ago",
            duration: "0:28",
            progress: 0.64,
            likes: "118",
            comments: "12",
            range: "100m",
            isUnlocked: true,
            category: "Shortcut",
            imageURL: URL(string: "https://picsum.photos/seed/mg-road-shortcut/900/600"),
            mediaSymbol: "arrow.turn.up.right",
            gradientColors: [TrailTheme.purple, TrailTheme.orange]
        ),
        VoiceDrop(
            creator: aakash,
            title: "Food court table worth finding",
            caption: "The balcony corner has the best view and usually opens up after lunch rush.",
            locationName: "Phoenix Mall",
            distance: "1.1km away",
            postedAgo: "3h ago",
            duration: "0:41",
            progress: 0.22,
            likes: "2.3K",
            comments: "77",
            range: "500m",
            isUnlocked: true,
            category: "Mall Guide",
            imageURL: URL(string: "https://picsum.photos/seed/phoenix-mall-food-court/900/600"),
            mediaSymbol: "fork.knife",
            gradientColors: [TrailTheme.orange, TrailTheme.cyan]
        ),
        VoiceDrop(
            creator: tara,
            title: "Old Manali bridge at sunrise",
            caption: "Stand near the wooden bridge just after sunrise and you can hear the river before the cafes wake up.",
            locationName: "Old Manali",
            distance: "220m away",
            postedAgo: "25m ago",
            duration: "0:52",
            progress: 0.42,
            likes: "3.1K",
            comments: "84",
            range: "100m",
            isUnlocked: true,
            category: "Mountain Story",
            imageURL: URL(string: "https://picsum.photos/seed/old-manali-bridge/900/600"),
            mediaSymbol: "mountain.2.fill",
            gradientColors: [TrailTheme.green, TrailTheme.cyan]
        ),
        VoiceDrop(
            creator: kabir,
            title: "Hidden momo place on Mall Road",
            caption: "Take the narrow stairs beside the wool shop. Ask for the chilli chutney separately.",
            locationName: "Mall Road, Manali",
            distance: "540m away",
            postedAgo: "2h ago",
            duration: "0:36",
            progress: 0.30,
            likes: "742",
            comments: "29",
            range: "50m",
            isUnlocked: true,
            category: "Food Drop",
            imageURL: URL(string: "https://picsum.photos/seed/manali-mall-road-momos/900/600"),
            mediaSymbol: "takeoutbag.and.cup.and.straw.fill",
            gradientColors: [TrailTheme.orange, TrailTheme.purple]
        ),
        VoiceDrop(
            creator: naina,
            title: "Solang trail wind check",
            caption: "If the flags near the first bend are snapping hard, wait before heading up for paragliding.",
            locationName: "Solang Valley, Manali",
            distance: "8.4km away",
            postedAgo: "5h ago",
            duration: "1:05",
            progress: 0.55,
            likes: "5.6K",
            comments: "138",
            range: "500m",
            isUnlocked: false,
            category: "Adventure Tip",
            imageURL: URL(string: "https://picsum.photos/seed/solang-valley-manali/900/600"),
            mediaSymbol: "figure.hiking",
            gradientColors: [TrailTheme.purple, TrailTheme.green]
        )
    ]

    static let stops: [JourneyStop] = [
        JourneyStop(place: "MG Road", detail: "2 notes unlocked", distance: "120m", count: 2, status: "Unlocked", coordinate: CLLocationCoordinate2D(latitude: 12.9754, longitude: 77.6068), color: TrailTheme.cyan),
        JourneyStop(place: "Church Street", detail: "2 notes waiting", distance: "430m", count: 2, status: "Walk closer", coordinate: CLLocationCoordinate2D(latitude: 12.9750, longitude: 77.6013), color: TrailTheme.orange),
        JourneyStop(place: "Phoenix Mall", detail: "2 creator drops", distance: "1.2km", count: 2, status: "Nearby", coordinate: CLLocationCoordinate2D(latitude: 12.9966, longitude: 77.6964), color: TrailTheme.green),
        JourneyStop(place: "Old Manali", detail: "1 note unlocked", distance: "220m", count: 1, status: "Unlocked", coordinate: CLLocationCoordinate2D(latitude: 32.2539, longitude: 77.1772), color: TrailTheme.cyan),
        JourneyStop(place: "Mall Road, Manali", detail: "1 food drop", distance: "540m", count: 1, status: "Nearby", coordinate: CLLocationCoordinate2D(latitude: 32.2432, longitude: 77.1892), color: TrailTheme.orange),
        JourneyStop(place: "Solang Valley, Manali", detail: "1 adventure tip", distance: "8.4km", count: 1, status: "Walk closer", coordinate: CLLocationCoordinate2D(latitude: 32.3165, longitude: 77.1576), color: TrailTheme.green)
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
