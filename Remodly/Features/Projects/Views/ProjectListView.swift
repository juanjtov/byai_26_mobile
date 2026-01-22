import SwiftUI

struct ProjectListView: View {
    @State private var projects: [Project] = []
    @State private var isLoading = false
    @State private var showCreateProject = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading projects...")
                } else if projects.isEmpty {
                    emptyStateView
                } else {
                    projectList
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showCreateProject = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateProject) {
                CreateProjectView()
            }
            .task {
                await loadProjects()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Projects Yet")
                .font(.headline)

            Text("Create your first project to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Create Project") {
                showCreateProject = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var projectList: some View {
        List(projects) { project in
            NavigationLink(destination: ProjectDetailView(project: project)) {
                ProjectRowView(project: project)
            }
        }
        .refreshable {
            await loadProjects()
        }
    }

    private func loadProjects() async {
        isLoading = true
        do {
            projects = try await APIClient.shared.request(endpoint: .projects)
        } catch {
            print("Failed to load projects: \(error)")
            #if DEBUG
            // Use mock data in development when API is unavailable
            projects = Project.mockProjects
            #endif
        }
        isLoading = false
    }
}

struct ProjectRowView: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.name)
                .font(.headline)

            if let address = project.address {
                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                StatusBadge(status: project.status)
                Spacer()
                Text(project.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: Project.ProjectStatus

    var body: some View {
        Text(statusText)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }

    private var statusText: String {
        switch status {
        case .draft: return "Draft"
        case .inProgress: return "In Progress"
        case .pendingReview: return "Pending Review"
        case .completed: return "Completed"
        }
    }

    private var statusColor: Color {
        switch status {
        case .draft: return .gray
        case .inProgress: return .blue
        case .pendingReview: return .orange
        case .completed: return .green
        }
    }
}

#Preview {
    ProjectListView()
}
