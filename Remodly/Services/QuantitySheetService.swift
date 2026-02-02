import Foundation
import RoomPlan

/// Service for creating and managing QuantitySheets from room scans
struct QuantitySheetService {

    // MARK: - Create from Scan

    /// Creates a QuantitySheet from RoomMeasurements and CapturedRoom data
    /// - Parameters:
    ///   - measurements: Extracted measurements from MeasurementExtractor
    ///   - capturedRoom: The captured room from RoomPlan
    ///   - roomCaptureId: ID of the associated RoomCapture
    ///   - roomType: The type of room (affects fixture detection)
    /// - Returns: A new QuantitySheet populated with the scan data
    static func createFromScan(
        measurements: RoomMeasurements,
        capturedRoom: CapturedRoom,
        roomCaptureId: String,
        roomType: RoomCapture.RoomType = .bathroom
    ) -> QuantitySheet {
        // Convert door dimensions from feet to inches
        let doorSizes = measurements.doorDimensions.map { dim in
            QuantitySheet.DoorSize(
                width: dim.width * 12,  // feet to inches
                height: dim.height * 12
            )
        }

        // Convert window dimensions from feet to inches
        let windowSizes = measurements.windowDimensions.map { dim in
            QuantitySheet.WindowSize(
                width: dim.width * 12,  // feet to inches
                height: dim.height * 12
            )
        }

        // Detect fixtures from captured room objects with room type context
        let fixtures = FixtureDetector.detectFixtures(from: capturedRoom, roomType: roomType)

        let now = Date()

        return QuantitySheet(
            id: UUID().uuidString,
            roomCaptureId: roomCaptureId,
            version: 1,
            floorArea: measurements.floorArea,
            wallArea: measurements.wallArea,
            perimeterLength: measurements.perimeter,
            ceilingHeight: measurements.ceilingHeight,
            doorCount: doorSizes.count,
            doorSizes: doorSizes,
            windowCount: windowSizes.count,
            windowSizes: windowSizes,
            fixtures: fixtures,
            isLocked: false,
            createdAt: now,
            updatedAt: now
        )
    }

    // MARK: - Lock for Pricing

    /// Creates a locked version of the QuantitySheet for pricing
    /// - Parameter sheet: The QuantitySheet to lock
    /// - Returns: A new locked QuantitySheet with the same data
    static func lockForPricing(_ sheet: QuantitySheet) -> QuantitySheet {
        return QuantitySheet(
            id: sheet.id,
            roomCaptureId: sheet.roomCaptureId,
            version: sheet.version,
            floorArea: sheet.floorArea,
            wallArea: sheet.wallArea,
            perimeterLength: sheet.perimeterLength,
            ceilingHeight: sheet.ceilingHeight,
            doorCount: sheet.doorCount,
            doorSizes: sheet.doorSizes,
            windowCount: sheet.windowCount,
            windowSizes: sheet.windowSizes,
            fixtures: sheet.fixtures,
            isLocked: true,
            createdAt: sheet.createdAt,
            updatedAt: Date()
        )
    }

    // MARK: - Create New Version

    /// Creates a new version of the QuantitySheet for editing after being locked
    /// - Parameter sheet: The locked QuantitySheet to create a new version from
    /// - Returns: A new unlocked QuantitySheet with incremented version
    static func createNewVersion(from sheet: QuantitySheet) -> QuantitySheet {
        return QuantitySheet(
            id: UUID().uuidString,
            roomCaptureId: sheet.roomCaptureId,
            version: sheet.version + 1,
            floorArea: sheet.floorArea,
            wallArea: sheet.wallArea,
            perimeterLength: sheet.perimeterLength,
            ceilingHeight: sheet.ceilingHeight,
            doorCount: sheet.doorCount,
            doorSizes: sheet.doorSizes,
            windowCount: sheet.windowCount,
            windowSizes: sheet.windowSizes,
            fixtures: sheet.fixtures,
            isLocked: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    // MARK: - Add Fixture

    /// Adds a fixture to the QuantitySheet
    /// - Parameters:
    ///   - sheet: The QuantitySheet to modify
    ///   - fixtureType: The type of fixture to add
    ///   - count: The number of fixtures (default 1)
    /// - Returns: Updated QuantitySheet with the new fixture
    static func addFixture(to sheet: QuantitySheet, type fixtureType: QuantitySheet.Fixture.FixtureType, count: Int = 1) -> QuantitySheet {
        var updatedFixtures = sheet.fixtures

        // Check if fixture type already exists
        if let existingIndex = updatedFixtures.firstIndex(where: { $0.type == fixtureType }) {
            // Update count
            var existingFixture = updatedFixtures[existingIndex]
            existingFixture = QuantitySheet.Fixture(
                id: existingFixture.id,
                type: existingFixture.type,
                count: existingFixture.count + count
            )
            updatedFixtures[existingIndex] = existingFixture
        } else {
            // Add new fixture
            let newFixture = QuantitySheet.Fixture(
                id: UUID().uuidString,
                type: fixtureType,
                count: count
            )
            updatedFixtures.append(newFixture)
        }

        return QuantitySheet(
            id: sheet.id,
            roomCaptureId: sheet.roomCaptureId,
            version: sheet.version,
            floorArea: sheet.floorArea,
            wallArea: sheet.wallArea,
            perimeterLength: sheet.perimeterLength,
            ceilingHeight: sheet.ceilingHeight,
            doorCount: sheet.doorCount,
            doorSizes: sheet.doorSizes,
            windowCount: sheet.windowCount,
            windowSizes: sheet.windowSizes,
            fixtures: updatedFixtures,
            isLocked: sheet.isLocked,
            createdAt: sheet.createdAt,
            updatedAt: Date()
        )
    }

    // MARK: - Remove Fixture

    /// Removes a fixture from the QuantitySheet
    /// - Parameters:
    ///   - sheet: The QuantitySheet to modify
    ///   - fixtureId: The ID of the fixture to remove
    /// - Returns: Updated QuantitySheet without the fixture
    static func removeFixture(from sheet: QuantitySheet, fixtureId: String) -> QuantitySheet {
        let updatedFixtures = sheet.fixtures.filter { $0.id != fixtureId }

        return QuantitySheet(
            id: sheet.id,
            roomCaptureId: sheet.roomCaptureId,
            version: sheet.version,
            floorArea: sheet.floorArea,
            wallArea: sheet.wallArea,
            perimeterLength: sheet.perimeterLength,
            ceilingHeight: sheet.ceilingHeight,
            doorCount: sheet.doorCount,
            doorSizes: sheet.doorSizes,
            windowCount: sheet.windowCount,
            windowSizes: sheet.windowSizes,
            fixtures: updatedFixtures,
            isLocked: sheet.isLocked,
            createdAt: sheet.createdAt,
            updatedAt: Date()
        )
    }
}
