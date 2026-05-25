import SwiftUI
import UIKit

struct FeedView: View {
    @StateObject private var viewModel: FeedViewModel
    @State private var selectedDrop: VoiceDrop?
    @State private var isEditingLocation = false

    init(viewModel: FeedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    FeedHeader(
                        subtitle: subtitle,
                        isResolvingLocation: viewModel.isResolvingCurrentLocation,
                        isEditingLocation: isEditingLocation,
                        onLocationTap: {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                isEditingLocation.toggle()
                            }
                        }
                    )

                    if isEditingLocation {
                        LocationEditField(
                            locationQuery: $viewModel.locationQuery,
                            onQueryChange: viewModel.locationQueryDidChange,
                            onDone: {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                    isEditingLocation = false
                                }
                            }
                        )
                    }

                    HStack(spacing: 10) {
                        ForEach(viewModel.filters, id: \.self) { filter in
                            Button {
                                viewModel.selectFilter(filter)
                            } label: {
                                FilterChip(title: filter, symbol: symbol(for: filter), isSelected: viewModel.selectedFilter == filter)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if viewModel.isLoading {
                        FeedLoadingState()
                    } else if let errorMessage = viewModel.errorMessage {
                        FeedErrorState(message: errorMessage) {
                            Task { await viewModel.reload() }
                        }
                    } else if viewModel.visibleDrops.isEmpty {
                        EmptyLocationState(query: viewModel.locationQuery, filter: viewModel.selectedFilter)
                    } else {
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
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 110)
            }
            .background(TrailTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await viewModel.loadIfNeeded()
                await viewModel.refreshCurrentLocation()
            }
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

    private var subtitle: String {
        locationTitle
    }

    private var locationTitle: String {
        let query = viewModel.locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? viewModel.currentLocationName : query
    }

    private func symbol(for filter: String) -> String {
        switch filter {
        case "Trending": "flame.fill"
        case "Following": "person.2.fill"
        default: "location.fill"
        }
    }
}

private struct FeedHeader: View {
    let subtitle: String
    let isResolvingLocation: Bool
    let isEditingLocation: Bool
    let onLocationTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            BrandWordmark()

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

private struct BrandWordmark: View {
    var body: some View {
        HStack(spacing: 9) {
            ZStack {
                Circle()
                    .fill(TrailTheme.subtleFill)
                    .frame(width: 34, height: 34)

                Image(systemName: "waveform.path")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(TrailTheme.green)
            }

            HStack(spacing: 0) {
                Text("Tell")
                    .foregroundStyle(TrailTheme.primaryText)
                Text("Trail")
                    .foregroundStyle(TrailTheme.green)
            }
            .font(.title2.weight(.black))
        }
        .accessibilityLabel("TellTrail")
    }
}

private struct LocationEditField: View {
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

            if !locationQuery.isEmpty {
                Button {
                    locationQuery = ""
                    onQueryChange()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(TrailTheme.secondaryText)
                }
                .buttonStyle(.plain)
            }

            Button("Done", action: onDone)
                .font(.caption.weight(.bold))
                .foregroundStyle(TrailTheme.cyan)
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

private struct FeedLoadingState: View {
    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
            Text("Loading voice notes")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TrailTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }
}

private struct FeedErrorState: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(message)
                .font(.headline.weight(.bold))
                .foregroundStyle(TrailTheme.primaryText)
            CompactButton(title: "Retry", symbol: "arrow.clockwise", style: .secondary)
                .onTapGesture(perform: onRetry)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }
}

private struct EmptyLocationState: View {
    let query: String
    let filter: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No voice notes found")
                .font(.headline.weight(.bold))
                .foregroundStyle(TrailTheme.primaryText)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(TrailTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }

    private var message: String {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            return "No notes match the \(filter.lowercased()) filter yet."
        }
        return "No \(filter.lowercased()) notes found around \(trimmedQuery). Try MG Road, Church Street, or Phoenix Mall."
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

struct VoiceDropDetailView: View {
    let drop: VoiceDrop
    let isPlaying: Bool
    let playbackProgress: Double
    let onPlay: () -> Void

    @State private var isLiked = false
    @State private var isSaved = false
    @State private var isShowingComments = false
    @State private var isShowingMediaCarousel = false
    @State private var comments = VoiceDropComment.sampleComments

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

