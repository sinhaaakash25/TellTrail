import CoreLocation
import Foundation

final class TrailDataStore: ObservableObject, FeedDataProviding, JourneyDataProviding {
    @Published private(set) var drops: [VoiceDrop]
    @Published private(set) var stops: [JourneyStop]

    init(drops: [VoiceDrop] = PreviewTrailData.drops, stops: [JourneyStop] = PreviewTrailData.stops) {
        self.drops = drops
        self.stops = stops
    }

    func fetchVoiceDrops() async throws -> [VoiceDrop] {
        drops
    }

    func fetchJourney() async throws -> JourneySnapshot {
        JourneySnapshot(stops: stops, voiceDrops: drops)
    }

    func addVoiceDrop(title: String, caption: String, locationName: String, duration: String, range: String) {
        let drop = VoiceDrop(
            creator: PreviewTrailData.aakash,
            title: title,
            caption: caption.isEmpty ? "New voice note from this location." : caption,
            locationName: locationName,
            distance: "Here",
            postedAgo: "Just now",
            duration: duration,
            progress: 0,
            likes: "0",
            comments: "0",
            range: range,
            isUnlocked: true,
            category: "Voice Drop",
            imageURL: nil,
            mediaSymbol: "mic.fill",
            gradientColors: [TrailTheme.cyan, TrailTheme.green]
        )

        drops.insert(drop, at: 0)
        upsertStop(for: locationName)
    }

    private func upsertStop(for locationName: String) {
        if let matchingIndex = stops.firstIndex(where: { isLocation(locationName, near: $0.place) }) {
            let stop = stops[matchingIndex]
            stops[matchingIndex] = JourneyStop(
                place: stop.place,
                detail: "\(stop.count + 1) notes available",
                distance: stop.distance,
                count: stop.count + 1,
                status: "Nearby",
                coordinate: stop.coordinate,
                color: stop.color
            )
            return
        }

        stops.append(
            JourneyStop(
                place: locationName,
                detail: "1 note available",
                distance: "Here",
                count: 1,
                status: "Nearby",
                coordinate: fallbackCoordinate(for: locationName),
                color: TrailTheme.cyan
            )
        )
    }

    private func isLocation(_ locationName: String, near stopPlace: String) -> Bool {
        locationName.localizedCaseInsensitiveContains(stopPlace)
            || stopPlace.localizedCaseInsensitiveContains(locationName)
            || stopPlace
                .split(separator: " ")
                .map(String.init)
                .filter { $0.count > 2 }
                .contains { locationName.localizedCaseInsensitiveContains($0) }
    }

    private func fallbackCoordinate(for locationName: String) -> CLLocationCoordinate2D {
        if locationName.localizedCaseInsensitiveContains("manali") {
            return CLLocationCoordinate2D(latitude: 32.2432, longitude: 77.1892)
        }

        if locationName.localizedCaseInsensitiveContains("church") {
            return CLLocationCoordinate2D(latitude: 12.9750, longitude: 77.6013)
        }

        if locationName.localizedCaseInsensitiveContains("phoenix") {
            return CLLocationCoordinate2D(latitude: 12.9966, longitude: 77.6964)
        }

        return CLLocationCoordinate2D(latitude: 12.9754, longitude: 77.6068)
    }
}
