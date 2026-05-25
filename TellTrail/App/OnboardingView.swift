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
            title: "Hear a place before you arrive",
            body: "Find short voice drops tied to real locations, so every trail starts with a local story.",
            symbol: "waveform.path.ecg",
            accent: TrailTheme.cyan
        ),
        OnboardingPage(
            title: "Leave memories where they happened",
            body: "Record a voice note, attach a snap, and save it to the map for others to discover nearby.",
            symbol: "mappin.and.ellipse",
            accent: TrailTheme.green
        ),
        OnboardingPage(
            title: "Explore voices around you",
            body: "Switch locations, open the map, play notes, and collect the moments that make a place feel alive.",
            symbol: "location.north.line",
            accent: TrailTheme.orange
        )
    ]
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let isAnimating: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer(minLength: 10)

            OnboardingHero(symbol: page.symbol, accent: page.accent, isAnimating: isAnimating)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(TrailTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.86)

                Text(page.body)
                    .font(.body.weight(.medium))
                    .foregroundStyle(TrailTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 6)
            }

            Spacer(minLength: 20)
        }
    }
}

private struct OnboardingHero: View {
    let symbol: String
    let accent: Color
    let isAnimating: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(TrailTheme.surface)
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(TrailTheme.border, lineWidth: 1)
                )

            VStack(spacing: 24) {
                ZStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(accent.opacity(0.18 - Double(index) * 0.04), lineWidth: 1)
                            .frame(width: CGFloat(116 + index * 48), height: CGFloat(116 + index * 48))
                            .scaleEffect(isAnimating ? 1.06 : 0.94)
                    }

                    Circle()
                        .fill(accent.opacity(0.16))
                        .frame(width: 112, height: 112)

                    Image(systemName: symbol)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(accent)
                }

                AnimatedWaveform(accent: accent, isAnimating: isAnimating)
                    .frame(height: 54)
                    .padding(.horizontal, 32)

                HStack(spacing: 10) {
                    Label("Map", systemImage: "map")
                    Label("Voice", systemImage: "mic")
                    Label("Snaps", systemImage: "photo")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(TrailTheme.secondaryText)
            }
            .padding(26)
        }
    }
}

private struct AnimatedWaveform: View {
    let accent: Color
    let isAnimating: Bool

    private let bars: [CGFloat] = [0.30, 0.58, 0.36, 0.78, 0.48, 0.92, 0.42, 0.70, 0.34, 0.62, 0.46, 0.86, 0.38, 0.66, 0.32]

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ForEach(bars.indices, id: \.self) { index in
                Capsule()
                    .fill(index % 3 == 0 ? accent : TrailTheme.primaryText.opacity(0.55))
                    .frame(width: 5, height: max(12, bars[index] * (isAnimating ? 54 : 34)))
                    .animation(.easeInOut(duration: 0.9 + Double(index % 4) * 0.12).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .frame(maxWidth: .infinity)
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
