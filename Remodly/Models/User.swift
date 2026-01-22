import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let organizationId: String
    let role: UserRole

    enum UserRole: String, Codable {
        case admin = "admin"
        case projectManager = "project_manager"
    }
}