                DetailAudioCard(
                    drop: drop,
                    isPlaying: isPlaying,
                    progress: playbackProgress,
                    onPlay: onPlay,
                    onOpenMedia: { isShowingMediaCarousel = true }
                )

                HStack(spacing: 18) {
                    Button {
                        updateWithoutAnimation {
                            isLiked.toggle()
                        }
                    } label: {
                        ActionLabel(symbol: isLiked ? "heart.fill" : "heart", text: displayedLikes)
                            .foregroundStyle(isLiked ? TrailTheme.primaryText : TrailTheme.secondaryText)
                    }
                    .buttonStyle(.plain)

                    Button {
                        isShowingComments = true
                    } label: {
                        ActionLabel(symbol: "bubble.left", text: displayedComments)
                            .foregroundStyle(TrailTheme.secondaryText)
                    }
                    .buttonStyle(.plain)

                    ShareLink(item: shareText) {
                        ActionLabel(symbol: "arrowshape.turn.up.right", text: "Share")
                            .foregroundStyle(TrailTheme.secondaryText)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        updateWithoutAnimation {
                            isSaved.toggle()
                        }
                    } label: {
                        ActionLabel(symbol: isSaved ? "bookmark.fill" : "bookmark", text: isSaved ? "Saved" : "Save")
                            .foregroundStyle(isSaved ? TrailTheme.primaryText : TrailTheme.secondaryText)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
                .transaction { transaction in
                    transaction.animation = nil
                }

                Text(drop.caption)
                    .font(.body)
                    .foregroundStyle(TrailTheme.secondaryText)
                    .lineSpacing(4)

                Link(destination: mapsURL) {
                    HStack(spacing: 8) {
                        Label(drop.locationName, systemImage: "mappin.and.ellipse")
                        Text(drop.category)
                        Image(systemName: "arrow.up.right")
                            .font(.caption2.weight(.bold))
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TrailTheme.cyan)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
        .background(TrailTheme.background.ignoresSafeArea())
        .navigationTitle("Voice Drop")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingComments) {
            CommentsSheet(drop: drop, comments: $comments)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isShowingMediaCarousel) {
            MediaCarouselView(drop: drop)
                .presentationDetents([.large])
        }
    }

    private func updateWithoutAnimation(_ updates: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, updates)
    }

    private var displayedLikes: String {
        let likes = numericCount(drop.likes) + (isLiked ? 1 : 0)
        return formattedCount(likes)
    }

    private var displayedComments: String {
        formattedCount(Double(comments.count))
    }

    private var shareText: String {
        "Listen to \"\(drop.title)\" by \(drop.creator.name) at \(drop.locationName)."
    }

    private var mapsURL: URL {
        let query = drop.locationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? drop.locationName
        return URL(string: "http://maps.apple.com/?q=\(query)") ?? URL(string: "http://maps.apple.com")!
    }

    private func numericCount(_ value: String) -> Double {
        let normalized = value.replacingOccurrences(of: ",", with: "")
        if normalized.localizedCaseInsensitiveContains("K") {
            return (Double(normalized.replacingOccurrences(of: "K", with: "", options: .caseInsensitive)) ?? 0) * 1_000
        }
        if normalized.localizedCaseInsensitiveContains("M") {
            return (Double(normalized.replacingOccurrences(of: "M", with: "", options: .caseInsensitive)) ?? 0) * 1_000_000
        }
        return Double(normalized) ?? 0
    }

    private func formattedCount(_ count: Double) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", count / 1_000_000)
        }
        if count >= 1_000 {
            return String(format: "%.1fK", count / 1_000)
        }
        return String(Int(count))
    }
}

private struct VoiceDropComment: Identifiable {
    let id = UUID()
    let author: String
    let message: String
    let postedAgo: String

    static let sampleComments = [
        VoiceDropComment(author: "Tara", message: "This note made the place much easier to find.", postedAgo: "8m"),
        VoiceDropComment(author: "Kabir", message: "Saved this for my next walk nearby.", postedAgo: "24m"),
        VoiceDropComment(author: "Naina", message: "The audio tip is accurate.", postedAgo: "1h")
    ]
}

private struct CommentsSheet: View {
    let drop: VoiceDrop
    @Binding var comments: [VoiceDropComment]
    @State private var draftComment = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(drop.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(TrailTheme.secondaryText)

                        ForEach(comments) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                    .padding(16)
                }

