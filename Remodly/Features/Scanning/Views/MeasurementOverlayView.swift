import SwiftUI

/// SwiftUI overlay showing key room measurements
struct MeasurementOverlayView: View {
    let measurements: RoomMeasurements

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Room Measurements")
                .font(.headline)

            // Primary measurements grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MeasurementCard(
                    icon: "square.dashed",
                    label: "Floor Area",
                    value: measurements.formattedFloorArea
                )

                MeasurementCard(
                    icon: "rectangle.portrait",
                    label: "Wall Area",
                    value: measurements.formattedWallArea
                )

                MeasurementCard(
                    icon: "arrow.up.and.down",
                    label: "Ceiling Height",
                    value: measurements.formattedCeilingHeight
                )

                MeasurementCard(
                    icon: "arrow.triangle.2.circlepath",
                    label: "Perimeter",
                    value: measurements.formattedPerimeter
                )
            }

            // Openings summary
            if !measurements.doorDimensions.isEmpty || !measurements.windowDimensions.isEmpty {
                Divider()

                Text("Openings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 16) {
                    if !measurements.doorDimensions.isEmpty {
                        OpeningSummary(
                            icon: "door.left.hand.open",
                            iconColor: .orange,
                            label: "Doors",
                            count: measurements.doorDimensions.count,
                            dimensions: measurements.doorDimensions
                        )
                    }

                    if !measurements.windowDimensions.isEmpty {
                        OpeningSummary(
                            icon: "window.horizontal",
                            iconColor: .cyan,
                            label: "Windows",
                            count: measurements.windowDimensions.count,
                            dimensions: measurements.windowDimensions
                        )
                    }
                }
            }

            // Wall details (collapsible)
            if !measurements.wallDimensions.isEmpty {
                Divider()

                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(measurements.wallDimensions.enumerated()), id: \.offset) { index, dim in
                            HStack {
                                Text("Wall \(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "%.1f' x %.1f'", dim.width, dim.height))
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    HStack {
                        Image(systemName: "rectangle.split.3x3")
                            .foregroundColor(.blue)
                        Text("Wall Details (\(measurements.wallDimensions.count) walls)")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// Card displaying a single measurement
struct MeasurementCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Summary of door/window openings
struct OpeningSummary: View {
    let icon: String
    let iconColor: Color
    let label: String
    let count: Int
    let dimensions: [(width: Double, height: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text("\(count) \(label)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            // Show first few dimensions
            ForEach(Array(dimensions.prefix(3).enumerated()), id: \.offset) { index, dim in
                Text(String(format: "%.1f' x %.1f'", dim.width, dim.height))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if dimensions.count > 3 {
                Text("+ \(dimensions.count - 3) more")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    MeasurementOverlayView(
        measurements: RoomMeasurements(
            floorArea: 150.5,
            wallArea: 420.0,
            perimeter: 50.0,
            ceilingHeight: 9.0,
            wallDimensions: [
                (width: 12.5, height: 9.0),
                (width: 10.0, height: 9.0),
                (width: 12.5, height: 9.0),
                (width: 10.0, height: 9.0)
            ],
            doorDimensions: [
                (width: 3.0, height: 7.0),
                (width: 2.5, height: 7.0)
            ],
            windowDimensions: [
                (width: 4.0, height: 3.5),
                (width: 3.0, height: 3.5)
            ]
        )
    )
    .padding()
}
