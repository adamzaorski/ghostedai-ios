import SwiftUI

/// Sign-in options modal - polished to perfection with exact Figma specs
/// Premium iOS design with precise spacing, colors, and interactions
struct SignInOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToEmailSignIn = false
    @State private var showTerms = false
    @State private var showPrivacy = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Very dark charcoal background (#1C1C1E)
                Color(hex: 0x1C1C1E)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top section with drag indicator and dismiss button
                    topSection
                        .padding(.top, 16)

                    // Header
                    headerSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                    // Sign-in buttons
                    signInButtons
                        .padding(.horizontal, 24)

                    Spacer()

                    // Terms and privacy
                    termsSection
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                }
            }
            .fullScreenCover(isPresented: $navigateToEmailSignIn) {
                EmailSignInView()
            }
        }
        .presentationCornerRadius(24)
        .presentationBackground(Color(hex: 0x1C1C1E))
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled(false)
    }

    // MARK: - Top Section (Drag Indicator + Dismiss Button)

    private var topSection: some View {
        ZStack {
            // Centered drag indicator
            Capsule()
                .fill(Color(hex: 0x8E8E93).opacity(0.3))
                .frame(width: 36, height: 5)

            // Dismiss button (top-right)
            HStack {
                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: 0x8E8E93))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .padding(.trailing, 16)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sign In")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(.white)

            Text("Welcome back! Choose how you'd like to continue")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(Color(hex: 0x8E8E93))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Sign-In Buttons

    private var signInButtons: some View {
        VStack(spacing: 12) {
            // Sign in with Apple
            Button(action: handleAppleSignIn) {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)

                    Text("Sign in with Apple")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressableButtonStyle())

            // Sign in with Google
            Button(action: handleGoogleSignIn) {
                HStack(spacing: 8) {
                    // Colorful G placeholder
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.26, green: 0.52, blue: 0.96), // Google Blue
                                        Color(red: 0.92, green: 0.25, blue: 0.21), // Google Red
                                        Color(red: 0.98, green: 0.74, blue: 0.02), // Google Yellow
                                        Color(red: 0.20, green: 0.66, blue: 0.33)  // Google Green
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 20, height: 20)

                        Text("G")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text("Sign in with Google")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressableButtonStyle())

            // Continue with Email - Orange gradient with shadow
            Button(action: handleEmailSignIn) {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Continue with Email")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    // MARK: - Terms Section

    private var termsSection: some View {
        Text(attributedTermsText)
            .font(.system(size: 12, weight: .regular, design: .default))
            .foregroundColor(Color(hex: 0x8E8E93))
            .multilineTextAlignment(.center)
            .environment(\.openURL, OpenURLAction { url in
                // Handle taps on terms/privacy
                if url.absoluteString == "terms" {
                    showTerms = true
                    return .handled
                } else if url.absoluteString == "privacy" {
                    showPrivacy = true
                    return .handled
                }
                return .systemAction
            })
            .sheet(isPresented: $showTerms) {
                NavigationStack {
                    ZStack {
                        Color.DS.primaryBlack.ignoresSafeArea()
                        VStack {
                            Text("Terms and Conditions")
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                        }
                    }
                    .navigationTitle("Terms")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showTerms = false
                            }
                        }
                    }
                }
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showPrivacy) {
                NavigationStack {
                    ZStack {
                        Color.DS.primaryBlack.ignoresSafeArea()
                        VStack {
                            Text("Privacy Policy")
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                        }
                    }
                    .navigationTitle("Privacy")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showPrivacy = false
                            }
                        }
                    }
                }
                .presentationDetents([.large])
            }
    }

    // MARK: - Attributed Text for Terms

    private var attributedTermsText: AttributedString {
        var result = AttributedString("By continuing you agree to Ghosted AI's ")

        var terms = AttributedString("Terms and Conditions")
        terms.foregroundColor = Color(hex: 0xFF6B35)
        terms.link = URL(string: "terms")

        let and = AttributedString(" and ")

        var privacy = AttributedString("Privacy Policy")
        privacy.foregroundColor = Color(hex: 0xFF6B35)
        privacy.link = URL(string: "privacy")

        result.append(terms)
        result.append(and)
        result.append(privacy)

        return result
    }

    // MARK: - Actions

    private func handleAppleSignIn() {
        // TODO: Implement Apple Sign-In
        print("Apple Sign In tapped")
    }

    private func handleGoogleSignIn() {
        // TODO: Implement Google Sign-In
        print("Google Sign In tapped")
    }

    private func handleEmailSignIn() {
        navigateToEmailSignIn = true
    }
}

// MARK: - Pressable Button Style

/// Premium button style with scale and opacity feedback
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}


// MARK: - Preview

#Preview("Sign In Options") {
    ZStack {
        // Simulated background content
        Color.black.ignoresSafeArea()

        VStack {
            Spacer()
            Text("Welcome Screen")
                .foregroundColor(.white)
                .font(.largeTitle)
            Spacer()
        }
    }
    .sheet(isPresented: .constant(true)) {
        SignInOptionsView()
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
    }
}

#Preview("Email Sign In") {
    NavigationStack {
        EmailSignInView()
    }
}
