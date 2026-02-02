import SwiftUI

struct StyleSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStyle: StylePreset?
    @State private var isRendering = false
    @State private var showSnapshots = false

    let styles = StylePreset.allPresets

    var body: some View {
        NavigationStack {
            ZStack {
                Color.obsidian
                    .ignoresSafeArea()

                VStack(spacing: RemodlySpacing.lg) {
                    // Header
                    VStack(spacing: RemodlySpacing.sm) {
                        Text("Choose a Style")
                            .font(.remodlyTitle1)
                            .foregroundColor(.ivory)

                        Text("Select a design direction for your remodel")
                            .font(.remodlySubhead)
                            .foregroundColor(.bodyText)
                    }

                    // Style cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: RemodlySpacing.md) {
                            ForEach(styles) { style in
                                StyleCard(
                                    style: style,
                                    isSelected: selectedStyle?.id == style.id
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedStyle = style
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()

                    // Selected style details
                    if let style = selectedStyle {
                        RemodlyCard {
                            VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                                Text(style.displayName)
                                    .font(.remodlyHeadline)
                                    .foregroundColor(.ivory)

                                Text(style.description)
                                    .font(.remodlySubhead)
                                    .foregroundColor(.bodyText)

                                // Color palette preview
                                HStack(spacing: RemodlySpacing.sm) {
                                    ColorSwatch(hex: style.palette.primary, label: "Primary")
                                    ColorSwatch(hex: style.palette.secondary, label: "Secondary")
                                    ColorSwatch(hex: style.palette.accent, label: "Accent")
                                    ColorSwatch(hex: style.palette.neutral, label: "Neutral")
                                }
                                .padding(.top, RemodlySpacing.sm)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Render button
                    RemodlyButton(
                        title: isRendering ? "Rendering..." : "Generate Snapshots",
                        icon: "camera.aperture",
                        isLoading: isRendering,
                        isDisabled: selectedStyle == nil
                    ) {
                        renderSnapshots()
                    }
                    .copperGlow(intensity: selectedStyle != nil ? 0.4 : 0)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Style Selection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.obsidian, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.copper)
                }
            }
            .sheet(isPresented: $showSnapshots) {
                if let style = selectedStyle {
                    SnapshotGalleryView(style: style)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func renderSnapshots() {
        guard selectedStyle != nil else { return }

        isRendering = true

        // Simulate rendering time
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isRendering = false
            showSnapshots = true
        }
    }
}

struct StyleCard: View {
    let style: StylePreset
    let isSelected: Bool

    var body: some View {
        VStack(spacing: RemodlySpacing.sm) {
            // Style preview image placeholder
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: style.palette.primary),
                        Color(hex: style.palette.secondary)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "photo.artframe")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(width: 160, height: 120)
            .cornerRadius(RemodlyRadius.large)

            Text(style.displayName)
                .font(.remodlyHeadline)
                .foregroundColor(.ivory)

            Text(style.description)
                .font(.remodlyCaption)
                .foregroundColor(.bodyText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 180)
        .padding()
        .background(isSelected ? Color.copperSubtle : Color.ivorySubtle)
        .cornerRadius(RemodlyRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: RemodlyRadius.large)
                .stroke(isSelected ? Color.copper : Color.clear, lineWidth: 2)
        )
        .copperGlow(intensity: isSelected ? 0.3 : 0)
    }
}

struct ColorSwatch: View {
    let hex: String
    let label: String

    var body: some View {
        VStack(spacing: RemodlySpacing.xs) {
            Circle()
                .fill(Color(hex: hex))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.ivoryBorder, lineWidth: 1)
                )

            Text(label)
                .font(.remodlyCaption)
                .foregroundColor(.bodyText)
        }
    }
}

#Preview {
    StyleSelectionView()
}
