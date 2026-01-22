import Foundation

struct QuantitySheet: Codable, Identifiable {
    let id: String
    let roomCaptureId: String
    let version: Int
    var floorArea: Double          // square feet
    var wallArea: Double           // square feet
    var perimeterLength: Double    // linear feet
    var ceilingHeight: Double      // feet
    var doorCount: Int
    var doorSizes: [DoorSize]
    var windowCount: Int
    var windowSizes: [WindowSize]
    var fixtures: [Fixture]
    let isLocked: Bool
    let createdAt: Date
    let updatedAt: Date

    struct DoorSize: Codable {
        var width: Double  // inches
        var height: Double // inches
    }

    struct WindowSize: Codable {
        var width: Double  // inches
        var height: Double // inches
    }

    struct Fixture: Codable, Identifiable {
        let id: String
        var type: FixtureType
        var count: Int

        enum FixtureType: String, Codable, CaseIterable {
            case toilet = "toilet"
            case vanity = "vanity"
            case bathtub = "bathtub"
            case shower = "shower"
            case sink = "sink"

            var displayName: String {
                switch self {
                case .toilet: return "Toilet"
                case .vanity: return "Vanity"
                case .bathtub: return "Bathtub"
                case .shower: return "Shower"
                case .sink: return "Sink"
                }
            }
        }
    }
}
