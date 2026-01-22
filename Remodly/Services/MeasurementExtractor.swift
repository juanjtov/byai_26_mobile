import Foundation
import RoomPlan
import simd

/// Measurements extracted from a CapturedRoom
struct RoomMeasurements {
    let floorArea: Double           // sq ft
    let wallArea: Double            // sq ft
    let perimeter: Double           // ft
    let ceilingHeight: Double       // ft
    let wallDimensions: [(width: Double, height: Double)]
    let doorDimensions: [(width: Double, height: Double)]
    let windowDimensions: [(width: Double, height: Double)]

    /// Formatted floor area string
    var formattedFloorArea: String {
        String(format: "%.1f sq ft", floorArea)
    }

    /// Formatted wall area string
    var formattedWallArea: String {
        String(format: "%.1f sq ft", wallArea)
    }

    /// Formatted ceiling height string
    var formattedCeilingHeight: String {
        String(format: "%.1f ft", ceilingHeight)
    }

    /// Formatted perimeter string
    var formattedPerimeter: String {
        String(format: "%.1f ft", perimeter)
    }
}

/// Service for extracting measurements from CapturedRoom data
struct MeasurementExtractor {
    /// Meters to feet conversion factor
    private static let metersToFeet: Double = 3.28084

    /// Meters squared to feet squared conversion factor
    private static let metersSquaredToFeetSquared: Double = 10.7639

    /// Extract all measurements from a CapturedRoom
    /// - Parameter room: The captured room from RoomPlan
    /// - Returns: RoomMeasurements containing all extracted dimensions
    static func extract(from room: CapturedRoom) -> RoomMeasurements {
        let wallDims = extractWallDimensions(from: room)
        let doorDims = extractDoorDimensions(from: room)
        let windowDims = extractWindowDimensions(from: room)

        let ceilingHeight = calculateCeilingHeight(from: room)
        let perimeter = calculatePerimeter(from: wallDims)
        let floorArea = calculateFloorArea(from: room)
        let wallArea = calculateWallArea(from: wallDims, doorDims: doorDims, windowDims: windowDims)

        return RoomMeasurements(
            floorArea: floorArea,
            wallArea: wallArea,
            perimeter: perimeter,
            ceilingHeight: ceilingHeight,
            wallDimensions: wallDims,
            doorDimensions: doorDims,
            windowDimensions: windowDims
        )
    }

    /// Extract wall dimensions (width, height) in feet
    private static func extractWallDimensions(from room: CapturedRoom) -> [(width: Double, height: Double)] {
        room.walls.map { wall in
            // CapturedRoom.Surface dimensions are in meters (x=width, y=height, z=depth)
            let widthFeet = Double(wall.dimensions.x) * metersToFeet
            let heightFeet = Double(wall.dimensions.y) * metersToFeet
            return (width: widthFeet, height: heightFeet)
        }
    }

    /// Extract door dimensions (width, height) in feet
    private static func extractDoorDimensions(from room: CapturedRoom) -> [(width: Double, height: Double)] {
        room.doors.map { door in
            let widthFeet = Double(door.dimensions.x) * metersToFeet
            let heightFeet = Double(door.dimensions.y) * metersToFeet
            return (width: widthFeet, height: heightFeet)
        }
    }

    /// Extract window dimensions (width, height) in feet
    private static func extractWindowDimensions(from room: CapturedRoom) -> [(width: Double, height: Double)] {
        room.windows.map { window in
            let widthFeet = Double(window.dimensions.x) * metersToFeet
            let heightFeet = Double(window.dimensions.y) * metersToFeet
            return (width: widthFeet, height: heightFeet)
        }
    }

    /// Calculate ceiling height from wall heights (average of wall heights)
    private static func calculateCeilingHeight(from room: CapturedRoom) -> Double {
        guard !room.walls.isEmpty else { return 0 }

        let totalHeight = room.walls.reduce(0.0) { sum, wall in
            sum + Double(wall.dimensions.y)
        }
        let averageHeightMeters = totalHeight / Double(room.walls.count)
        return averageHeightMeters * metersToFeet
    }

    /// Calculate perimeter from wall widths
    private static func calculatePerimeter(from wallDims: [(width: Double, height: Double)]) -> Double {
        wallDims.reduce(0.0) { sum, dim in
            sum + dim.width
        }
    }

    /// Calculate floor area using wall positions to estimate room polygon
    private static func calculateFloorArea(from room: CapturedRoom) -> Double {
        guard room.walls.count >= 3 else {
            // Fallback: estimate from wall dimensions
            return estimateFloorAreaFromWalls(room.walls)
        }

        // Get wall center positions projected to XZ plane (floor)
        let points = room.walls.map { wall -> simd_float2 in
            let position = wall.transform.columns.3
            return simd_float2(position.x, position.z)
        }

        // Calculate area using shoelace formula
        let areaMeters = calculatePolygonArea(points: points)
        return Double(areaMeters) * metersSquaredToFeetSquared
    }

    /// Estimate floor area when we can't calculate polygon (fallback)
    private static func estimateFloorAreaFromWalls(_ walls: [CapturedRoom.Surface]) -> Double {
        guard walls.count >= 2 else { return 0 }

        // Group walls by orientation and estimate dimensions
        let widths = walls.map { Double($0.dimensions.x) }
        let sortedWidths = widths.sorted(by: >)

        if sortedWidths.count >= 2 {
            // Estimate rectangular room
            let length = sortedWidths[0] * metersToFeet
            let width = sortedWidths[1] * metersToFeet
            return length * width
        }

        return 0
    }

    /// Calculate polygon area using the shoelace formula
    private static func calculatePolygonArea(points: [simd_float2]) -> Float {
        guard points.count >= 3 else { return 0 }

        // Sort points by angle from centroid to create proper polygon order
        let centroid = points.reduce(simd_float2.zero) { $0 + $1 } / Float(points.count)
        let sortedPoints = points.sorted { p1, p2 in
            let angle1 = atan2(p1.y - centroid.y, p1.x - centroid.x)
            let angle2 = atan2(p2.y - centroid.y, p2.x - centroid.x)
            return angle1 < angle2
        }

        // Shoelace formula
        var area: Float = 0
        let n = sortedPoints.count
        for i in 0..<n {
            let j = (i + 1) % n
            area += sortedPoints[i].x * sortedPoints[j].y
            area -= sortedPoints[j].x * sortedPoints[i].y
        }

        return abs(area) / 2
    }

    /// Calculate total wall area minus door and window openings
    private static func calculateWallArea(
        from wallDims: [(width: Double, height: Double)],
        doorDims: [(width: Double, height: Double)],
        windowDims: [(width: Double, height: Double)]
    ) -> Double {
        let grossWallArea = wallDims.reduce(0.0) { sum, dim in
            sum + (dim.width * dim.height)
        }

        let doorArea = doorDims.reduce(0.0) { sum, dim in
            sum + (dim.width * dim.height)
        }

        let windowArea = windowDims.reduce(0.0) { sum, dim in
            sum + (dim.width * dim.height)
        }

        return max(0, grossWallArea - doorArea - windowArea)
    }
}
