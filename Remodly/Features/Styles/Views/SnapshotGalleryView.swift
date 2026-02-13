import SwiftUI
import RoomPlan

struct SnapshotGalleryView: View {
    let style: StylePreset
    let snapshots: [DesignSnapshot]
    let capturedRoom: CapturedRoom
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAngle: DesignSnapshot.CameraAngle = .entryCorner
    @State private var showEstimate = false
    @State private var snapshotImages: [DesignSnapshot.CameraAngle: UIImage] = [:]
    @State private var isSaving = false
    @State private var saveSuccess = false

    let angles = DesignSnapshot.CameraAngle.allCases

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main snapshot view
                ZStack {
                    Color.obsidian

                    if let image = snapshotImages[selectedAngle] {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        VStack(spacing: RemodlySpacing.sm) {
                            ProgressView()
                                .tint(.copper)
                            Text("Loading snapshot...")
                                .font(.remodlySubhead)
                                .foregroundColor(.bodyText)
                        }
                    }

                    // Overlay with angle name and style
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedAngle.displayName)
                                    .font(.remodlySubhead)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.ivory)
                                Text(style.displayName + " Style")
                                    .font(.remodlyCaption)
                                    .foregroundColor(.bodyText)
                            }
                            .padding(.horizontal, RemodlySpacing.sm)
                            .padding(.vertical, RemodlySpacing.xs)
                            .background(.ultraThinMaterial)
                            .cornerRadius(RemodlyRadius.medium)
                            Spacer()
                        }
                        .padding(RemodlySpacing.sm)
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
                                isSelected: selectedAngle == angle,
                                image: snapshotImages[angle]
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
                .background(Color.tungsten)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    RemodlyButton(
                        title: "Generate Estimate",
                        icon: "doc.text"
                    ) {
                        showEstimate = true
                    }

                    HStack(spacing: 12) {
                        RemodlyButton(
                            title: "Share",
                            style: .secondary,
                            icon: "square.and.arrow.up"
                        ) {
                            shareSnapshots()
                        }

                        RemodlyButton(
                            title: isSaving ? "Saving..." : (saveSuccess ? "Saved" : "Save"),
                            style: .secondary,
                            icon: saveSuccess ? "checkmark" : "square.and.arrow.down",
                            isLoading: isSaving
                        ) {
                            saveSnapshots()
                        }
                    }
                }
                .padding()
                .background(Color.obsidian)
            }
            .background(Color.obsidian)
            .navigationTitle("Design Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.obsidian, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.copper)
                }
            }
            .sheet(isPresented: $showEstimate) {
                EstimateView()
            }
            .onAppear {
                loadSnapshotImages()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func loadSnapshotImages() {
        for snapshot in snapshots {
            if let path = snapshot.localFilePath,
               let image = UIImage(contentsOfFile: path) {
                snapshotImages[snapshot.cameraAngle] = image
            }
        }
    }

    private func shareSnapshots() {
        let images = Array(snapshotImages.values)
        guard !images.isEmpty else { return }

        let activityVC = UIActivityViewController(
            activityItems: images,
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var presentingVC = rootVC
            while let presented = presentingVC.presentedViewController {
                presentingVC = presented
            }
            activityVC.popoverPresentationController?.sourceView = presentingVC.view
            presentingVC.present(activityVC, animated: true)
        }
    }

    private func saveSnapshots() {
        isSaving = true
        for (_, image) in snapshotImages {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            saveSuccess = true
        }
    }
}

struct AngleThumbnail: View {
    let angle: DesignSnapshot.CameraAngle
    let style: StylePreset
    let isSelected: Bool
    var image: UIImage?

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: style.palette.primary).opacity(0.8),
                                    Color(hex: style.palette.secondary)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: iconForAngle(angle))
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 80, height: 60)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.copper : Color.clear, lineWidth: 2)
            )

            Text(angle.displayName)
                .font(.caption2)
                .foregroundColor(isSelected ? .copper : .bodyText)
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

// Preview requires CapturedRoom data from a real scan
#Preview {
    Text("SnapshotGalleryView Preview\n(requires CapturedRoom from scan)")
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.obsidian)
}
