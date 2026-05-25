import SwiftUI

struct LoginView: View {
    let onLogin: () -> Void

    @State private var isSigningIn = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            LoginBackground()

            VStack(spacing: 0) {
                Spacer(minLength: 34)

                VStack(spacing: 24) {
                    LoginBrandMark(isPulsing: pulse)

                    VStack(spacing: 10) {
                        HStack(spacing: 0) {
                            Text("Tell")
                                .foregroundStyle(.white)
                            Text("Trail")
                                .foregroundStyle(TrailTheme.green)
                        }
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .accessibilityLabel("TellTrail")

                        Text("Save voices to places. Discover stories around you.")
                            .font(.body.weight(.medium))
                            .foregroundStyle(TrailTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 18)
                    }
                }

                Spacer(minLength: 36)

                VStack(spacing: 14) {
                    Button {
                        signIn()
                    } label: {
                        HStack(spacing: 12) {
                            if isSigningIn {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Image(systemName: "apple.logo")
                                    .font(.title3.weight(.semibold))
                            }

                            Text(isSigningIn ? "Signing in" : "Continue with Apple")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSigningIn)

                    Button {
                        onLogin()
                    } label: {
                        Text("Continue as demo user")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(TrailTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(TrailTheme.subtleFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Text("Apple sign-in is mocked for this MVP build.")
                        .font(.caption)
                        .foregroundStyle(TrailTheme.secondaryText.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func signIn() {
        guard !isSigningIn else { return }
        isSigningIn = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            onLogin()
        }
    }
}

private struct LoginBrandMark: View {
    let isPulsing: Bool

    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(TrailTheme.cyan.opacity(0.18 - Double(index) * 0.04), lineWidth: 1)
                    .frame(width: CGFloat(116 + index * 42), height: CGFloat(116 + index * 42))
                    .scaleEffect(isPulsing ? 1.06 : 0.95)
            }

            Circle()
                .fill(TrailTheme.surface)
                .frame(width: 112, height: 112)
                .overlay(Circle().stroke(TrailTheme.border, lineWidth: 1))

            Image(systemName: "waveform.path")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(TrailTheme.green)
        }
        .frame(height: 190)
    }
}

private struct LoginBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                TrailTheme.background,
                Color(red: 0.05, green: 0.12, blue: 0.30),
                TrailTheme.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(TrailTheme.cyan.opacity(0.16))
                .frame(width: 240, height: 240)
                .blur(radius: 80)
                .offset(x: 80, y: -90)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(TrailTheme.green.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 90)
                .offset(x: -90, y: 80)
        }
    }
}

#Preview {
    LoginView(onLogin: { })
}
