import MapKit
import SwiftUI

struct JourneyView: View {
    @StateObject private var viewModel: JourneyViewModel
    @State private var selectedDrop: VoiceDrop?
    @State private var isEditingLocation = false

    init(viewModel: JourneyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    JourneyHeader(
                        subtitle: locationTitle,
                        isResolvingLocation: viewModel.isResolvingCurrentLocation,
                        isEditingLocation: isEditingLocation,
                        onLocationTap: {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                isEditingLocation.toggle()
                            }
                        }
                    )

                    if isEditingLocation {
                        JourneyLocationEditField(
                            locationQuery: $viewModel.locationQuery,
                            onQueryChange: viewModel.locationQueryDidChange,
                            onDone: {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                    isEditingLocation = false
                                }
                            }
                        )
                    }

                    if viewModel.isLoading {
                        JourneyLoadingState()
                    } else if let errorMessage = viewModel.errorMessage {
                        JourneyErrorState(message: errorMessage) {
                            Task { await viewModel.reload() }
                        }
                    } else {
                        MapDiscoveryPanel(
                            stops: viewModel.visibleStops,
                            selectedStop: viewModel.selectedStop,
                            onSelectStop: viewModel.selectStop
                        )
                        SelectedStopMapCard(stop: viewModel.selectedStop, dropCount: viewModel.selectedStopDrops.count)
                        SelectedStopNotes(
                            stop: viewModel.selectedStop,
                            drops: viewModel.selectedStopDrops,
                            playingDropID: viewModel.playingDropID,
                            playbackProgress: viewModel.playbackProgress,
                            onPlay: viewModel.togglePlayback,
                            onOpen: { selectedDrop = $0 }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 110)
            }
            .background(TrailTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: detailIsPresented) {
                if let drop = selectedDrop {
                    VoiceDropDetailView(
                        drop: drop,
                        isPlaying: viewModel.playingDropID == drop.id,
                        playbackProgress: viewModel.playingDropID == drop.id ? viewModel.playbackProgress : drop.progress,
                        onPlay: { viewModel.togglePlayback(for: drop) }
                    )
                }
            }
        }
        .task {
            await viewModel.loadIfNeeded()
            await viewModel.refreshCurrentLocation()
        }
    }

    private var detailIsPresented: Binding<Bool> {
        Binding(
            get: { selectedDrop != nil },
            set: { isPresented in
                if !isPresented {
                    selectedDrop = nil
                }
            }
        )
    }

    private var locationTitle: String {
        let query = viewModel.locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? viewModel.currentLocationName : query
    }
}

private struct JourneyHeader: View {
    let subtitle: String
    let isResolvingLocation: Bool
    let isEditingLocation: Bool
    let onLocationTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SplitHeaderTitle(primary: "Ex", accent: "plore")

            Button(action: onLocationTap) {
                HStack(spacing: 6) {
                    if isResolvingLocation {
                        ProgressView()
                            .scaleEffect(0.72)
                    } else {
                        Image(systemName: "mappin.and.ellipse")
                    }

                    Text(subtitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Image(systemName: isEditingLocation ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.bold))
                }
                .font(.subheadline)
                .foregroundStyle(TrailTheme.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SplitHeaderTitle: View {
    let primary: String
    let accent: String

    var body: some View {
        HStack(spacing: 0) {
            Text(primary)
                .foregroundStyle(.white)
            Text(accent)
                .foregroundStyle(TrailTheme.green)
        }
        .font(.title2.weight(.black))
        .lineLimit(1)
        .minimumScaleFactor(0.82)
        .accessibilityLabel(primary + accent)
    }
}

private struct JourneyLocationEditField: View {
    @Binding var locationQuery: String
    let onQueryChange: () -> Void
    let onDone: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "mappin.and.ellipse")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TrailTheme.cyan)

            TextField("Enter location", text: $locationQuery)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .submitLabel(.done)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TrailTheme.primaryText)
                .onSubmit(onDone)
                .onChange(of: locationQuery) { _, _ in
                    onQueryChange()
                }

            Button("Done", action: onDone)
                .font(.caption.weight(.bold))
                .foregroundStyle(TrailTheme.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }
}

private struct JourneyLoadingState: View {
    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
            Text("Loading journey")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TrailTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct JourneyErrorState: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(message)
                .font(.headline.weight(.bold))
            CompactButton(title: "Retry", symbol: "arrow.clockwise", style: .secondary)
                .onTapGesture(perform: onRetry)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct MapDiscoveryPanel: View {
    let stops: [JourneyStop]
    let selectedStop: JourneyStop?
    let onSelectStop: (JourneyStop) -> Void

    private var cameraPosition: MapCameraPosition {
        if let selectedStop {
            return .region(MKCoordinateRegion(
                center: selectedStop.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
            ))
        }

        return .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 12.9820, longitude: 77.6350),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.12)
        ))
    }

    var body: some View {
        Map(initialPosition: cameraPosition, interactionModes: [.pan, .zoom]) {
            ForEach(stops) { stop in
                Annotation(stop.place, coordinate: stop.coordinate, anchor: .bottom) {
                    Button {
                        onSelectStop(stop)
                    } label: {
                        VoicePin(stop: stop, isSelected: stop.id == selectedStop?.id)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .mapControlVisibility(.hidden)
        .frame(height: 270)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }
}

private struct SelectedStopMapCard: View {
    let stop: JourneyStop?
    let dropCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(stop?.color ?? TrailTheme.secondaryText)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 3) {
                Text(stop?.place ?? "Select a stop")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TrailTheme.primaryText)
                Text(detailText)
                    .font(.caption)
                    .foregroundStyle(TrailTheme.secondaryText)
            }

            Spacer()

            if let stop {
                Link(destination: mapsURL(for: stop)) {
                    Label("Navigate", systemImage: "arrow.triangle.turn.up.right.diamond")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(stop.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(TrailTheme.subtleFill, in: Capsule())
                }
            } else {
                Text("Map")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TrailTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(TrailTheme.subtleFill, in: Capsule())
            }
        }
        .padding(14)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }

    private var detailText: String {
        let noteText = dropCount == 1 ? "voice note" : "voice notes"
        return "\(dropCount) \(noteText) available"
    }

    private func mapsURL(for stop: JourneyStop) -> URL {
        let latitude = stop.coordinate.latitude
        let longitude = stop.coordinate.longitude
        let query = stop.place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? stop.place
        return URL(string: "http://maps.apple.com/?ll=\(latitude),\(longitude)&q=\(query)") ?? URL(string: "http://maps.apple.com")!
    }
}

