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
        case utility = "utility"
        case other = "other"

        var displayName: String {
            switch self {
            case .bathroom: return "Bathroom"
            case .kitchen: return "Kitchen"
            case .bedroom: return "Bedroom"
            case .livingRoom: return "Living Room"
            case .utility: return "Utility/Laundry"
            case .other: return "Other"
            }
        }

        var icon: String {
            switch self {
            case .bathroom: return "shower"
            case .kitchen: return "fork.knife"
            case .bedroom: return "bed.double"
            case .livingRoom: return "sofa"
            case .utility: return "washer"
            case .other: return "square.dashed"
            }
        }

        /// Whether this room type typically has windows
        var typicallyHasWindows: Bool {
            switch self {
            case .bathroom, .utility:
                return false  // Often windowless
            case .kitchen, .bedroom, .livingRoom, .other:
                return true
            }
        }

        /// Expected fixture types for this room
        var expectedFixtures: [QuantitySheet.Fixture.FixtureType] {
            switch self {
            case .bathroom:
                return [.toilet, .vanity, .bathtub, .shower, .sink]
            case .kitchen:
                return [.refrigerator, .oven, .dishwasher, .microwave, .sink, .rangeHood]
            case .utility:
                return [.washer, .dryer, .sink]
            default:
                return []
            }
        }

        /// Label for fixtures/appliances in this room type
        var fixtureLabel: String {
            switch self {
            case .bathroom: return "Fixtures"
            case .kitchen, .utility: return "Appliances"
            default: return "Items"
            }
        }
    }
}
