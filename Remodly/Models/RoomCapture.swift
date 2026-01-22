import Foundation

struct RoomCapture: Codable, Identifiable {
    let id: String
    let projectId: String
    let siteVisitId: String
    let roomType: RoomType
    let qualityScore: Double
    let capturedAt: Date
    let localFilePath: String?
    let uploadedAt: Date?
    let serverUrl: String?

    enum RoomType: String, Codable, CaseIterable {
        case bathroom = "bathroom"
        case kitchen = "kitchen"
        case bedroom = "bedroom"
        case livingRoom = "living_room"
        case other = "other"

        var displayName: String {
            switch self {
            case .bathroom: return "Bathroom"
            case .kitchen: return "Kitchen"
            case .bedroom: return "Bedroom"
            case .livingRoom: return "Living Room"
            case .other: return "Other"
            }
        }
    }
}
