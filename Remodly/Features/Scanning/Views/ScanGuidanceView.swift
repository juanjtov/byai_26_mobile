import SwiftUI

struct ScanGuidanceView: View {
    @ObservedObject var manager: RoomPlanManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scan Checklist")
                .font(.headline)

            ChecklistItem(
                title: "Scan full perimeter",
                isCompleted: manager.hasScannedPerimeter,
                icon: "arrow.triangle.2.circlepath"
            )

            ChecklistItem(
                title: "Capture openings",
                isCompleted: manager.hasScannedOpenings,
                icon: "door.left.hand.open"
            )

            ChecklistItem(
                title: "Capture fixtures",
                isCompleted: manager.hasScannedFixtures,
                icon: "sink"
            )

            ChecklistItem(
                title: "Capture ceiling",
                isCompleted: manager.hasScannedCeiling,
                icon: "rectangle.compress.vertical"
            )

            // Quality score
            HStack {
                Text("Scan Quality:")
                    .font(.subheadline)
                Spacer()
                QualityIndicator(score: manager.qualityScore)
            }
            .padding(.top, 8)
        }
    }
}

struct ChecklistItem: View {
    let title: String
    let isCompleted: Bool
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(isCompleted ? .green : .secondary)

            Text(title)
                .font(.subheadline)

            Spacer()

            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .secondary)
        }
    }
}

struct QualityIndicator: View {
    let score: Double

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index < Int(score * 5) ? qualityColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
            Text(qualityText)
                .font(.caption)
                .foregroundColor(qualityColor)
        }
    }

    private var qualityColor: Color {
        switch score {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .yellow
        default: return .red
        }
    }

    private var qualityText: String {
        switch score {
        case 0.8...1.0: return "Good"
        case 0.6..<0.8: return "Fair"
        default: return "Poor"
        }
    }
}

#Preview {
    ScanGuidanceView(manager: RoomPlanManager())
        .padding()
        .background(Color.gray.opacity(0.2))
}
