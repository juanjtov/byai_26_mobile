import Foundation

/// Configuration for quality scoring based on room type and conditions
struct ScanQualityConfiguration {
    let roomType: RoomCapture.RoomType
    let estimatedRoomSize: RoomSize
    var hasConfirmedNoOpenings: Bool = false

    enum RoomSize: String {
        case small      // < 100 sq ft
        case medium     // 100-250 sq ft
        case large      // > 250 sq ft (LiDAR challenged)

        var lidarReliabilityFactor: Double {
            switch self {
            case .small: return 1.0
            case .medium: return 0.9
            case .large: return 0.75  // Reduce expectations for large rooms
            }
        }

        var displayName: String {
            switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
            }
        }
    }

    /// Quality weights for this configuration
    var qualityWeights: QualityWeights {
        var weights = QualityWeights.default

        // Adjust for room type - rooms that typically don't have windows
        if !roomType.typicallyHasWindows || hasConfirmedNoOpenings {
            // Remove openings requirement, redistribute weight
            weights.openingsWeight = 0.0
            weights.perimeterWeight = 0.35
            weights.fixturesWeight = 0.35
            weights.ceilingWeight = 0.30
        }

        return weights
    }

    /// Minimum score needed to finish (adjusted for conditions)
    var minimumQualityScore: Double {
        switch estimatedRoomSize {
        case .small: return 0.70
        case .medium: return 0.65
        case .large: return 0.55  // More lenient for large spaces
        }
    }

    /// Room size thresholds in square feet
    static let smallRoomMaxArea: Double = 100
    static let mediumRoomMaxArea: Double = 250

    /// Determines room size from floor area
    static func roomSize(fromFloorArea area: Double) -> RoomSize {
        if area < smallRoomMaxArea {
            return .small
        } else if area < mediumRoomMaxArea {
            return .medium
        } else {
            return .large
        }
    }
}

struct QualityWeights {
    var perimeterWeight: Double
    var openingsWeight: Double
    var fixturesWeight: Double
    var ceilingWeight: Double

    static let `default` = QualityWeights(
        perimeterWeight: 0.25,
        openingsWeight: 0.25,
        fixturesWeight: 0.25,
        ceilingWeight: 0.25
    )

    var total: Double {
        perimeterWeight + openingsWeight + fixturesWeight + ceilingWeight
    }

    /// Normalize weights to sum to 1.0
    var normalized: QualityWeights {
        let sum = total
        guard sum > 0 else { return self }
        return QualityWeights(
            perimeterWeight: perimeterWeight / sum,
            openingsWeight: openingsWeight / sum,
            fixturesWeight: fixturesWeight / sum,
            ceilingWeight: ceilingWeight / sum
        )
    }
}
