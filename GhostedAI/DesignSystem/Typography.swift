import SwiftUI

/// Typography system using SF Pro with Space Grotesk-inspired styling.
/// Maintains the same font sizing hierarchy from the Flutter implementation.
///
/// Usage:
/// ```swift
/// Text("Title")
///     .typography(.headlineLarge)
///
/// Text("Body text")
///     .typography(.bodyMedium)
/// ```
public extension View {
    /// Apply a typography style to text
    func typography(_ style: Typography.Style) -> some View {
        modifier(Typography.StyleModifier(style: style))
    }
}

public struct Typography {
    // MARK: - Typography Styles

    public enum Style {
        // MARK: Display Styles (Large Titles)
        /// 57pt, Bold, -3% letter spacing
        case displayLarge
        /// 45pt, Bold, -3% letter spacing
        case displayMedium
        /// 36pt, Semibold, -3% letter spacing
        case displaySmall

        // MARK: Headline Styles (Section Headers)
        /// 32pt, Semibold, -3% letter spacing
        case headlineLarge
        /// 28pt, Semibold, -3% letter spacing
        case headlineMedium
        /// 24pt, Semibold, -3% letter spacing
        case headlineSmall

        // MARK: Title Styles
        /// 22pt, Medium, -3% letter spacing
        case titleLarge
        /// 16pt, Medium, -3% letter spacing
        case titleMedium
        /// 14pt, Medium, -3% letter spacing
        case titleSmall

        // MARK: Body Styles
        /// 16pt, Regular, 0.5pt spacing, 1.5 line height
        case bodyLarge
        /// 14pt, Regular, 0.25pt spacing, 1.43 line height
        case bodyMedium
        /// 12pt, Regular, 0.4pt spacing, 1.33 line height
        case bodySmall

        // MARK: Label Styles
        /// 14pt, Medium, 0.1pt spacing
        case labelLarge
        /// 12pt, Medium, 0.5pt spacing
        case labelMedium
        /// 11pt, Medium, 0.5pt spacing
        case labelSmall

        // MARK: Data/Monospace Style
        /// 14pt, Monospace (SF Mono), for numerical displays
        case dataMedium
        /// 12pt, Monospace (SF Mono), for numerical displays
        case dataSmall

        // MARK: - Style Properties

        var font: Font {
            switch self {
            // Display styles - using rounded for Space Grotesk feel
            case .displayLarge:
                return .system(size: 57, weight: .bold, design: .rounded)
            case .displayMedium:
                return .system(size: 45, weight: .bold, design: .rounded)
            case .displaySmall:
                return .system(size: 36, weight: .semibold, design: .rounded)

            // Headline styles
            case .headlineLarge:
                return .system(size: 32, weight: .semibold, design: .rounded)
            case .headlineMedium:
                return .system(size: 28, weight: .semibold, design: .rounded)
            case .headlineSmall:
                return .system(size: 24, weight: .semibold, design: .rounded)

            // Title styles
            case .titleLarge:
                return .system(size: 22, weight: .medium, design: .rounded)
            case .titleMedium:
                return .system(size: 16, weight: .medium, design: .rounded)
            case .titleSmall:
                return .system(size: 14, weight: .medium, design: .rounded)

            // Body styles - SF Pro Text
            case .bodyLarge:
                return .system(size: 16, weight: .regular, design: .default)
            case .bodyMedium:
                return .system(size: 14, weight: .regular, design: .default)
            case .bodySmall:
                return .system(size: 12, weight: .regular, design: .default)

            // Label styles
            case .labelLarge:
                return .system(size: 14, weight: .medium, design: .default)
            case .labelMedium:
                return .system(size: 12, weight: .medium, design: .default)
            case .labelSmall:
                return .system(size: 11, weight: .medium, design: .default)

            // Data/Monospace
            case .dataMedium:
                return .system(size: 14, weight: .regular, design: .monospaced)
            case .dataSmall:
                return .system(size: 12, weight: .regular, design: .monospaced)
            }
        }

        var kerning: CGFloat {
            switch self {
            // -3% letter spacing for display/headline/title styles
            case .displayLarge:
                return -1.71  // -3% of 57
            case .displayMedium:
                return -1.35  // -3% of 45
            case .displaySmall:
                return -1.08  // -3% of 36
            case .headlineLarge:
                return -0.96  // -3% of 32
            case .headlineMedium:
                return -0.84  // -3% of 28
            case .headlineSmall:
                return -0.72  // -3% of 24
            case .titleLarge:
                return -0.66  // -3% of 22
            case .titleMedium:
                return -0.48  // -3% of 16
            case .titleSmall:
                return -0.42  // -3% of 14

            // Body styles - positive spacing
            case .bodyLarge:
                return 0.5
            case .bodyMedium:
                return 0.25
            case .bodySmall:
                return 0.4

            // Label styles
            case .labelLarge:
                return 0.1
            case .labelMedium, .labelSmall:
                return 0.5

            // Data styles - no spacing
            case .dataMedium, .dataSmall:
                return 0
            }
        }

        var lineSpacing: CGFloat {
            switch self {
            case .bodyLarge:
                return 16 * 0.5  // 1.5 line height = 0.5 extra spacing
            case .bodyMedium:
                return 14 * 0.43  // 1.43 line height
            case .bodySmall:
                return 12 * 0.33  // 1.33 line height
            default:
                return 0
            }
        }

        var textColor: Color {
            switch self {
            case .bodySmall, .labelMedium, .labelSmall:
                return .DS.textSecondary
            default:
                return .DS.textPrimary
            }
        }
    }

    // MARK: - Style Modifier

    struct StyleModifier: ViewModifier {
        let style: Style

        func body(content: Content) -> some View {
            content
                .font(style.font)
                .kerning(style.kerning)
                .lineSpacing(style.lineSpacing)
                .foregroundColor(style.textColor)
        }
    }
}

// MARK: - Convenience Text Extensions

public extension Text {
    /// Apply typography style directly to Text
    func typography(_ style: Typography.Style) -> Text {
        self
            .font(style.font)
            .kerning(style.kerning)
            .foregroundColor(style.textColor)
    }
}

// MARK: - Custom Font Helper (Optional)

public extension Font {
    /// SF Pro Text with custom parameters
    static func sfProText(
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// SF Pro Rounded (Space Grotesk alternative) with custom parameters
    static func sfProRounded(
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// SF Mono for data/numerical displays
    static func sfMono(
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}
