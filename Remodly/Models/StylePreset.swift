import Foundation

struct StylePreset: Codable, Identifiable {
    let id: String
    let name: String
    let displayName: String
    let description: String
    let palette: ColorPalette
    let materialSetId: String
    let fixtureStyleDirection: String
    let lightingPreset: String
    let thumbnailUrl: String?

    struct ColorPalette: Codable {
        let primary: String    // hex color
        let secondary: String  // hex color
        let accent: String     // hex color
        let neutral: String    // hex color
    }
}

extension StylePreset {
    static let sophisticated = StylePreset(
        id: "sophisticated",
        name: "sophisticated",
        displayName: "Sophisticated",
        description: "Clean lines, neutral tones, modern elegance",
        palette: ColorPalette(primary: "#2C3E50", secondary: "#ECF0F1", accent: "#3498DB", neutral: "#BDC3C7"),
        materialSetId: "mat_sophisticated_01",
        fixtureStyleDirection: "modern",
        lightingPreset: "bright_neutral",
        thumbnailUrl: nil
    )

    static let antique = StylePreset(
        id: "antique",
        name: "antique",
        displayName: "Antique",
        description: "Classic warmth, rich textures, timeless appeal",
        palette: ColorPalette(primary: "#8B4513", secondary: "#F5F5DC", accent: "#DAA520", neutral: "#D2B48C"),
        materialSetId: "mat_antique_01",
        fixtureStyleDirection: "traditional",
        lightingPreset: "warm_ambient",
        thumbnailUrl: nil
    )

    static let european = StylePreset(
        id: "european",
        name: "european",
        displayName: "European",
        description: "Continental flair, refined details, sophisticated charm",
        palette: ColorPalette(primary: "#4A4A4A", secondary: "#FFFFFF", accent: "#C0A080", neutral: "#E8E4E1"),
        materialSetId: "mat_european_01",
        fixtureStyleDirection: "transitional",
        lightingPreset: "soft_directional",
        thumbnailUrl: nil
    )

    static let allPresets: [StylePreset] = [.sophisticated, .antique, .european]
}
