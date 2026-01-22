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
