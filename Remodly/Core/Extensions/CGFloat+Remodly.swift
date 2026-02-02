import Foundation

extension CGFloat {
    // MARK: - Border Radius

    /// Small elements, badges, tags - 4pt
    static let radiusSmall: CGFloat = 4

    /// Buttons, inputs, small cards - 8pt
    static let radiusMedium: CGFloat = 8

    /// Cards, containers, modals - 12pt
    static let radiusLarge: CGFloat = 12

    /// Avatars, pills, circular buttons - 9999pt
    static let radiusFull: CGFloat = 9999

    // MARK: - Spacing

    /// Extra small - 4pt
    static let spacingXS: CGFloat = 4

    /// Small - 8pt
    static let spacingSM: CGFloat = 8

    /// Medium - 16pt
    static let spacingMD: CGFloat = 16

    /// Large - 24pt
    static let spacingLG: CGFloat = 24

    /// Extra large - 32pt
    static let spacingXL: CGFloat = 32

    /// Extra extra large - 48pt
    static let spacingXXL: CGFloat = 48
}

// MARK: - Remodly Design Tokens

enum RemodlySpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum RemodlyRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let full: CGFloat = 9999
}
