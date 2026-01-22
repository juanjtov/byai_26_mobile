import Foundation

struct Project: Codable, Identifiable {
    let id: String
    let organizationId: String
    let name: String
    let address: String?
    let homeownerName: String?
    let homeownerEmail: String?
    let homeownerPhone: String?
    let notes: String?
    let status: ProjectStatus
    let createdAt: Date
    let updatedAt: Date

    enum ProjectStatus: String, Codable {
        case draft = "draft"
        case inProgress = "in_progress"
        case pendingReview = "pending_review"
        case completed = "completed"
    }
}

#if DEBUG
extension Project {
    static var mockProjects: [Project] {
        [
            Project(
                id: "mock-1",
                organizationId: "org-1",
                name: "Kitchen Renovation",
                address: "123 Main St, Austin TX",
                homeownerName: "John Smith",
                homeownerEmail: "john@example.com",
                homeownerPhone: "512-555-0123",
                notes: "Demo project for development",
                status: .inProgress,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Project(
                id: "mock-2",
                organizationId: "org-1",
                name: "Bathroom Remodel",
                address: "456 Oak Ave, Austin TX",
                homeownerName: "Jane Doe",
                homeownerEmail: nil,
                homeownerPhone: nil,
                notes: nil,
                status: .draft,
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date().addingTimeInterval(-86400)
            ),
            Project(
                id: "mock-3",
                organizationId: "org-1",
                name: "Living Room Update",
                address: "789 Pine Blvd, Austin TX",
                homeownerName: "Bob Wilson",
                homeownerEmail: "bob@example.com",
                homeownerPhone: "512-555-0456",
                notes: "Flooring and paint",
                status: .completed,
                createdAt: Date().addingTimeInterval(-172800),
                updatedAt: Date().addingTimeInterval(-3600)
            )
        ]
    }
}
#endif
