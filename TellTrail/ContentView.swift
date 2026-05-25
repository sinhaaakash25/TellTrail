import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    @State private var hasCompletedOnboarding = false
    @State private var isLoggedIn = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else if !isLoggedIn {
                LoginView {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                        isLoggedIn = true
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                RootTabView()
                    .environmentObject(coordinator)
                    .preferredColorScheme(.dark)
                    .task {
                        await AppPermissionManager.shared.requestInitialPermissions()
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
