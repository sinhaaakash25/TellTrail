import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        RootTabView()
            .environmentObject(coordinator)
            .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
