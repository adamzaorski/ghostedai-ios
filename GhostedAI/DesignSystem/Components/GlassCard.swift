import SwiftUI

// MARK: - Glass Card Style

/// Style options for GlassCard
public enum GlassCardStyle {
    /// Standard glass effect (ultraThinMaterial)
    case standard
    /// Premium glass with enhanced gradient and shadows
    case premium
    /// Frosted glass (more opaque)
    case frosted
    /// Minimal glass (subtle background)
    case minimal

    var cornerRadius: CGFloat {
        switch self {
        case .standard: return 16
        case .premium: return 20
        case .frosted: return 16
        case .minimal: return 12
        }
    }
}

// MARK: - Glass Card Component

/// A reusable glass card component with premium iOS 18-inspired aesthetics.
/// Combines glassmorphic effects with consistent spacing and typography.
///
/// Usage:
/// ```swift
/// GlassCard {
///     Text("Content")
/// }
///
/// GlassCard(style: .premium) {
///     VStack {
///         Text("Title")
///             .typography(.titleLarge)
///         Text("Description")
///             .typography(.bodyMedium)
///     }
/// }
/// ```
public struct GlassCard<Content: View>: View {

    // MARK: - Properties

    private let style: GlassCardStyle
    private let content: Content

    // MARK: - Initialization

    /// Create a glass card with custom styling
    /// - Parameters:
    ///   - style: Visual style of the card (default: .standard)
    ///   - content: Card content
    public init(
        style: GlassCardStyle = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        content
            .padding(Spacing.m)
            .background {
                glassBackground
            }
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
    }

    // MARK: - Glass Background

    @ViewBuilder
    private var glassBackground: some View {
        ZStack {
            // Base blur material
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(material)

            // Surface tint (for frosted/premium)
            if style == .frosted || style == .premium {
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(Color.DS.surfaceElevated.opacity(surfaceTintOpacity))
            }

            // Gradient overlay
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(gradientOverlay)

            // Border
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(Color.white.opacity(borderOpacity), lineWidth: borderWidth)
        }
    }

    // MARK: - Style Properties

    private var material: Material {
        switch style {
        case .standard, .premium:
            return .ultraThinMaterial
        case .frosted:
            return .regularMaterial
        case .minimal:
            return .thinMaterial
        }
    }

    private var gradientOverlay: LinearGradient {
        switch style {
        case .standard, .minimal:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .premium:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.05),
                    Color.white.opacity(0.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .frosted:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .center
            )
        }
    }

    private var borderOpacity: Double {
        switch style {
        case .standard: return 0.15
        case .premium: return 0.25
        case .frosted: return 0.12
        case .minimal: return 0.08
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .premium: return 1.5
        default: return 1
        }
    }

    private var surfaceTintOpacity: Double {
        switch style {
        case .frosted: return 0.7
        case .premium: return 0.5
        default: return 0
        }
    }

    private var shadowColor: Color {
        switch style {
        case .premium:
            return Color.DS.glassShadow
        default:
            return Color.DS.glassShadow
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .premium: return 20
        case .standard: return 16
        case .frosted: return 12
        case .minimal: return 8
        }
    }

    private var shadowOffset: CGFloat {
        switch style {
        case .premium: return 10
        case .standard: return 8
        case .frosted: return 6
        case .minimal: return 4
        }
    }
}

// MARK: - Specialized Glass Cards

/// A glass card specifically designed for content sections
public struct GlassContentCard<Content: View>: View {
    private let title: String?
    private let content: Content

    public init(
        title: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        GlassCard(style: .standard) {
            VStack(alignment: .leading, spacing: Spacing.m) {
                if let title = title {
                    Text(title)
                        .typography(.titleLarge)

                    Divider()
                        .background(Color.DS.dividerGray)
                }

                content
            }
        }
    }
}

/// A glass card with an icon header
public struct GlassIconCard<Content: View>: View {
    private let icon: String
    private let title: String
    private let subtitle: String?
    private let content: Content

    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: some View {
        GlassCard(style: .premium) {
            VStack(alignment: .leading, spacing: Spacing.m) {
                // Header
                HStack(spacing: Spacing.s) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.DS.accentOrangeStart)
                        .frame(width: 40, height: 40)
                        .background {
                            Circle()
                                .fill(Color.DS.accentOrangeStart.opacity(0.15))
                        }

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(title)
                            .typography(.titleMedium)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .typography(.bodySmall)
                        }
                    }

                    Spacer()
                }

                // Content
                content
            }
        }
    }
}

/// A glass card for statistics/metrics
public struct GlassMetricCard: View {
    private let value: String
    private let label: String
    private let trend: Trend?

    public enum Trend {
        case up(String)
        case down(String)
        case neutral(String)

        var color: Color {
            switch self {
            case .up: return .DS.successGreen
            case .down: return .DS.errorRed
            case .neutral: return .DS.textSecondary
            }
        }

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }

        var text: String {
            switch self {
            case .up(let val), .down(let val), .neutral(let val):
                return val
            }
        }
    }

    public init(
        value: String,
        label: String,
        trend: Trend? = nil
    ) {
        self.value = value
        self.label = label
        self.trend = trend
    }

    public var body: some View {
        GlassCard(style: .frosted) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                // Value
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text(value)
                        .font(.sfMono(size: 32, weight: .semibold))
                        .foregroundColor(.DS.textPrimary)

                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(trend.text)
                                .font(.sfMono(size: 12, weight: .medium))
                        }
                        .foregroundColor(trend.color)
                    }
                }

                // Label
                Text(label)
                    .typography(.labelMedium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Preview Provider

#Preview("Glass Card Styles") {
    ZStack {
        Color.DS.primaryBlack.ignoresSafeArea()

        ScrollView {
            VStack(spacing: Spacing.l) {
                // Standard
                GlassCard {
                    Text("Standard Glass Card")
                        .typography(.bodyLarge)
                }

                // Premium
                GlassCard(style: .premium) {
                    Text("Premium Glass Card")
                        .typography(.bodyLarge)
                }

                // Frosted
                GlassCard(style: .frosted) {
                    Text("Frosted Glass Card")
                        .typography(.bodyLarge)
                }

                // Minimal
                GlassCard(style: .minimal) {
                    Text("Minimal Glass Card")
                        .typography(.bodyLarge)
                }

                // Content Card
                GlassContentCard(title: "Section Title") {
                    Text("This is a content card with a title and divider.")
                        .typography(.bodyMedium)
                }

                // Icon Card
                GlassIconCard(
                    icon: "star.fill",
                    title: "Featured",
                    subtitle: "Special content"
                ) {
                    Text("Icon card with header and content")
                        .typography(.bodyMedium)
                }

                // Metric Cards
                HStack(spacing: Spacing.m) {
                    GlassMetricCard(
                        value: "1,234",
                        label: "Total Users",
                        trend: .up("+12%")
                    )

                    GlassMetricCard(
                        value: "567",
                        label: "Active Now",
                        trend: .down("-5%")
                    )
                }
            }
            .padding(Spacing.m)
        }
    }
}
