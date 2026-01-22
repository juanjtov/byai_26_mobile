import SwiftUI

struct SnapshotGalleryView: View {
    let style: StylePreset
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAngle: DesignSnapshot.CameraAngle = .entryCorner
    @State private var showEstimate = false

    let angles = DesignSnapshot.CameraAngle.allCases

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main snapshot view
                ZStack {
                    // Placeholder for actual rendered snapshot
                    LinearGradient(
                        colors: [
                            Color(hex: style.palette.primary) ?? .gray,
                            Color(hex: style.palette.secondary) ?? .white
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack {
                        Image(systemName: "cube.transparent.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.3))

                        Text(selectedAngle.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(style.displayName + " Style")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 400)

                // Camera angle selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(angles, id: \.self) { angle in
                            AngleThumbnail(
                                angle: angle,
                                style: style,
                                isSelected: selectedAngle == angle
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedAngle = angle
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.1))

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: { showEstimate = true }) {
                        Text("Generate Estimate")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    HStack(spacing: 12) {
                        Button(action: shareSnapshots) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button(action: saveSnapshots) {
                            Label("Save", systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("Design Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showEstimate) {
                EstimateView()
            }
        }
    }

    private func shareSnapshots() {
        // Implement share functionality
    }

    private func saveSnapshots() {
        // Implement save to photos functionality
    }
}

struct AngleThumbnail: View {
    let angle: DesignSnapshot.CameraAngle
    let style: StylePreset
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: style.palette.primary)?.opacity(0.8) ?? .gray,
                                Color(hex: style.palette.secondary) ?? .white
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: iconForAngle(angle))
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 60)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )

            Text(angle.displayName)
                .font(.caption2)
                .foregroundColor(isSelected ? .blue : .secondary)
        }
    }

    private func iconForAngle(_ angle: DesignSnapshot.CameraAngle) -> String {
        switch angle {
        case .entryCorner: return "door.left.hand.open"
        case .oppositeCorner: return "arrow.up.left.and.arrow.down.right"
        case .vanity: return "sink"
        case .showerTub: return "bathtub"
        }
    }
}

#Preview {
    SnapshotGalleryView(style: .sophisticated)
}
