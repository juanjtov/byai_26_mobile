import SwiftUI

/// Remodly-styled card container
struct RemodlyCard<Content: View>: View {
    var padding: CGFloat = RemodlySpacing.lg
    var background: Color = .ivorySubtle
    var hasBorder: Bool = true
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: RemodlyRadius.large)
                    .stroke(hasBorder ? Color.ivoryBorder : Color.clear, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: RemodlyRadius.large))
    }
}

/// Card with dark tungsten background
struct RemodlyCardDark<Content: View>: View {
    var padding: CGFloat = RemodlySpacing.lg
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Color.tungsten)
            .overlay(
                RoundedRectangle(cornerRadius: RemodlyRadius.large)
                    .stroke(Color.ivoryBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: RemodlyRadius.large))
    }
}

/// Section header styled for Remodly
struct RemodlySectionHeader: View {
    let title: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: RemodlySpacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.remodlyTitle2)
                    .foregroundColor(.copper)
            }

            Text(title)
                .font(.remodlyTitle2)
                .foregroundColor(.ivory)

            Spacer()
        }
    }
}

/// Badge component for status indicators
struct RemodlyBadge: View {
    let text: String
    var style: BadgeStyle = .default

    enum BadgeStyle {
        case `default`  // Copper
        case success    // Signal
        case warning    // Gold
        case info       // Sage
    }

    var body: some View {
        Text(text)
            .font(.remodlyCaption)
            .fontWeight(.medium)
            .foregroundColor(textColor)
            .padding(.horizontal, RemodlySpacing.sm)
            .padding(.vertical, RemodlySpacing.xs)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var textColor: Color {
        switch style {
        case .default:
            return .copper
        case .success:
            return .signal
        case .warning:
            return .gold
        case .info:
            return .sage
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default:
            return .copperBadge
        case .success:
            return .signalSubtle
        case .warning:
            return Color.gold.opacity(0.2)
        case .info:
            return Color.sage.opacity(0.2)
        }
    }
}

/// Divider styled for Remodly
struct RemodlyDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.ivoryBorder)
            .frame(height: 1)
    }
}

/// Icon button for navigation and actions
struct RemodlyIconButton: View {
    let icon: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    var color: Color = .copper
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(color.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

// MARK: - Previews

#Preview("Cards") {
    ScrollView {
        VStack(spacing: 20) {
            RemodlyCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Standard Card")
                        .font(.remodlyHeadline)
                        .foregroundColor(.ivory)
                    Text("This is content inside a standard Remodly card.")
                        .font(.remodlyBody)
                        .foregroundColor(.bodyText)
                }
            }

            RemodlyCardDark {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dark Card")
                        .font(.remodlyHeadline)
                        .foregroundColor(.ivory)
                    Text("This card uses tungsten background.")
                        .font(.remodlyBody)
                        .foregroundColor(.bodyText)
                }
            }

            RemodlySectionHeader(title: "Section Title", icon: "ruler")

            RemodlyDivider()

            HStack(spacing: 12) {
                RemodlyBadge(text: "Default")
                RemodlyBadge(text: "Success", style: .success)
                RemodlyBadge(text: "Warning", style: .warning)
                RemodlyBadge(text: "Info", style: .info)
            }

            HStack(spacing: 16) {
                RemodlyIconButton(icon: "pencil", action: {})
                RemodlyIconButton(icon: "trash", color: .coral, action: {})
                RemodlyIconButton(icon: "checkmark", color: .signal, action: {})
            }
        }
        .padding()
    }
    .background(Color.obsidian)
}
