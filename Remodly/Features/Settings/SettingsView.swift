import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @ObservedObject var syncService = SyncService.shared

    var body: some View {
        NavigationStack {
            List {
                // User section
                if let user = authService.currentUser {
                    Section("Account") {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)

                        HStack {
                            Text("Role")
                            Spacer()
                            Text(user.role == .admin ? "Admin" : "Project Manager")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Sync status
                Section("Sync Status") {
                    HStack {
                        Image(systemName: syncService.isOnline ? "wifi" : "wifi.slash")
                            .foregroundColor(syncService.isOnline ? .green : .red)
                        Text(syncService.isOnline ? "Online" : "Offline")
                        Spacer()
                        if !syncService.pendingUploads.isEmpty {
                            Text("\(syncService.pendingUploads.count) pending")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    if !syncService.pendingUploads.isEmpty {
                        ForEach(syncService.pendingUploads) { upload in
                            HStack {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundColor(.orange)
                                Text(upload.type == .roomCapture ? "Room Scan" : "Snapshot")
                                Spacer()
                                Text("Pending")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // App settings
                Section("App") {
                    NavigationLink(destination: Text("Notifications")) {
                        Label("Notifications", systemImage: "bell")
                    }

                    NavigationLink(destination: Text("Appearance")) {
                        Label("Appearance", systemImage: "paintbrush")
                    }

                    NavigationLink(destination: Text("Storage")) {
                        Label("Storage & Cache", systemImage: "internaldrive")
                    }
                }

                // Support
                Section("Support") {
                    Link(destination: URL(string: "https://help.remodly.com")!) {
                        Label("Help Center", systemImage: "questionmark.circle")
                    }

                    Link(destination: URL(string: "mailto:support@remodly.com")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }

                    NavigationLink(destination: Text("About")) {
                        Label("About Remodly", systemImage: "info.circle")
                    }
                }

                // Logout
                Section {
                    Button(action: logout) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }

                // Version
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (1)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func logout() {
        authService.logout()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService())
}
