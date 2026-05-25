import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                ProfileHero()

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.metrics) { metric in
                        MetricCard(metric: metric)
                    }
                }

                SegmentControl(options: viewModel.profileSections, selected: viewModel.selectedSection)

                VStack(spacing: 12) {
                    ForEach(viewModel.drops.prefix(2)) { drop in
                        MiniDropRow(drop: drop)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 110)
        }
    }
}

private struct ProfileHero: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(TrailTheme.accentGradient)
                .frame(height: 220)
                .overlay(
                    Image(systemName: "map.fill")
                        .font(.system(size: 96, weight: .bold))
                        .foregroundStyle(.white.opacity(0.28))
                        .offset(x: 96, y: -18)
                )

            HStack(alignment: .bottom, spacing: 14) {
                AvatarView(initials: "AS", size: 72)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text("Aakash Sinha")
                            .font(.title2.weight(.bold))
                        Image(systemName: "checkmark.seal.fill")
                    }
                    Text("@aakashtrails")
                        .foregroundStyle(.white.opacity(0.82))
                    HStack {
                        CompactButton(title: "Follow", symbol: "person.badge.plus", style: .dark)
                        CompactButton(title: "Message", symbol: "message.fill", style: .dark)
                    }
                    .padding(.top, 6)
                }
            }
            .padding(18)
        }
    }
}

private struct MetricCard: View {
    let metric: CreatorMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(metric.title)
                .font(.caption)
                .foregroundStyle(TrailTheme.secondaryText)
            Text(metric.value)
                .font(.title2.weight(.black))
            Text(metric.trend)
                .font(.caption.weight(.bold))
                .foregroundStyle(TrailTheme.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct MiniDropRow: View {
    let drop: VoiceDrop

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(colors: drop.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 68, height: 68)
                .overlay(Image(systemName: drop.mediaSymbol).foregroundStyle(.white).font(.title2))

            VStack(alignment: .leading, spacing: 5) {
                Text(drop.title)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                Text("\(drop.likes) plays  •  \(drop.locationName)")
                    .font(.caption)
                    .foregroundStyle(TrailTheme.secondaryText)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(TrailTheme.secondaryText)
        }
        .padding(12)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
