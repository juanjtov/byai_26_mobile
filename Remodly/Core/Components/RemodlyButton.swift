import SwiftUI

/// Remodly-styled button component
struct RemodlyButton: View {
    enum Style {
        case primary    // Copper background, dark text
        case secondary  // Transparent with copper border
        case ghost      // Text only
    }

    let title: String
    var style: Style = .primary
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var fullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            HStack(spacing: RemodlySpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.remodlyBody(17, weight: .medium))
                }

                Text(title)
                    .font(.remodlyBody(17, weight: .medium))
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, RemodlySpacing.lg)
            .padding(.vertical, 12)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: RemodlyRadius.medium)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: RemodlyRadius.medium))
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return .obsidian
        case .secondary, .ghost:
            return .copper
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .copper
        case .secondary:
            return .copperSubtle
        case .ghost:
            return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .ghost:
            return .clear
        case .secondary:
            return Color.copper.opacity(0.5)
        }
    }
}

/// Button style for copper glow effect
struct RemodlyButtonGlowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .copperGlow(intensity: configuration.isPressed ? 0.6 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Primary Button") {
    VStack(spacing: 20) {
        RemodlyButton(title: "Continue", action: {})

        RemodlyButton(title: "Continue", icon: "arrow.right", action: {})

        RemodlyButton(title: "Loading...", isLoading: true, action: {})

        RemodlyButton(title: "Disabled", isDisabled: true, action: {})
    }
    .padding()
    .background(Color.obsidian)
}

#Preview("Secondary Button") {
    VStack(spacing: 20) {
        RemodlyButton(title: "Cancel", style: .secondary, action: {})

        RemodlyButton(title: "Edit", style: .secondary, icon: "pencil", action: {})
    }
    .padding()
    .background(Color.obsidian)
}

#Preview("Ghost Button") {
    VStack(spacing: 20) {
        RemodlyButton(title: "Skip", style: .ghost, action: {})

        RemodlyButton(title: "Learn More", style: .ghost, icon: "arrow.up.right", fullWidth: false, action: {})
    }
    .padding()
    .background(Color.obsidian)
}
