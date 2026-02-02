import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
        // Configure tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.tungsten)

        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.copper)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.copper)
        ]

        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.bodyText)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.bodyText)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ProjectListView()
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
                .tag(0)

            ScanningView()
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .tint(.copper)
    }
}

#Preview {
    MainTabView()
}
