import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel: FeedViewModel
    @State private var selectedDrop: VoiceDrop?

    init(viewModel: FeedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HeaderView(title: "TellTrail", subtitle: subtitle, actionSymbol: "bell.badge")

                    LocationPicker(
                        locations: viewModel.locations,
                        selectedLocation: viewModel.selectedLocation,
                        onSelect: viewModel.selectLocation
                    )

                    HStack(spacing: 10) {
                        ForEach(viewModel.filters, id: \.self) { filter in
                            FilterChip(title: filter, symbol: symbol(for: filter), isSelected: viewModel.selectedFilter == filter)
                        }
                    }

                    ForEach(viewModel.visibleDrops) { drop in
                        VoiceDropCard(
                            drop: drop,
                            isPlaying: viewModel.playingDropID == drop.id,
                            playbackProgress: viewModel.playingDropID == drop.id ? viewModel.playbackProgress : drop.progress,
                            onPlay: { viewModel.togglePlayback(for: drop) },
                            onOpen: { selectedDrop = drop }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 110)
            }
            .background(TrailTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedDrop) { drop in
                VoiceDropDetailView(
                    drop: drop,
                    isPlaying: viewModel.playingDropID == drop.id,
                    playbackProgress: viewModel.playingDropID == drop.id ? viewModel.playbackProgress : drop.progress,
                    onPlay: { viewModel.togglePlayback(for: drop) }
                )
            }
        }
    }

    private var subtitle: String {
        let count = viewModel.visibleDrops.count
        let noteText = count == 1 ? "voice note" : "voice notes"
        return "\(count) \(noteText) near \(viewModel.selectedLocation)"
    }

    private func symbol(for filter: String) -> String {
        switch filter {
        case "Trending": "flame.fill"
        case "Following": "person.2.fill"
        default: "location.fill"
        }
    }
}

private struct LocationPicker: View {
    let locations: [String]
    let selectedLocation: String
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(locations, id: \.self) { location in
                    Button {
                        onSelect(location)
                    } label: {
                        Label(location, systemImage: location == "Nearby" ? "location.fill" : "mappin.and.ellipse")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(location == selectedLocation ? .white : TrailTheme.secondaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(
                                location == selectedLocation ? AnyShapeStyle(TrailTheme.accentGradient) : AnyShapeStyle(TrailTheme.surface),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule().stroke(TrailTheme.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 1)
        }
    }
}

private struct VoiceDropCard: View {
    let drop: VoiceDrop
    let isPlaying: Bool
    let playbackProgress: Double
    let onPlay: () -> Void
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    AvatarView(initials: drop.creator.initials, size: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 5) {
                            Text(drop.creator.name)
                                .font(.subheadline.weight(.bold))
                            if drop.creator.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundStyle(TrailTheme.cyan)
                            }
                        }
                        Text("\(drop.distance)  •  \(drop.postedAgo)")
                            .font(.caption)
                            .foregroundStyle(TrailTheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(TrailTheme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 7) {
                    Text(drop.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(TrailTheme.primaryText)
                    HStack(spacing: 8) {
                        Label(drop.locationName, systemImage: "mappin.and.ellipse")
                        Text(drop.category)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TrailTheme.cyan)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onOpen)

            AudioPlayerStrip(
                drop: drop,
                isPlaying: isPlaying,
                progress: playbackProgress,
                onPlay: onPlay
            )
        }
        .padding(16)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }
}

private struct VoiceDropDetailView: View {
    let drop: VoiceDrop
    let isPlaying: Bool
    let playbackProgress: Double
    let onPlay: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 10) {
                    AvatarView(initials: drop.creator.initials, size: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 5) {
                            Text(drop.creator.name)
                                .font(.headline.weight(.bold))
                            if drop.creator.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundStyle(TrailTheme.cyan)
                            }
                        }
                        Text(drop.creator.handle)
                            .font(.caption)
                            .foregroundStyle(TrailTheme.secondaryText)
                    }

                    Spacer()

                    LockBadge(isUnlocked: drop.isUnlocked)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(drop.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(TrailTheme.primaryText)
                    Text("\(drop.distance)  •  \(drop.postedAgo)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(TrailTheme.secondaryText)
                }

                MediaHero(drop: drop)
                AudioPlayerStrip(drop: drop, isPlaying: isPlaying, progress: playbackProgress, onPlay: onPlay)

                HStack(spacing: 18) {
                    ActionLabel(symbol: "heart.fill", text: drop.likes)
                    ActionLabel(symbol: "bubble.left.fill", text: drop.comments)
                    ActionLabel(symbol: "arrowshape.turn.up.right.fill", text: "Share")
                    Spacer()
                    ActionLabel(symbol: "bookmark.fill", text: "Save")
                }
                .padding(.vertical, 4)

                Text(drop.caption)
                    .font(.body)
                    .foregroundStyle(TrailTheme.secondaryText)
                    .lineSpacing(4)

                HStack(spacing: 8) {
                    Label(drop.locationName, systemImage: "mappin.and.ellipse")
                    Text(drop.category)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(TrailTheme.cyan)
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 32)
        }
        .background(TrailTheme.background.ignoresSafeArea())
        .navigationTitle("Voice Drop")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MediaHero: View {
    let drop: VoiceDrop

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: drop.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    Image(systemName: drop.mediaSymbol)
                        .font(.system(size: 84, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.86))
                )
                .frame(height: 210)

            HStack(spacing: 8) {
                Label(drop.range, systemImage: "scope")
                Text(drop.isUnlocked ? "Playable now" : "Walk closer to unlock")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.black.opacity(0.38), in: Capsule())
            .padding(12)
        }
    }
}

private struct AudioPlayerStrip: View {
    let drop: VoiceDrop
    let isPlaying: Bool
    let progress: Double
    let onPlay: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onPlay) {
                Image(systemName: playSymbol)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(buttonBackground, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!drop.isUnlocked)
            .accessibilityLabel(isPlaying ? "Pause voice note" : "Play voice note")

            VStack(alignment: .leading, spacing: 8) {
                WaveformView(progress: progress, isActive: drop.isUnlocked)
                HStack {
                    Text(statusText)
                    Spacer()
                    Text(drop.duration)
                }
                .font(.caption2.weight(.semibold))
                .foregroundStyle(TrailTheme.secondaryText)
            }
        }
        .padding(12)
        .background(TrailTheme.elevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var playSymbol: String {
        if !drop.isUnlocked { return "lock.fill" }
        return isPlaying ? "pause.fill" : "play.fill"
    }

    private var statusText: String {
        if !drop.isUnlocked { return "Locked" }
        return isPlaying ? "Playing" : "Tap to play"
    }

    private var buttonBackground: some ShapeStyle {
        if drop.isUnlocked {
            AnyShapeStyle(TrailTheme.accentGradient)
        } else {
            AnyShapeStyle(TrailTheme.subtleFill)
        }
    }
}
