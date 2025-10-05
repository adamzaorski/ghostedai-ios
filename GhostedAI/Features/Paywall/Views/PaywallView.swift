import SwiftUI

/// Placeholder paywall view shown after completing onboarding
/// Will be expanded with subscription options, RevenueCat integration, etc.
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Animated gradient background
            animatedBackground

            VStack(spacing: Spacing.xxl) {
                Spacer()

                // Icon/Logo
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.DS.accentOrangeStart,
                                Color.DS.accentOrangeEnd
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Heading
                VStack(spacing: Spacing.m) {
                    Text("You're Almost There")
                        .typography(.displayMedium)
                        .foregroundColor(.DS.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("unlock your personalized healing journey")
                        .typography(.titleLarge)
                        .foregroundColor(.DS.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Placeholder subscription options
                VStack(spacing: Spacing.m) {
                    // Premium plan card
                    subscriptionCard(
                        title: "Premium",
                        price: "$9.99/month",
                        features: [
                            "Unlimited AI conversations",
                            "Personalized healing plan",
                            "Daily check-ins & support",
                            "Premium content library"
                        ]
                    )

                    // Continue button
                    Button(action: handleSubscribe) {
                        HStack(spacing: Spacing.s) {
                            Text("Start Your Journey")
                                .typography(.titleMedium)
                                .foregroundColor(.DS.onAccentOrange)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.DS.onAccentOrange)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.m)
                        .background(LinearGradient.DS.orangeAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(
                            color: Color.DS.accentOrangeStart.opacity(0.3),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())

                    // Restore purchases / Terms
                    HStack(spacing: Spacing.m) {
                        Button("Restore") {
                            // TODO: Restore purchases
                        }
                        .typography(.labelMedium)
                        .foregroundColor(.DS.textSecondary)

                        Text("•")
                            .foregroundColor(.DS.textSecondary)

                        Button("Terms") {
                            // TODO: Show terms
                        }
                        .typography(.labelMedium)
                        .foregroundColor(.DS.textSecondary)

                        Text("•")
                            .foregroundColor(.DS.textSecondary)

                        Button("Privacy") {
                            // TODO: Show privacy
                        }
                        .typography(.labelMedium)
                        .foregroundColor(.DS.textSecondary)
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Background

    private var animatedBackground: some View {
        ZStack {
            // Base black background
            Color.DS.primaryBlack
                .ignoresSafeArea()

            // Subtle gradient overlay
            RadialGradient(
                colors: [
                    Color.DS.accentOrangeStart.opacity(0.15),
                    Color.DS.accentOrangeEnd.opacity(0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 600
            )
            .blur(radius: 80)
            .ignoresSafeArea()
        }
    }

    // MARK: - Subscription Card

    private func subscriptionCard(title: String, price: String, features: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            // Title and price
            HStack {
                Text(title)
                    .typography(.headlineLarge)
                    .foregroundColor(.DS.textPrimary)

                Spacer()

                Text(price)
                    .typography(.titleLarge)
                    .foregroundColor(.DS.accentOrangeStart)
            }

            // Features list
            VStack(alignment: .leading, spacing: Spacing.s) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: Spacing.s) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.DS.accentOrangeStart)

                        Text(feature)
                            .typography(.bodyMedium)
                            .foregroundColor(.DS.textSecondary)
                    }
                }
            }
        }
        .padding(Spacing.l)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient.DS.orangeAccent,
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.DS.accentOrangeStart.opacity(0.2),
                    radius: 30,
                    x: 0,
                    y: 15
                )
        )
    }

    // MARK: - Actions

    private func handleSubscribe() {
        // TODO: Implement subscription flow with RevenueCat
        print("Subscribe tapped - implement RevenueCat flow")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PaywallView()
    }
}
