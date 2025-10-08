import SwiftUI
import AuthenticationServices

/// Save your progress - Sign-in prompt screen matching our design system
struct SaveProgressSignInView: View {
    var onContinue: () -> Void
    var onSkip: () -> Void

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showEmailSignIn = false

    var body: some View {
        ZStack {
            // Black background (matching our design system)
            Color.DS.primaryBlack
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar at top (100% filled)
                progressBar

                // Title
                Text("Save your progress")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)

                Spacer()

                // Sign in buttons (centered vertically)
                VStack(spacing: 16) {
                    // Sign in with Email
                    Button(action: handleEmailSignIn) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: 0xFF6B35))

                            Text("Sign in with Email")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color(hex: 0x1C1C1E))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: 0xFF6B35), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())

                    // Sign in with Apple - Custom button matching our style
                    Button(action: handleAppleSignInTap) {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)

                            Text("Sign in with Apple")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(ScaleButtonStyle())

                    // Sign in with Google
                    Button(action: handleGoogleSignIn) {
                        HStack(spacing: 12) {
                            // Google G logo placeholder (colorful)
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.red, .yellow, .green, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text("G")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                )

                            Text("Sign in with Google")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: 0xE5E5EA), lineWidth: 1)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 24)

                // Skip option
                HStack(spacing: 4) {
                    Text("Would you like to sign in later?")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(hex: 0x8E8E93))

                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: 0xFF6B35))
                            .underline()
                    }
                    .buttonStyle(ScaleButtonStyle(scale: 0.98))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)

                Spacer()
            }
        }
        .alert("Coming Soon", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInSheet(onSuccess: {
                showEmailSignIn = false
                onContinue()
            })
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.DS.surfaceElevated.opacity(0.3))
                    .frame(height: 4)

                // Progress (100% filled)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.DS.accentOrangeStart,
                                Color.DS.accentOrangeEnd
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width, height: 4)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Actions

    private func handleEmailSignIn() {
        showEmailSignIn = true
    }

    private func handleAppleSignInTap() {
        // Use the native Sign in with Apple flow
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.performRequests()

        // For now, just continue
        // TODO: Implement proper ASAuthorizationControllerDelegate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onContinue()
        }
    }

    private func handleGoogleSignIn() {
        // Placeholder for Google Sign In
        alertMessage = "Google Sign-In coming soon! For now, you can skip or use Apple."
        showingAlert = true

        // TODO: Implement Google Sign-In SDK integration
        // For now, just continue after dismissing alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onContinue()
        }
    }
}

/// Wrapper for EmailSignInView to work with onboarding flow
struct EmailSignInSheet: View {
    @StateObject private var authState = AuthStateManager()
    var onSuccess: () -> Void

    var body: some View {
        EmailSignInView()
            .environmentObject(authState)
            .onChange(of: authState.isAuthenticated) { oldValue, newValue in
                if newValue {
                    onSuccess()
                }
            }
    }
}

#Preview {
    SaveProgressSignInView(
        onContinue: {},
        onSkip: {}
    )
}
