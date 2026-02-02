import Foundation

enum APIEndpoint: Sendable {
    // Auth
    case login
    case logout
    case me

    // Projects
    case projects
    case project(id: String)
    case createProject

    // Site Visits
    case siteVisits(projectId: String)
    case createSiteVisit(projectId: String)

    // Room Captures
    case roomCaptureUploadURL(visitId: String)
    case roomCaptureComplete(visitId: String)
    case roomCapture(id: String)

    // Quantity Sheets
    case createQuantitySheet(captureId: String)
    case quantitySheet(id: String)
    case updateQuantitySheet(id: String)

    // Style Presets
    case stylePresets(roomType: String)

    // Estimates
    case createEstimate
    case estimate(id: String)
    case estimateVersions(id: String)
    case estimatePDF(id: String)
    case estimateShare(id: String)

    // Allowances
    case allowanceBands(region: String, roomType: String, tier: String)

    nonisolated var path: String {
        switch self {
        // Auth
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .me:
            return "/auth/me"

        // Projects
        case .projects:
            return "/projects"
        case .project(let id):
            return "/projects/\(id)"
        case .createProject:
            return "/projects"

        // Site Visits
        case .siteVisits(let projectId):
            return "/projects/\(projectId)/site-visits"
        case .createSiteVisit(let projectId):
            return "/projects/\(projectId)/site-visits"

        // Room Captures
        case .roomCaptureUploadURL(let visitId):
            return "/site-visits/\(visitId)/room-captures/upload-url"
        case .roomCaptureComplete(let visitId):
            return "/site-visits/\(visitId)/room-captures/complete"
        case .roomCapture(let id):
            return "/room-captures/\(id)"

        // Quantity Sheets
        case .createQuantitySheet(let captureId):
            return "/room-captures/\(captureId)/quantity-sheets"
        case .quantitySheet(let id):
            return "/quantity-sheets/\(id)"
        case .updateQuantitySheet(let id):
            return "/quantity-sheets/\(id)"

        // Style Presets
        case .stylePresets(let roomType):
            return "/style-presets?room_type=\(roomType)"

        // Estimates
        case .createEstimate:
            return "/estimates"
        case .estimate(let id):
            return "/estimates/\(id)"
        case .estimateVersions(let id):
            return "/estimates/\(id)/versions"
        case .estimatePDF(let id):
            return "/estimates/\(id)/pdf"
        case .estimateShare(let id):
            return "/estimates/\(id)/share"

        // Allowances
        case .allowanceBands(let region, let roomType, let tier):
            return "/allowances/bands?region=\(region)&room_type=\(roomType)&tier=\(tier)"
        }
    }
}
