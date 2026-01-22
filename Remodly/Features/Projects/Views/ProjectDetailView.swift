import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @State private var showScanning = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Project Info
                projectInfoSection

                Divider()

                // Room Captures
                roomCapturesSection

                Divider()

                // Estimates
                estimatesSection
            }
            .padding()
        }
        .navigationTitle(project.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showScanning = true }) {
                        Label("New Scan", systemImage: "camera.viewfinder")
                    }
                    Button(action: {}) {
                        Label("Edit Project", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .fullScreenCover(isPresented: $showScanning) {
            ScanningView()
        }
    }

    private var projectInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Details")
                .font(.headline)

            if let address = project.address {
                InfoRow(label: "Address", value: address)
            }

            if let homeowner = project.homeownerName {
                InfoRow(label: "Homeowner", value: homeowner)
            }

            if let phone = project.homeownerPhone {
                InfoRow(label: "Phone", value: phone)
            }

            if let notes = project.notes {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(notes)
                        .font(.body)
                }
            }
        }
    }

    private var roomCapturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Room Scans")
                    .font(.headline)
                Spacer()
                Button("Add Scan") {
                    showScanning = true
                }
                .font(.caption)
            }

            // Placeholder for room captures list
            Text("No scans yet")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }

    private var estimatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estimates")
                .font(.headline)

            // Placeholder for estimates list
            Text("No estimates yet")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.body)
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: Project(
            id: "1",
            organizationId: "org1",
            name: "Smith Bathroom Remodel",
            address: "123 Main St, City, ST 12345",
            homeownerName: "John Smith",
            homeownerEmail: "john@example.com",
            homeownerPhone: "(555) 123-4567",
            notes: "Master bathroom on second floor",
            status: .inProgress,
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
