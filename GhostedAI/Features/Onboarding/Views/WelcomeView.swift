import SwiftUI

/// Welcome screen for GhostedAI - Gen Z friendly onboarding
/// Features animated gradient background, glassmorphic design, and warm messaging
struct WelcomeView: View {
    @State private var isAnimating = false
    @State private var showContent = false
    @State private var pulseAnimation = false
    @State private var showSignInModal = false
    @State private var navigateToOnboarding = false

    var body: some View {
        NavigationStack {
            ZStack {
            // Animated gradient background
            animatedBackground

            // Main content
            VStack(spacing: Spacing.xxl) {
                Spacer()

                // Logo and branding
                brandingSection
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Spacer()

                // CTA buttons
                ctaSection
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.xxl)
            }
            .ignoresSafeArea()
            .navigationDestination(isPresented: $navigateToOnboarding) {
                OnboardingContainerView()
            }
            .sheet(isPresented: $showSignInModal) {
                SignInOptionsView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
            }
            .onAppear {
                startAnimations()
            }
        }
    }

    // MARK: - Animated Background

    private var animatedBackground: some View {
        ZStack {
            // Base black background
            Color.DS.primaryBlack

            // Subtle animated gradient overlay
            RadialGradient(
                colors: [
                    Color.DS.accentOrangeStart.opacity(pulseAnimation ? 0.15 : 0.08),
                    Color.DS.accentOrangeEnd.opacity(pulseAnimation ? 0.08 : 0.04),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 50,
                endRadius: pulseAnimation ? 600 : 500
            )
            .blur(radius: 80)

            // Secondary gradient for depth
            RadialGradient(
                colors: [
                    Color.DS.accentOrangeEnd.opacity(0.06),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 100,
                endRadius: 400
            )
            .blur(radius: 60)
        }
    }

    // MARK: - Branding Section

    private var brandingSection: some View {
        VStack(spacing: Spacing.m) {
            // Logo/App Name
            Text("GhostedAI")
                .typography(.displayLarge)
                .foregroundColor(.DS.textPrimary)
                .scaleEffect(isAnimating ? 1.0 : 0.95)

            // Tagline - warm and relatable
            Text("your anti-therapist\nfor moving on")
                .typography(.titleLarge)
                .foregroundColor(.DS.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - CTA Section

    private var ctaSection: some View {
        VStack(spacing: Spacing.m) {
            // Primary CTA - Get Started
            Button(action: handleGetStarted) {
                HStack(spacing: Spacing.s) {
                    Text("Get Started")
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

            // Secondary CTA - Sign In
            Button(action: handleSignIn) {
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.DS.textSecondary)

                    Text("Sign in")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.DS.accentOrangeStart)
                }
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.98))
        }
    }

    // MARK: - Actions

    private func handleGetStarted() {
        navigateToOnboarding = true
    }

    private func handleSignIn() {
        showSignInModal = true
    }

    // MARK: - Animations

    private func startAnimations() {
        // Stagger content appearance
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            showContent = true
        }

        withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
            isAnimating = true
        }

        // Breathing pulse animation (continuous)
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
}

// MARK: - Custom Button Style

/// Scale button style for subtle press feedback
struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
}
