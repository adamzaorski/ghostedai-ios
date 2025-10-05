import SwiftUI

/// Comprehensive design system preview showcasing all colors, typography,
/// glass effects, spacing, and components in action.
///
/// This view serves as both a visual reference and testing playground
/// for the Midnight Warmth design system.
struct DesignSystemPreviewView: View {
    @State private var selectedTab = 0


    var body: some View {
        ZStack {
            // Background
            Color.DS.primaryBlack.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    headerSection

                    // Color Palette
                    colorPaletteSection

                    // Typography
                    typographySection

                    // Glass Effects
                    glassEffectsSection

                    // Gradients
                    gradientSection

                    // Spacing Examples
                    spacingSection

                    // Component Examples
                    componentsSection

                    // Interactive Demo
                    interactiveSection
                }
                .padding(Spacing.m)
                .padding(.bottom, Spacing.xxl)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.m) {
            Text("Design System")
                .typography(.displayLarge)

            Text("Midnight Warmth • Therapeutic Minimalism")
                .typography(.bodyMedium)
                .foregroundColor(.DS.textSecondary)

            Rectangle()
                .fill(LinearGradient.DS.orangeAccent)
                .frame(height: 4)
                .frame(maxWidth: 120)
        }
        .padding(.top, Spacing.l)
        .padding(.bottom, Spacing.m)
    }

    // MARK: - Color Palette Section

    private var colorPaletteSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader("Color Palette")

            GlassCard(style: .frosted) {
                VStack(spacing: Spacing.m) {
                    // Primary Colors
                    colorGroup(title: "Primary", colors: [
                        ("Primary Black", Color.DS.primaryBlack, true),
                        ("Text Primary", Color.DS.textPrimary, false),
                        ("Text Secondary", Color.DS.textSecondary, false)
                    ])

                    divider()

                    // Accent Colors
                    colorGroup(title: "Accent", colors: [
                        ("Orange Start", Color.DS.accentOrangeStart, true),
                        ("Orange End", Color.DS.accentOrangeEnd, true),
                        ("On Orange", Color.DS.onAccentOrange, false)
                    ])

                    divider()

                    // Semantic Colors
                    colorGroup(title: "Semantic", colors: [
                        ("Success Green", Color.DS.successGreen, true),
                        ("Warning Amber", Color.DS.warningAmber, false),
                        ("Error Red", Color.DS.errorRed, true)
                    ])

                    divider()

                    // Surface Colors
                    colorGroup(title: "Surface", colors: [
                        ("Elevated", Color.DS.surfaceElevated, false),
                        ("Divider", Color.DS.dividerGray, false),
                        ("Border", Color.DS.surfaceBorder, false)
                    ])
                }
            }
        }
    }

    private func colorGroup(title: String, colors: [(String, Color, Bool)]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .typography(.labelLarge)
                .foregroundColor(.DS.textSecondary)

            VStack(spacing: Spacing.s) {
                ForEach(colors, id: \.0) { item in
                    colorSwatch(name: item.0, color: item.1, darkText: item.2)
                }
            }
        }
    }

    private func colorSwatch(name: String, color: Color, darkText: Bool) -> some View {
        HStack(spacing: Spacing.s) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 48, height: 48)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .typography(.bodyMedium)

                Text("Color Sample")
                    .font(.sfProText(size: 11, weight: .regular))
                    .foregroundColor(.DS.textSecondary)
            }

            Spacer()

            // Color preview with text
            Text("Aa")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(darkText ? .black : .white)
                .frame(width: 32, height: 32)
                .background(color)
                .clipShape(Circle())
        }
    }

    // MARK: - Typography Section

    private var typographySection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader("Typography")

            GlassCard(style: .standard) {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    // Display Styles
                    typographyGroup(title: "Display", styles: [
                        ("Display Large", Typography.Style.displayLarge),
                        ("Display Medium", Typography.Style.displayMedium),
                        ("Display Small", Typography.Style.displaySmall)
                    ])

                    divider()

                    // Headline Styles
                    typographyGroup(title: "Headline", styles: [
                        ("Headline Large", Typography.Style.headlineLarge),
                        ("Headline Medium", Typography.Style.headlineMedium),
                        ("Headline Small", Typography.Style.headlineSmall)
                    ])

                    divider()

                    // Title Styles
                    typographyGroup(title: "Title", styles: [
                        ("Title Large", Typography.Style.titleLarge),
                        ("Title Medium", Typography.Style.titleMedium),
                        ("Title Small", Typography.Style.titleSmall)
                    ])

                    divider()

                    // Body Styles
                    typographyGroup(title: "Body", styles: [
                        ("Body Large", Typography.Style.bodyLarge),
                        ("Body Medium", Typography.Style.bodyMedium),
                        ("Body Small", Typography.Style.bodySmall)
                    ])

                    divider()

                    // Label Styles
                    typographyGroup(title: "Label", styles: [
                        ("Label Large", Typography.Style.labelLarge),
                        ("Label Medium", Typography.Style.labelMedium),
                        ("Label Small", Typography.Style.labelSmall)
                    ])

                    divider()

                    // Data Styles
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("Data/Monospace")
                            .typography(.labelLarge)
                            .foregroundColor(.DS.textSecondary)

                        Text("1,234.56")
                            .typography(.dataMedium)

                        Text("$567.89")
                            .typography(.dataSmall)
                    }
                }
            }
        }
    }

    private func typographyGroup(title: String, styles: [(String, Typography.Style)]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .typography(.labelLarge)
                .foregroundColor(.DS.textSecondary)

            ForEach(styles, id: \.0) { item in
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.0)
                        .typography(item.1)

                    Text(styleDescription(item.1))
                        .font(.sfProText(size: 10, weight: .regular))
                        .foregroundColor(.DS.textSecondary)
                }
            }
        }
    }

    private func styleDescription(_ style: Typography.Style) -> String {
        let kerning = style.kerning
        return "Kerning: \(String(format: "%.2f", kerning))pt"
    }

    // MARK: - Glass Effects Section

    private var glassEffectsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader("Glass Effects")

            VStack(spacing: Spacing.m) {
                // Standard Glass
                glassDemo(
                    title: "Standard Glass",
                    subtitle: "Ultra-thin material with subtle border",
                    style: .standard
                )

                // Premium Glass
                glassDemo(
                    title: "Premium Glass",
                    subtitle: "Enhanced gradients and dual shadows",
                    style: .premium
                )

                // Frosted Glass
                glassDemo(
                    title: "Frosted Glass",
                    subtitle: "More opaque with stronger blur",
                    style: .frosted
                )

                // Minimal Glass
                glassDemo(
                    title: "Minimal Glass",
                    subtitle: "Subtle background, minimal shadow",
                    style: .minimal
                )
            }
        }
    }

    @ViewBuilder
    private func glassDemo(title: String, subtitle: String, style: GlassCardStyle) -> some View {
        GlassCard(style: style) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .typography(.titleMedium)

                Text(subtitle)
                    .typography(.bodySmall)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Gradient Section

    private var gradientSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader("Gradients")

            VStack(spacing: Spacing.m) {
                // Orange Accent Gradient
                VStack(spacing: Spacing.s) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient.DS.orangeAccent)
                        .frame(height: 100)
                        .overlay {
                            Text("Orange Accent Gradient")
                                .typography(.titleMedium)
                                .foregroundColor(.DS.onAccentOrange)
                        }

                    Text("#FF6B35 → #FF8E53")
                        .typography(.bodySmall)
                }

                // Glass Overlay Gradient
                VStack(spacing: Spacing.s) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient.DS.glassOverlay)
                        .frame(height: 100)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.DS.surfaceElevated)
                        }
                        .overlay {
                            Text("Glass Overlay")
                                .typography(.titleMedium)
                        }

                    Text("White gradient for glass effects")
                        .typography(.bodySmall)
                }
            }
            .padding(Spacing.m)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.thinMaterial)
            }
            .shadow(color: Color.DS.glassShadow, radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Spacing Section

    private var spacingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader("Spacing (8pt Grid)")

            GlassCard(style: .standard) {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    spacingExample("XS", value: Spacing.xs, "4pt")
                    spacingExample("S", value: Spacing.s, "8pt")
                    spacingExample("M", value: Spacing.m, "16pt")
                    spacingExample("L", value: Spacing.l, "24pt")
                    spacingExample("XL", value: Spacing.xl, "32pt")
                    spacingExample("XXL", value: Spacing.xxl, "48pt")
                }
            }
        }
    }

    private func spacingExample(_ name: String, value: CGFloat, _ description: String) -> some View {
        HStack(spacing: Spacing.m) {
            Text(name)
                .typography(.labelLarge)
                .frame(width: 40, alignment: .leading)

            Rectangle()
                .fill(LinearGradient.DS.orangeAccent)
                .frame(width: value, height: 4)

            Text(description)
                .typography(.bodySmall)

            Spacer()
        }
    }

    // MARK: - Components Section

    private var componentsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader("Components")

            VStack(spacing: Spacing.m) {
                // Glass Content Card
                GlassContentCard(title: "Content Card") {
                    Text("A glass card with title and divider. Perfect for organizing content into logical sections.")
                        .typography(.bodyMedium)
                }

                // Glass Icon Card
                GlassIconCard(
                    icon: "star.fill",
                    title: "Icon Card",
                    subtitle: "With header and icon"
                ) {
                    Text("Features an icon header with title and subtitle. Great for feature highlights.")
                        .typography(.bodyMedium)
                }

                // Metric Cards
                HStack(spacing: Spacing.m) {
                    GlassMetricCard(
                        value: "1.2K",
                        label: "Users",
                        trend: .up("+12%")
                    )

                    GlassMetricCard(
                        value: "567",
                        label: "Active",
                        trend: .down("-5%")
                    )
                }
            }
        }
    }

    // MARK: - Interactive Section

    private var interactiveSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader("Interactive Demo")

            GlassCard(style: .premium) {
                VStack(spacing: Spacing.l) {
                    // Button Examples
                    VStack(spacing: Spacing.s) {
                        Text("Buttons")
                            .typography(.titleSmall)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: Spacing.s) {
                            Button("Primary") {}
                                .buttonStyle(PrimaryButtonStyle())

                            Button("Secondary") {}
                                .buttonStyle(SecondaryButtonStyle())
                        }
                    }

                    divider()

                    // Toggle Example
                    VStack(spacing: Spacing.s) {
                        Text("Toggle")
                            .typography(.titleSmall)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Text("Dark Mode")
                                .typography(.bodyMedium)
                            Spacer()
                            Toggle("", isOn: .constant(true))
                                .labelsHidden()
                        }
                    }

                    divider()

                    // Segmented Control Example
                    VStack(spacing: Spacing.s) {
                        Text("Tabs")
                            .typography(.titleSmall)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Picker("", selection: $selectedTab) {
                            Text("All").tag(0)
                            Text("Active").tag(1)
                            Text("Archived").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
        }
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .typography(.headlineSmall)

            Spacer()
        }
    }

    private func divider() -> some View {
        Rectangle()
            .fill(Color.DS.dividerGray)
            .frame(height: 1)
    }
}

// MARK: - Custom Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.DS.onAccentOrange)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .frame(maxWidth: .infinity)
            .background(LinearGradient.DS.orangeAccent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.DS.accentOrangeStart)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .frame(maxWidth: .infinity)
            .background(Color.DS.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.DS.accentOrangeStart, lineWidth: 1.5)
            }
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    DesignSystemPreviewView()
}
