import Foundation

struct Estimate: Codable, Identifiable {
    let id: String
    let projectId: String
    let roomCaptureId: String
    let quantitySheetId: String
    let stylePresetId: String
    let version: Int
    let sections: [EstimateSection]
    let laborTotal: Double
    let materialsTotal: Double
    let finishAllowanceLow: Double
    let finishAllowanceHigh: Double
    let grandTotal: Double
    let assumptions: [String]
    let exclusions: [String]
    let pdfUrl: String?
    let shareToken: String?
    let shareUrl: String?
    let createdAt: Date
    let updatedAt: Date
}

struct EstimateSection: Codable, Identifiable {
    let id: String
    let name: String
    let lineItems: [EstimateLineItem]
    let subtotal: Double
}

struct EstimateLineItem: Codable, Identifiable {
    let id: String
    let description: String
    let quantity: Double
    let unit: String
    let unitPrice: Double
    let total: Double
    let category: LineItemCategory

    enum LineItemCategory: String, Codable {
        case labor = "labor"
        case material = "material"
        case allowance = "allowance"
    }
}
