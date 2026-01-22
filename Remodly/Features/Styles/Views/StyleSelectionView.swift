import SwiftUI

struct StyleSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStyle: StylePreset?
    @State private var isRendering = false
    @State private var showSnapshots = false

    let styles = StylePreset.allPresets

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Choose a Style")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Select a design direction for your remodel")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Style cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(styles) { style in
                            StyleCard(
                                style: style,
                                isSelected: selectedStyle?.id == style.id
                            )
                            .onTapGesture {
                                withAnimation {
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(style.displayName)
                            .font(.headline)
                        Text(style.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        // Color palette preview
                        HStack(spacing: 8) {
                            ColorSwatch(hex: style.palette.primary, label: "Primary")
                            ColorSwatch(hex: style.palette.secondary, label: "Secondary")
                            ColorSwatch(hex: style.palette.accent, label: "Accent")
                            ColorSwatch(hex: style.palette.neutral, label: "Neutral")
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Render button
                Button(action: renderSnapshots) {
                    if isRendering {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Rendering...")
                        }
                    } else {
                        Text("Generate Snapshots")
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .disabled(selectedStyle == nil || isRendering)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Style Selection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSnapshots) {
                if let style = selectedStyle {
                    SnapshotGalleryView(style: style)
                }
            }
        }
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
        VStack(spacing: 12) {
            // Style preview image placeholder
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: style.palette.primary) ?? .gray,
                        Color(hex: style.palette.secondary) ?? .white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "photo.artframe")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(width: 160, height: 120)
            .cornerRadius(12)

            Text(style.displayName)
                .font(.headline)

            Text(style.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 180)
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct ColorSwatch: View {
    let hex: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color(hex: hex) ?? .gray)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// Color extension for hex support
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

#Preview {
    StyleSelectionView()
}
