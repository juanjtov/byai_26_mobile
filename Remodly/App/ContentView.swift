import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService

    // Set to true to bypass login during development
    private let skipLoginForTesting = true

    var body: some View {
        Group {
            if skipLoginForTesting || authService.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