                HStack(spacing: 10) {
                    TextField("Add a comment", text: $draftComment)
                        .textInputAutocapitalization(.sentences)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(TrailTheme.elevated, in: Capsule())

                    Button("Post") {
                        postComment()
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(draftComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? TrailTheme.secondaryText : TrailTheme.cyan)
                    .disabled(draftComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(16)
                .background(TrailTheme.surface)
            }
            .background(TrailTheme.background.ignoresSafeArea())
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func postComment() {
        let message = draftComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        comments.insert(VoiceDropComment(author: "You", message: message, postedAgo: "now"), at: 0)
        draftComment = ""
    }
}

private struct CommentRow: View {
    let comment: VoiceDropComment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(initials: initials, size: 34)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.author)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(TrailTheme.primaryText)
                    Text(comment.postedAgo)
                        .font(.caption)
                        .foregroundStyle(TrailTheme.secondaryText)
                }

                Text(comment.message)
                    .font(.subheadline)
                    .foregroundStyle(TrailTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }

    private var initials: String {
        comment.author
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }
}

private struct DetailAudioCard: View {
    let drop: VoiceDrop
    let isPlaying: Bool
    let progress: Double
    let onPlay: () -> Void
    let onOpenMedia: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onPlay) {
                Image(systemName: playSymbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(buttonForeground)
                    .frame(width: 36, height: 36)
                    .background(TrailTheme.elevated, in: Circle())
                    .overlay(Circle().stroke(buttonBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(!drop.isUnlocked)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text(isPlaying ? "Playing" : "Voice note")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(TrailTheme.primaryText)
                    Spacer(minLength: 8)
                    Text(drop.duration)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(TrailTheme.secondaryText)
                }

                VoiceDropProgressLine(progress: progress, isActive: isPlaying, isEnabled: drop.isUnlocked)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if drop.imageURL != nil {
                Button(action: onOpenMedia) {
                    SnapsIcon()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open photos")
            }
        }
        .padding(12)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
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

private struct SnapsIcon: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(TrailTheme.primaryText)

            Circle()
                .fill(TrailTheme.cyan)
                .frame(width: 7, height: 7)
                .offset(x: 4, y: -4)
        }
        .frame(width: 30, height: 30)
        .contentShape(Rectangle())
    }
}

private struct MediaCarouselView: View {
    let drop: VoiceDrop
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TabView {
                MediaThumbnail(drop: drop)
                    .scaledToFit()
                    .padding(16)
                    .tag(0)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .background(TrailTheme.background.ignoresSafeArea())
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct MediaThumbnail: View {
    let drop: VoiceDrop

    var body: some View {
        mediaContent
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TrailTheme.border, lineWidth: 1)
            )
    }

    @ViewBuilder
    private var mediaContent: some View {
        if let imageURL = drop.imageURL, imageURL.isFileURL, let image = UIImage(contentsOfFile: imageURL.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if let imageURL = drop.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    fallbackThumbnail.overlay(ProgressView().tint(.white))
                default:
                    fallbackThumbnail
                }
            }
        } else {
            fallbackThumbnail
        }
    }

    private var fallbackThumbnail: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(LinearGradient(colors: drop.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(
                Image(systemName: drop.mediaSymbol)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.86))
            )
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
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(buttonForeground)
                    .frame(width: 40, height: 40)
                    .background(TrailTheme.surface, in: Circle())
                    .overlay(Circle().stroke(buttonBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(!drop.isUnlocked)
            .accessibilityLabel(isPlaying ? "Pause voice note" : "Play voice note")

            VStack(alignment: .leading, spacing: 8) {
                VoiceDropProgressLine(progress: progress, isActive: isPlaying, isEnabled: drop.isUnlocked)
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
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TrailTheme.border, lineWidth: 1)
        )
    }

    private var playSymbol: String {
        if !drop.isUnlocked { return "lock.fill" }
        return isPlaying ? "pause.fill" : "play.fill"
    }

    private var statusText: String {
        if !drop.isUnlocked { return "Locked" }
        return isPlaying ? "Playing" : "Tap to play"
    }

    private var buttonForeground: Color {
        if !drop.isUnlocked { return TrailTheme.secondaryText }
        return isPlaying ? TrailTheme.cyan : TrailTheme.primaryText
    }

    private var buttonBorder: Color {
        isPlaying ? TrailTheme.cyan.opacity(0.58) : TrailTheme.border
    }
}

private struct VoiceDropProgressLine: View {
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