private struct VoicePin: View {
    let stop: JourneyStop
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? stop.color : TrailTheme.surface)
                .frame(width: isSelected ? 40 : 34, height: isSelected ? 40 : 34)
                .overlay(Circle().stroke(stop.color.opacity(isSelected ? 0.72 : 0.48), lineWidth: 1))

            Circle()
                .fill(isSelected ? .white : stop.color)
                .frame(width: 9, height: 9)
        }
        .shadow(color: stop.color.opacity(isSelected ? 0.22 : 0), radius: 9, y: 5)
        .accessibilityLabel(stop.place)
    }
}

private struct JourneyStopList: View {
    let stops: [JourneyStop]
    let selectedStop: JourneyStop?
    let onSelectStop: (JourneyStop) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Journey")
                .font(.headline.weight(.bold))
            ForEach(stops) { stop in
                Button {
                    onSelectStop(stop)
                } label: {
                    JourneyStopRow(stop: stop, isSelected: stop.id == selectedStop?.id)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct SelectedStopNotes: View {
    let stop: JourneyStop?
    let drops: [VoiceDrop]
    let playingDropID: UUID?
    let playbackProgress: Double
    let onPlay: (VoiceDrop) -> Void
    let onOpen: (VoiceDrop) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(stop == nil ? "Voice Notes" : "Notes near \(stop?.place ?? "")")
                .font(.headline.weight(.bold))

            if drops.isEmpty {
                Text("No voice notes are attached to this stop yet.")
                    .font(.subheadline)
                    .foregroundStyle(TrailTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                ForEach(drops) { drop in
                    JourneyDropRow(
                        drop: drop,
                        isPlaying: playingDropID == drop.id,
                        progress: playingDropID == drop.id ? playbackProgress : drop.progress,
                        onPlay: { onPlay(drop) },
                        onOpen: { onOpen(drop) }
                    )
                }
            }
        }
    }
}

private struct JourneyDropRow: View {
    let drop: VoiceDrop
    let isPlaying: Bool
    let progress: Double
    let onPlay: () -> Void
    let onOpen: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onPlay) {
                Image(systemName: playSymbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(buttonForeground)
                    .frame(width: 38, height: 38)
                    .background(TrailTheme.elevated, in: Circle())
                    .overlay(Circle().stroke(buttonBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(!drop.isUnlocked)

            VStack(alignment: .leading, spacing: 6) {
                Text(drop.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TrailTheme.primaryText)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text("\(drop.creator.name) • \(drop.duration)")
                    Text(isPlaying ? "Playing" : drop.range)
                }
                .font(.caption)
                .foregroundStyle(TrailTheme.secondaryText)
                JourneyMiniProgress(progress: progress, isActive: isPlaying, isEnabled: drop.isUnlocked)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: onOpen)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(TrailTheme.secondaryText)
                .contentShape(Rectangle())
                .onTapGesture(perform: onOpen)
        }
        .padding(12)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isPlaying ? TrailTheme.cyan.opacity(0.42) : TrailTheme.border, lineWidth: 1)
        )
    }

    private var playSymbol: String {
        if !drop.isUnlocked { return "lock.fill" }
        return isPlaying ? "pause.fill" : "play.fill"
    }

    private var buttonForeground: Color {
        if !drop.isUnlocked { return TrailTheme.secondaryText }
        return isPlaying ? TrailTheme.cyan : TrailTheme.primaryText
    }

    private var buttonBorder: Color {
        isPlaying ? TrailTheme.cyan.opacity(0.54) : TrailTheme.border
    }
}

private struct JourneyMiniProgress: View {
    let progress: Double
    let isActive: Bool
    let isEnabled: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(TrailTheme.subtleFill)
                Capsule()
                    .fill(isActive && isEnabled ? TrailTheme.cyan : TrailTheme.secondaryText.opacity(0.32))
                    .frame(width: proxy.size.width * max(0, min(progress, 1)))
            }
        }
        .frame(height: 3)
    }
}

private struct JourneyStopRow: View {
    let stop: JourneyStop
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "mappin.circle.fill" : "mappin.circle")
                .font(.title2)
                .foregroundStyle(stop.color)
                .frame(width: 42, height: 42)
                .background(stop.color.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(stop.place)
                    .font(.headline.weight(.bold))
                Text(stop.detail)
                    .font(.caption)
                    .foregroundStyle(TrailTheme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(stop.distance)
                    .font(.caption.weight(.bold))
                Text(stop.status)
                    .font(.caption2)
                    .foregroundStyle(stop.color)
            }
        }
        .padding(14)
        .background(isSelected ? TrailTheme.elevated : TrailTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? stop.color.opacity(0.38) : TrailTheme.border, lineWidth: 1)
        )
    }
}
