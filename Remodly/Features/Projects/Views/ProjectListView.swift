import SwiftUI

struct ProjectListView: View {
    @State private var projects: [Project] = []
    @State private var isLoading = false
    @State private var showCreateProject = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.obsidian
                    .ignoresSafeArea()

                Group {
                    if isLoading {
                        VStack(spacing: RemodlySpacing.md) {
                            ProgressView()
                                .tint(.copper)
                            Text("Loading projects...")
                                .font(.remodlySubhead)
                                .foregroundColor(.bodyText)
                        }
                    } else if projects.isEmpty {
                        emptyStateView
                    } else {
                        projectList
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbarBackground(Color.obsidian, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showCreateProject = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.copper)
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
        .preferredColorScheme(.dark)
    }

    private var emptyStateView: some View {
        VStack(spacing: RemodlySpacing.md) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.copper)
                .copperGlow(intensity: 0.3)

            Text("No Projects Yet")
                .font(.remodlyTitle2)
                .foregroundColor(.ivory)

            Text("Create your first project to get started")
                .font(.remodlySubhead)
                .foregroundColor(.bodyText)

            RemodlyButton(
                title: "Create Project",
                icon: "plus",
                fullWidth: false
            ) {
                showCreateProject = true
            }
        }
        .padding()
    }

    private var projectList: some View {
        ScrollView {
            LazyVStack(spacing: RemodlySpacing.sm) {
                ForEach(projects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        ProjectRowView(project: project)
                    }
                }
            }
            .padding()
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
        RemodlyCard {
            VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                Text(project.name)
                    .font(.remodlyHeadline)
                    .foregroundColor(.ivory)

                if let address = project.address {
                    HStack(spacing: RemodlySpacing.xs) {
                        Image(systemName: "location")
                            .font(.remodlyCaption)
                        Text(address)
                            .font(.remodlySubhead)
                    }
                    .foregroundColor(.bodyText)
                }

                HStack {
                    StatusBadge(status: project.status)
                    Spacer()
                    Text(project.updatedAt, style: .date)
                        .font(.remodlyCaption)
                        .foregroundColor(.bodyText)
                }
            }
        }
    }
}

struct StatusBadge: View {
    let status: Project.ProjectStatus

    var body: some View {
        Text(statusText)
            .font(.remodlyCaption)
            .fontWeight(.medium)
            .padding(.horizontal, RemodlySpacing.sm)
            .padding(.vertical, RemodlySpacing.xs)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(RemodlyRadius.small)
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
        case .draft: return .bodyText
        case .inProgress: return .copper
        case .pendingReview: return .gold
        case .completed: return .signal
        }
    }
}

#Preview {
    ProjectListView()
}
