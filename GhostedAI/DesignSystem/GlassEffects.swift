import SwiftUI

/// Glass morphism effects for creating modern iOS-style blur and transparency
struct GlassEffects {
    /// Ultra thin glass material - very subtle blur
    static let ultraThin = Material.ultraThinMaterial

    /// Thin glass material - light blur
    static let thin = Material.thinMaterial

    /// Regular glass material - standard blur
    static let regular = Material.regularMaterial

    /// Thick glass material - heavy blur
    static let thick = Material.thickMaterial
}

/// View modifier for applying glass card effect
struct GlassCardModifier: ViewModifier {
    let material: Material
    let cornerRadius: CGFloat
    let borderOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(material)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Additional Modifiers (used by GlassCard component)

struct PremiumGlassModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

struct FrostedGlassModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

struct GlassBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

extension View {
    /// Apply glass card effect to any view
    func glassCard(
        material: Material = .thinMaterial,
        cornerRadius: CGFloat = 16,
        borderOpacity: Double = 0.15
    ) -> some View {
        modifier(GlassCardModifier(
            material: material,
            cornerRadius: cornerRadius,
            borderOpacity: borderOpacity
        ))
    }

    /// Apply subtle glass background (no border, minimal shadow)
    func glassBackground(cornerRadius: CGFloat = 12) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }
}
