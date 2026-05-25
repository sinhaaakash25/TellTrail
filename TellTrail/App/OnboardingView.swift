import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var selectedPage = 0
    @State private var animateSignal = false

    private let pages = OnboardingPage.all

    var body: some View {
        ZStack {
            OnboardingBackground()

            VStack(spacing: 0) {
                HStack {
                    OnboardingWordmark()

                    Spacer()

                    Button("Skip", action: onFinish)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(TrailTheme.secondaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(TrailTheme.subtleFill, in: Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, isAnimating: animateSignal)
                            .tag(index)
                            .padding(.horizontal, 24)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == selectedPage ? TrailTheme.green : TrailTheme.subtleFill)
                                .frame(width: index == selectedPage ? 26 : 8, height: 8)
                                .animation(.spring(response: 0.28, dampingFraction: 0.8), value: selectedPage)
                        }
                    }

                    Button {
                        if selectedPage == pages.count - 1 {
                            onFinish()
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                selectedPage += 1
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(selectedPage == pages.count - 1 ? "Start exploring" : "Continue")
                                .font(.headline.weight(.bold))

                            Image(systemName: selectedPage == pages.count - 1 ? "arrow.right" : "chevron.right")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(Color(red: 0.03, green: 0.05, blue: 0.12))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(TrailTheme.green, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                animateSignal = true
            }
        }
    }
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let symbol: String
    let accent: Color

    static let all: [OnboardingPage] = [
        OnboardingPage(
            title: "Places have stories. We saved the audio.",
            body: "Find short voice drops tied to real locations, so every trail starts with something worth hearing.",
            symbol: "waveform.path.ecg",
            accent: TrailTheme.cyan
        ),
        OnboardingPage(
            title: "Drop a voice note where the moment happened.",
            body: "Record a thought, attach a snap, and leave it on the map for the next curious traveler.",
            symbol: "mappin.and.ellipse",
            accent: TrailTheme.green
        ),
        OnboardingPage(
            title: "Wander less blindly. Listen first.",
            body: "Change location, open the map, play nearby notes, and let the best local clues find you.",
            symbol: "location.north.line",
            accent: TrailTheme.orange
        )
    ]
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let isAnimating: Bool

    var body: some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.height < 610
            let heroHeight = min(isCompact ? 218 : 252, proxy.size.height * 0.44)

            VStack(spacing: isCompact ? 18 : 24) {
                Spacer(minLength: isCompact ? 4 : 10)

                OnboardingHero(symbol: page.symbol, accent: page.accent, isAnimating: isAnimating, height: heroHeight)

                VStack(spacing: 10) {
                    Text(page.title)
                        .font(.system(size: isCompact ? 27 : 31, weight: .black, design: .rounded))
                        .foregroundStyle(TrailTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.78)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(page.body)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(TrailTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .lineLimit(4)
                        .minimumScaleFactor(0.84)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)
                }
                .frame(maxWidth: .infinity)

                Spacer(minLength: isCompact ? 4 : 14)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

private struct OnboardingHero: View {
    let symbol: String
    let accent: Color
    let isAnimating: Bool
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(TrailTheme.surface)
                .frame(height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(TrailTheme.border, lineWidth: 1)
                )

            VStack(spacing: 16) {
                ZStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(accent.opacity(0.18 - Double(index) * 0.04), lineWidth: 1)
                            .frame(width: CGFloat(88 + index * 36), height: CGFloat(88 + index * 36))
                            .scaleEffect(isAnimating ? 1.05 : 0.96)
                    }

                    Circle()
                        .fill(accent.opacity(0.16))
                        .frame(width: 86, height: 86)

                    Image(systemName: symbol)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(accent)
                }
                .frame(height: max(92, height * 0.44))

                AnimatedWaveform(accent: accent, isAnimating: isAnimating)
                    .frame(height: 38)
                    .padding(.horizontal, 26)

                HStack(spacing: 8) {
                    OnboardingFeatureChip(title: "Map", symbol: "map")
                    OnboardingFeatureChip(title: "Voice", symbol: "mic")
                    OnboardingFeatureChip(title: "Snaps", symbol: "photo")
                }
                .padding(.bottom, 2)
            }
            .padding(.horizontal, 18)
            .frame(height: height)
        }
        .frame(height: height)
    }
}

private struct OnboardingFeatureChip: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(TrailTheme.secondaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(TrailTheme.subtleFill, in: Capsule())
    }
}

private struct AnimatedWaveform: View {
    let accent: Color
    let isAnimating: Bool

    private let bars: [CGFloat] = [0.30, 0.58, 0.36, 0.78, 0.48, 0.92, 0.42, 0.70, 0.34, 0.62, 0.46, 0.86, 0.38, 0.66, 0.32]

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 6) {
                ForEach(bars.indices, id: \.self) { index in
                    Capsule()
                        .fill(index % 3 == 0 ? accent : TrailTheme.primaryText.opacity(0.55))
                        .frame(width: 5, height: max(10, bars[index] * (isAnimating ? proxy.size.height : proxy.size.height * 0.65)))
                        .animation(.easeInOut(duration: 0.9 + Double(index % 4) * 0.12).repeatForever(autoreverses: true), value: isAnimating)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

private struct OnboardingWordmark: View {
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
            .font(.title3.weight(.black))
        }
        .accessibilityLabel("TellTrail")
    }
}

private struct OnboardingBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                TrailTheme.background,
                Color(red: 0.04, green: 0.10, blue: 0.26),
                TrailTheme.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [TrailTheme.cyan.opacity(0.18), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 260)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    OnboardingView(onFinish: { })
}
