import SwiftUI

/// Midnight Warmth color palette implementing Therapeutic Minimalism design.
/// Supports both dark mode (primary) and light mode variants.
///
/// Usage:
/// ```swift
/// Text("Hello")
///     .foregroundColor(.DS.primaryBlack)
///     .background(.DS.surfaceElevated)
/// ```
public extension Color {
    /// Design System namespace to avoid conflicts
    struct DS {
        // MARK: - Primary Colors

        /// Primary black background (#000000)
        static let primaryBlack = Color(hex: 0x000000)

        /// Primary white text (#FFFFFF)
        static let textPrimary = Color(hex: 0xFFFFFF)

        /// Secondary text color (#B3B3B3)
        static let textSecondary = Color(hex: 0xB3B3B3)

        // MARK: - Accent Colors

        /// Orange gradient start (#FF6B35)
        static let accentOrangeStart = Color(hex: 0xFF6B35)

        /// Orange gradient end (#FF8E53)
        static let accentOrangeEnd = Color(hex: 0xFF8E53)

        /// Text color on orange accent (black)
        static let onAccentOrange = Color(hex: 0x000000)

        // MARK: - Semantic Colors

        /// Success state green (#4CAF50)
        static let successGreen = Color(hex: 0x4CAF50)

        /// Warning state amber (#FFC107)
        static let warningAmber = Color(hex: 0xFFC107)

        /// Error state red (#F44336)
        static let errorRed = Color(hex: 0xF44336)

        /// Success green text color (white)
        static let onSuccessGreen = Color(hex: 0xFFFFFF)

        /// Warning amber text color (black)
        static let onWarningAmber = Color(hex: 0x000000)

        /// Error red text color (white)
        static let onErrorRed = Color(hex: 0xFFFFFF)

        // MARK: - Surface Colors

        /// Elevated surface color (#1A1A1A)
        static let surfaceElevated = Color(hex: 0x1A1A1A)

        /// Divider gray (#333333)
        static let dividerGray = Color(hex: 0x333333)

        /// Surface border color (#444444)
        static let surfaceBorder = Color(hex: 0x444444)

        // MARK: - Shadow Colors

        /// Shadow color (20% opacity black)
        static let shadowColor = Color.black.opacity(0.2)

        /// Shadow color for glassmorphic effects (softer)
        static let glassShadow = Color.black.opacity(0.1)

        // MARK: - Light Mode Variants (Optional)

        /// Adaptive background - black in dark mode, white in light mode
        static let adaptiveBackground = Color(
            light: Color(hex: 0xFFFFFF),
            dark: Color(hex: 0x000000)
        )

        /// Adaptive text - white in dark mode, black in light mode
        static let adaptiveText = Color(
            light: Color(hex: 0x000000),
            dark: Color(hex: 0xFFFFFF)
        )

        /// Adaptive surface - light gray in light mode, dark gray in dark mode
        static let adaptiveSurface = Color(
            light: Color(hex: 0xF5F5F5),
            dark: Color(hex: 0x1A1A1A)
        )
    }
}

// MARK: - Gradient Definitions

public extension LinearGradient {
    /// Design System gradients
    struct DS {
        /// Orange accent gradient (top-left to bottom-right)
        static let orangeAccent = LinearGradient(
            colors: [.DS.accentOrangeStart, .DS.accentOrangeEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Subtle white gradient for glass overlays
        static let glassOverlay = LinearGradient(
            colors: [
                Color.white.opacity(0.15),
                Color.white.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Dark gradient for glass cards
        static let glassDark = LinearGradient(
            colors: [
                Color.DS.surfaceElevated.opacity(0.8),
                Color.DS.surfaceElevated.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Helper Extensions

extension Color {
    /// Initialize Color from hex value
    /// - Parameter hex: Hexadecimal color value (e.g., 0xFF6B35)
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    /// Initialize adaptive color for light/dark mode
    /// - Parameters:
    ///   - light: Color for light mode
    ///   - dark: Color for dark mode
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(light: UIColor(light), dark: UIColor(dark)))
    }
}

extension UIColor {
    /// Initialize adaptive UIColor for light/dark mode
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            case .light, .unspecified:
                return light
            @unknown default:
                return light
            }
        }
    }
}
