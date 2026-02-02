import SwiftUI

extension Font {
    // MARK: - Display Fonts (Cormorant Garamond)

    /// Large Title - 34pt SemiBold
    static let remodlyLargeTitle = Font.custom("CormorantGaramond-SemiBold", size: 34)

    /// Title 1 - 28pt SemiBold
    static let remodlyTitle1 = Font.custom("CormorantGaramond-SemiBold", size: 28)

    /// Title 2 - 22pt Medium
    static let remodlyTitle2 = Font.custom("CormorantGaramond-Medium", size: 22)

    // MARK: - Body Fonts (DM Sans)

    /// Title 3 - 20pt Medium
    static let remodlyTitle3 = Font.custom("DMSans-Medium", size: 20)

    /// Headline - 17pt SemiBold
    static let remodlyHeadline = Font.custom("DMSans-SemiBold", size: 17)

    /// Body - 17pt Regular
    static let remodlyBody = Font.custom("DMSans-Regular", size: 17)

    /// Callout - 16pt Regular
    static let remodlyCallout = Font.custom("DMSans-Regular", size: 16)

    /// Subhead - 15pt Regular
    static let remodlySubhead = Font.custom("DMSans-Regular", size: 15)

    /// Footnote - 13pt Regular
    static let remodlyFootnote = Font.custom("DMSans-Regular", size: 13)

    /// Caption - 12pt Regular
    static let remodlyCaption = Font.custom("DMSans-Regular", size: 12)

    // MARK: - Dynamic Font Builders

    /// Display font with custom size and weight
    static func remodlyDisplay(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        let fontName: String
        switch weight {
        case .regular:
            fontName = "CormorantGaramond-Regular"
        case .medium:
            fontName = "CormorantGaramond-Medium"
        case .semibold:
            fontName = "CormorantGaramond-SemiBold"
        case .bold:
            fontName = "CormorantGaramond-Bold"
        default:
            fontName = "CormorantGaramond-Regular"
        }
        return Font.custom(fontName, size: size)
    }

    /// Body font with custom size and weight
    static func remodlyBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .regular:
            fontName = "DMSans-Regular"
        case .medium:
            fontName = "DMSans-Medium"
        case .bold, .semibold:
            fontName = "DMSans-Bold"
        default:
            fontName = "DMSans-Regular"
        }
        return Font.custom(fontName, size: size)
    }
}

// MARK: - UIFont Extension for UIKit compatibility

#if canImport(UIKit)
import UIKit

extension UIFont {
    static func remodlyDisplay(size: CGFloat, weight: UIFont.Weight = .semibold) -> UIFont {
        let fontName: String
        switch weight {
        case .regular:
            fontName = "CormorantGaramond-Regular"
        case .medium:
            fontName = "CormorantGaramond-Medium"
        case .semibold:
            fontName = "CormorantGaramond-SemiBold"
        case .bold:
            fontName = "CormorantGaramond-Bold"
        default:
            fontName = "CormorantGaramond-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }

    static func remodlyBody(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName: String
        switch weight {
        case .regular:
            fontName = "DMSans-Regular"
        case .medium:
            fontName = "DMSans-Medium"
        case .bold, .semibold:
            fontName = "DMSans-Bold"
        default:
            fontName = "DMSans-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
#endif
