import Foundation

struct DesignSnapshot: Codable, Identifiable {
    let id: String
    let roomCaptureId: String
    let stylePresetId: String
    let cameraAngle: CameraAngle
    let localFilePath: String?
    let serverUrl: String?
    let isUploaded: Bool
    let renderedAt: Date

    enum CameraAngle: String, Codable, CaseIterable {
        case entryCorner = "entry_corner"
        case oppositeCorner = "opposite_corner"
        case vanity = "vanity"
        case showerTub = "shower_tub"

        var displayName: String {
            switch self {
            case .entryCorner: return "Entry View"
            case .oppositeCorner: return "Corner View"
            case .vanity: return "Vanity View"
            case .showerTub: return "Shower/Tub View"
            }
        }
    }
}
