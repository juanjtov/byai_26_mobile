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
            // Bathroom fixtures
            case toilet = "toilet"
            case vanity = "vanity"
            case bathtub = "bathtub"
            case shower = "shower"
            case sink = "sink"

            // Kitchen appliances
            case refrigerator = "refrigerator"
            case oven = "oven"
            case dishwasher = "dishwasher"
            case microwave = "microwave"
            case washer = "washer"
            case dryer = "dryer"
            case rangeHood = "range_hood"

            var displayName: String {
                switch self {
                case .toilet: return "Toilet"
                case .vanity: return "Vanity"
                case .bathtub: return "Bathtub"
                case .shower: return "Shower"
                case .sink: return "Sink"
                case .refrigerator: return "Refrigerator"
                case .oven: return "Oven/Range"
                case .dishwasher: return "Dishwasher"
                case .microwave: return "Microwave"
                case .washer: return "Washer"
                case .dryer: return "Dryer"
                case .rangeHood: return "Range Hood"
                }
            }

            var icon: String {
                switch self {
                case .toilet: return "toilet"
                case .vanity: return "cabinet"
                case .bathtub: return "bathtub"
                case .shower: return "shower"
                case .sink: return "sink"
                case .refrigerator: return "refrigerator"
                case .oven: return "oven"
                case .dishwasher: return "dishwasher"
                case .microwave: return "microwave"
                case .washer: return "washer"
                case .dryer: return "dryer"
                case .rangeHood: return "wind"
                }
            }

            var isKitchenAppliance: Bool {
                switch self {
                case .refrigerator, .oven, .dishwasher, .microwave, .rangeHood:
                    return true
                case .washer, .dryer:
                    return true // Utility room
                default:
                    return false
                }
            }
        }
    }
}
