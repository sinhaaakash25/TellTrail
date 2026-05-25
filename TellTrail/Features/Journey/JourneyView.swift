import SwiftUI

struct JourneyView: View {
    @StateObject private var viewModel: JourneyViewModel

    init(viewModel: JourneyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                HeaderView(title: "Journey", subtitle: viewModel.nearbySummary, actionSymbol: "location.north.circle")

                ModePicker(options: viewModel.modes, selected: viewModel.selectedMode) { mode in
                    viewModel.selectMode(mode)
                }

                if viewModel.isLoading {
                    JourneyLoadingState()
                } else if let errorMessage = viewModel.errorMessage {
                    JourneyErrorState(message: errorMessage) {
                        Task { await viewModel.reload() }
                    }
                } else if viewModel.selectedMode == "Map" {
                    MapDiscoveryPanel(
                        stops: viewModel.stops,
                        selectedStop: viewModel.selectedStop,
                        selectedDrops: viewModel.selectedStopDrops,
                        onSelectStop: viewModel.selectStop
                    )
                    SelectedStopNotes(stop: viewModel.selectedStop, drops: viewModel.selectedStopDrops)
                } else {
                    JourneyStopList(
                        stops: viewModel.stops,
                        selectedStop: viewModel.selectedStop,
                        onSelectStop: viewModel.selectStop
                    )
                    SelectedStopNotes(stop: viewModel.selectedStop, drops: viewModel.selectedStopDrops)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 110)
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}

private struct ModePicker: View {
    let options: [String]
    let selected: String
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    Text(option)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(option == selected ? TrailTheme.primaryText : TrailTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(option == selected ? TrailTheme.subtleFill : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(TrailTheme.surface, in: Capsule())
        .overlay(Capsule().stroke(TrailTheme.border, lineWidth: 1))
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
    let selectedDrops: [VoiceDrop]
    let onSelectStop: (JourneyStop) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(TrailTheme.elevated)
                .frame(height: 330)
                .overlay(MapGrid().opacity(0.28))
                .overlay(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.26)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                )

            ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                Button {
                    onSelectStop(stop)
                } label: {
                    VoicePin(index: index, stop: stop, isSelected: stop.id == selectedStop?.id)
                }
                .buttonStyle(.plain)
            }

            SelectedStopMapCard(stop: selectedStop, dropCount: selectedDrops.count)
                .padding(12)
        }
    }
}

private struct SelectedStopMapCard: View {
    let stop: JourneyStop?
    let dropCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stop?.status ?? "Select a stop")
                .font(.caption.weight(.semibold))
                .foregroundStyle(stop?.color ?? TrailTheme.secondaryText)
            Text(stop?.place ?? "Journey map")
                .font(.title3.weight(.bold))
            Text("\(dropCount) voice notes available")
                .font(.caption)
                .foregroundStyle(TrailTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }
}

private struct MapGrid: View {
    var body: some View {
        Canvas { context, size in
            let path = Path { path in
                for x in stride(from: 0, through: size.width, by: 44) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + 28, y: size.height))
                }
                for y in stride(from: 0, through: size.height, by: 42) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y + 18))
                }
            }
            context.stroke(path, with: .color(TrailTheme.secondaryText.opacity(0.42)), lineWidth: 1)
        }
    }
}

private struct VoicePin: View {
    let index: Int
    let stop: JourneyStop
    let isSelected: Bool

    private var offset: CGSize {
        switch index {
        case 0: CGSize(width: -98, height: -64)
        case 1: CGSize(width: 74, height: -86)
        case 2: CGSize(width: -24, height: -150)
        case 3: CGSize(width: 104, height: -18)
        default: CGSize(width: -112, height: -138)
        }
    }

    var body: some View {
        Image(systemName: isSelected ? "mappin.circle.fill" : "mappin.circle")
            .font(.title3.weight(.semibold))
            .foregroundStyle(isSelected ? .white : stop.color)
            .frame(width: isSelected ? 48 : 42, height: isSelected ? 48 : 42)
            .background(isSelected ? stop.color : TrailTheme.surface, in: Circle())
            .overlay(Circle().stroke(stop.color.opacity(0.52), lineWidth: 1))
            .shadow(color: stop.color.opacity(isSelected ? 0.28 : 0), radius: 12, y: 6)
            .offset(offset)
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
                    JourneyDropRow(drop: drop)
                }
            }
        }
    }
}

private struct JourneyDropRow: View {
    let drop: VoiceDrop

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: drop.isUnlocked ? "play.circle" : "lock.circle")
                .font(.title2)
                .foregroundStyle(drop.isUnlocked ? TrailTheme.cyan : TrailTheme.secondaryText)
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text(drop.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TrailTheme.primaryText)
                    .lineLimit(1)
                Text("\(drop.creator.name) • \(drop.duration)")
                    .font(.caption)
                    .foregroundStyle(TrailTheme.secondaryText)
            }

            Spacer()

            Text(drop.range)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TrailTheme.secondaryText)
        }
        .padding(12)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
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
