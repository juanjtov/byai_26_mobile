import SwiftUI

/// Guidance overlay for scanning large rooms (>250 sq ft)
struct LargeRoomGuidanceView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: RemodlySpacing.lg) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.gold)
                    .font(.system(size: 24))

                Text("Large Room Detected")
                    .font(.remodlyHeadline)
                    .foregroundColor(.ivory)

                Spacer()
            }

            // Tips
            VStack(alignment: .leading, spacing: RemodlySpacing.md) {
                GuidanceTip(
                    icon: "ruler",
                    text: "LiDAR works best within 5 meters (16 feet)"
                )

                GuidanceTip(
                    icon: "figure.walk",
                    text: "Walk closer to distant walls for better accuracy"
                )

                GuidanceTip(
                    icon: "arrow.clockwise",
                    text: "Move slowly and scan each wall section thoroughly"
                )

                GuidanceTip(
                    icon: "checkmark.circle",
                    text: "Quality requirements are relaxed for large spaces"
                )
            }

            // Dismiss button
            RemodlyButton(title: "Got It", icon: "checkmark") {
                onDismiss()
            }
        }
        .padding(RemodlySpacing.lg)
        .background(Color.tungsten)
        .cornerRadius(RemodlyRadius.large)
        .shadow(color: .black.opacity(0.3), radius: 10)
    }
}

struct GuidanceTip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: RemodlySpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(.signal)
                .frame(width: 24)

            Text(text)
                .font(.remodlySubhead)
                .foregroundColor(.bodyText)
        }
    }
}

#Preview {
    ZStack {
        Color.obsidian.ignoresSafeArea()

        LargeRoomGuidanceView {
            print("Dismissed")
        }
        .padding()
    }
}
