import SwiftUI

extension Color {
    // MARK: - Backgrounds

    /// Primary background - #0F1012
    static let obsidian = Color(hex: "#0F1012")

    /// Surface/cards - #1C1C1E
    static let tungsten = Color(hex: "#1C1C1E")

    /// Borders, dividers, accents - #2C2C2E
    static let surfaceLight = Color(hex: "#2C2C2E")

    // MARK: - Text

    /// Primary text - #FAF8F4
    static let ivory = Color(hex: "#FAF8F4")

    /// Secondary/body text - #B5ADA5
    static let bodyText = Color(hex: "#B5ADA5")

    // MARK: - Accents

    /// Primary accent (buttons, links) - #C88D74
    static let copper = Color(hex: "#C88D74")

    /// Hover/pressed state - #D4A08A
    static let copperHover = Color(hex: "#D4A08A")

    /// Secondary accent - #768A86
    static let sage = Color(hex: "#768A86")

    /// Cool secondary accent - #8B9E7D
    static let sageMuted = Color(hex: "#8B9E7D")

    /// Success, LiDAR glow, active states - #CFFF04
    static let signal = Color(hex: "#CFFF04")

    /// CTA accent - #E8A087
    static let coral = Color(hex: "#E8A087")

    /// Warm gold accent - #D4A84B
    static let gold = Color(hex: "#D4A84B")

    // MARK: - Opacity Variants

    /// Subtle backgrounds - ivory at 5%
    static let ivorySubtle = Color(hex: "#FAF8F4").opacity(0.05)

    /// Borders, dividers - ivory at 10%
    static let ivoryBorder = Color(hex: "#FAF8F4").opacity(0.1)

    /// Placeholder text - ivory at 40%
    static let ivoryPlaceholder = Color(hex: "#FAF8F4").opacity(0.4)

    /// Subtle accent backgrounds - copper at 10%
    static let copperSubtle = Color(hex: "#C88D74").opacity(0.1)

    /// Badge backgrounds - copper at 20%
    static let copperBadge = Color(hex: "#C88D74").opacity(0.2)

    /// Selection highlight - copper at 30%
    static let copperSelection = Color(hex: "#C88D74").opacity(0.3)

    /// Subtle glow - signal at 30%
    static let signalSubtle = Color(hex: "#CFFF04").opacity(0.3)

    /// Strong glow - signal at 60%
    static let signalStrong = Color(hex: "#CFFF04").opacity(0.6)

    // MARK: - Error State

    /// Error background - red at 10%
    static let errorBackground = Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.1)

    /// Error border - red at 50%
    static let errorBorder = Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.5)

    /// Error text - #F87171
    static let errorText = Color(hex: "#F87171")

    // MARK: - Hex Initializer

    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
