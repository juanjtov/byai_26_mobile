import Foundation
import RoomPlan

/// Service for detecting fixtures from RoomPlan captured room data
struct FixtureDetector {

    /// Detects fixtures from a CapturedRoom's objects
    /// - Parameters:
    ///   - room: The captured room from RoomPlan
    ///   - roomType: The type of room being scanned (affects detection context)
    /// - Returns: Array of detected fixtures
    static func detectFixtures(from room: CapturedRoom, roomType: RoomCapture.RoomType = .bathroom) -> [QuantitySheet.Fixture] {
        var fixtureMap: [QuantitySheet.Fixture.FixtureType: Int] = [:]

        for object in room.objects {
            if let fixtureType = mapObjectCategory(object.category, roomType: roomType) {
                fixtureMap[fixtureType, default: 0] += 1
            }
        }

        return fixtureMap.map { type, count in
            QuantitySheet.Fixture(
                id: UUID().uuidString,
                type: type,
                count: count
            )
        }.sorted { $0.type.rawValue < $1.type.rawValue }
    }

    /// Maps RoomPlan object category to our fixture type with room context
    /// - Parameters:
    ///   - category: The RoomPlan object category
    ///   - roomType: The type of room (affects how some categories are interpreted)
    /// - Returns: Corresponding FixtureType or nil if not a fixture
    static func mapObjectCategory(_ category: CapturedRoom.Object.Category, roomType: RoomCapture.RoomType = .bathroom) -> QuantitySheet.Fixture.FixtureType? {
        switch category {
        // Bathroom fixtures
        case .toilet:
            return .toilet
        case .sink:
            return .sink
        case .bathtub:
            return .bathtub

        // Kitchen appliances
        case .refrigerator:
            return .refrigerator
        case .stove:
            return .oven
        case .dishwasher:
            return .dishwasher
        // Note: RoomPlan doesn't have washer/dryer categories
        // Users must add these manually via AddFixturesSheet

        // Context-dependent categories
        case .storage:
            // In bathroom, storage is likely a vanity
            if roomType == .bathroom {
                return .vanity
            }
            return nil

        default:
            return nil
        }
    }

    /// Returns preset fixtures based on room type
    /// - Parameter roomType: The type of room
    /// - Returns: Array of fixture types relevant to that room
    static func presetsForRoomType(_ roomType: RoomCapture.RoomType) -> [QuantitySheet.Fixture.FixtureType] {
        switch roomType {
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

    /// Returns preset fixtures for bathrooms that may not be detected by RoomPlan
    static var bathroomPresets: [QuantitySheet.Fixture.FixtureType] {
        return presetsForRoomType(.bathroom)
    }

    /// Checks if any common fixtures are missing from detection based on room type
    /// - Parameters:
    ///   - detected: Array of fixtures that were detected
    ///   - roomType: The type of room
    /// - Returns: Array of fixture types that might be missing
    static func suggestMissingFixtures(detected: [QuantitySheet.Fixture], roomType: RoomCapture.RoomType = .bathroom) -> [QuantitySheet.Fixture.FixtureType] {
        let detectedTypes = Set(detected.map { $0.type })
        let expectedFixtures: Set<QuantitySheet.Fixture.FixtureType>

        switch roomType {
        case .bathroom:
            expectedFixtures = [.toilet, .vanity, .shower]
        case .kitchen:
            expectedFixtures = [.refrigerator, .oven, .sink]
        case .utility:
            expectedFixtures = [.washer, .dryer]
        default:
            expectedFixtures = []
        }

        return expectedFixtures.subtracting(detectedTypes).sorted { $0.rawValue < $1.rawValue }
    }
}
