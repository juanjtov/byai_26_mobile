import SwiftUI

extension View {
    // MARK: - Copper Glow

    /// Copper glow with default intensity (40%)
    func copperGlow() -> some View {
        self.shadow(color: Color.copper.opacity(0.4), radius: 20)
    }

    /// Copper glow with strong intensity (60%)
    func copperGlowStrong() -> some View {
        self.shadow(color: Color.copper.opacity(0.6), radius: 30)
    }

    /// Copper glow with custom intensity
    func copperGlow(intensity: Double) -> some View {
        self.shadow(color: Color.copper.opacity(intensity), radius: 20)
    }

    // MARK: - Signal Glow

    /// Signal glow with default intensity (40%)
    func signalGlow() -> some View {
        self.shadow(color: Color.signal.opacity(0.4), radius: 20)
    }

    /// Signal glow with strong intensity (60%)
    func signalGlowStrong() -> some View {
        self.shadow(color: Color.signal.opacity(0.6), radius: 30)
    }

    /// Signal glow with custom intensity
    func signalGlow(intensity: Double) -> some View {
        self.shadow(color: Color.signal.opacity(intensity), radius: 20)
    }

    // MARK: - Gold Glow

    /// Gold glow with default intensity (40%)
    func goldGlow() -> some View {
        self.shadow(color: Color.gold.opacity(0.4), radius: 20)
    }

    // MARK: - Sage Glow

    /// Sage glow with default intensity (40%)
    func sageGlow() -> some View {
        self.shadow(color: Color.sageMuted.opacity(0.4), radius: 20)
    }

    // MARK: - Card Styling

    /// Apply standard Remodly card styling
    func remodlyCard() -> some View {
        self
            .padding(.spacingLG)
            .background(Color.ivorySubtle)
            .overlay(
                RoundedRectangle(cornerRadius: .radiusLarge)
                    .stroke(Color.ivoryBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
    }

    /// Apply dark card styling with tungsten background
    func remodlyCardDark() -> some View {
        self
            .padding(.spacingLG)
            .background(Color.tungsten)
            .overlay(
                RoundedRectangle(cornerRadius: .radiusLarge)
                    .stroke(Color.ivoryBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
    }
}
