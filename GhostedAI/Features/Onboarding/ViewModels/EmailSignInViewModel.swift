import Foundation
import SwiftUI
import Combine
import Auth

/// ViewModel for email-based authentication (sign in / sign up)
/// Handles validation, authentication, and navigation logic
@MainActor
class EmailSignInViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var authMode: AuthMode = .signIn
    @Published var shouldNavigateToOnboarding: Bool = false
    @Published var shouldNavigateToDashboard: Bool = false

    // Store user info for passing to next screen
    var authenticatedUserId: UUID?
    var authenticatedUserEmail: String?

    // MARK: - Auth Mode

    enum AuthMode {
        case signIn
        case signUp

        var title: String {
            switch self {
            case .signIn: return "Sign in with Email"
            case .signUp: return "Create Account"
            }
        }

        var buttonText: String {
            switch self {
            case .signIn: return "Sign In"
            case .signUp: return "Create Account"
            }
        }

        var togglePrompt: AttributedString {
            switch self {
            case .signIn:
                var result = AttributedString("Don't have an account? ")
                result.foregroundColor = Color(hex: 0x8E8E93)

                var link = AttributedString("Sign up")
                link.foregroundColor = Color(hex: 0xFF6B35)
                link.underlineStyle = .single

                result.append(link)
                return result

            case .signUp:
                var result = AttributedString("Already have an account? ")
                result.foregroundColor = Color(hex: 0x8E8E93)

                var link = AttributedString("Sign in")
                link.foregroundColor = Color(hex: 0xFF6B35)
                link.underlineStyle = .single

                result.append(link)
                return result
            }
        }

        mutating func toggle() {
            self = self == .signIn ? .signUp : .signIn
        }
    }

    // MARK: - Computed Properties

    /// Email validation using regex
    var isEmailValid: Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email.trimmingCharacters(in: .whitespaces))
    }

    /// Password validation (minimum 6 characters)
    var isPasswordValid: Bool {
        password.count >= 6
    }

    /// Form is valid when both email and password meet requirements
    var isFormValid: Bool {
        isEmailValid && isPasswordValid
    }

    /// Can submit when form is valid and not currently loading
    var canSubmit: Bool {
        isFormValid && !isLoading
    }

    /// Validation error message for UI feedback
    var validationError: String? {
        if !email.isEmpty && !isEmailValid {
            return "Please enter a valid email address"
        }
        if !password.isEmpty && !isPasswordValid {
            return "Password must be at least 6 characters"
        }
        return nil
    }

    // MARK: - Authentication Methods

    /// Perform authentication based on current mode
    func authenticate() async {
        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil

        do {
            switch authMode {
            case .signIn:
                try await performSignIn()
            case .signUp:
                try await performSignUp()
            }
        } catch {
            handleAuthError(error)
        }

        isLoading = false
    }

    /// Sign in existing user
    private func performSignIn() async throws {
        print("🔐 [Auth] Starting sign-in for email: \(email)")

        let user = try await SupabaseService.shared.signIn(
            email: email.trimmingCharacters(in: .whitespaces),
            password: password
        )

        print("✅ [Auth] Sign-in successful!")
        print("👤 [Auth] User ID: \(user.id)")
        print("📧 [Auth] User Email: \(user.email ?? "N/A")")

        // Store user info for next screen
        authenticatedUserId = user.id
        authenticatedUserEmail = user.email

        // Check if user has completed onboarding
        print("🔍 [Auth] Checking onboarding status...")
        let hasCompletedOnboarding = try await checkOnboardingStatus(userId: user.id)

        if hasCompletedOnboarding {
            print("✨ [Auth] User has completed onboarding → Navigating to Dashboard")
            shouldNavigateToDashboard = true
        } else {
            print("📝 [Auth] User has incomplete/no onboarding → Navigating to Onboarding")
            shouldNavigateToOnboarding = true
        }
    }

    /// Sign up new user
    private func performSignUp() async throws {
        print("📝 [Auth] Starting sign-up for email: \(email)")

        let user = try await SupabaseService.shared.signUp(
            email: email.trimmingCharacters(in: .whitespaces),
            password: password
        )

        print("✅ [Auth] Sign-up successful!")
        print("👤 [Auth] New User ID: \(user.id)")
        print("📧 [Auth] User Email: \(user.email ?? "N/A")")
        print("🎯 [Auth] New user → Navigating to Onboarding (Screen 1)")

        // Store user info for next screen
        authenticatedUserId = user.id
        authenticatedUserEmail = user.email

        // New users always go to onboarding
        shouldNavigateToOnboarding = true
    }

    /// Check if user has completed onboarding
    private func checkOnboardingStatus(userId: UUID) async throws -> Bool {
        let answers = try await SupabaseService.shared.getOnboardingAnswers(userId: userId)
        let hasAnswers = answers != nil && !answers!.isEmpty

        if hasAnswers {
            print("📊 [Auth] Found \(answers?.count ?? 0) saved onboarding answers")
        } else {
            print("📊 [Auth] No onboarding answers found")
        }

        return hasAnswers
    }

    // MARK: - Error Handling

    /// Convert errors to user-friendly messages
    private func handleAuthError(_ error: Error) {
        print("❌ [Auth] Authentication failed with error: \(error.localizedDescription)")

        if let supabaseError = error as? SupabaseError {
            print("🔍 [Auth] SupabaseError type: \(supabaseError)")
            switch supabaseError {
            case .invalidEmail:
                errorMessage = "Please enter a valid email address"
            case .invalidPassword:
                errorMessage = "Password must be at least 6 characters"
            case .authFailed(let message):
                // Parse common auth errors
                if message.contains("User already registered") || message.contains("already exists") {
                    errorMessage = "This email is already registered. Try signing in instead."
                } else if message.contains("Invalid") || message.contains("credentials") || message.contains("password") {
                    errorMessage = "Incorrect email or password. Please try again."
                } else if message.contains("network") || message.contains("connection") {
                    errorMessage = "Connection failed. Please check your internet."
                } else {
                    errorMessage = "Authentication failed. Please try again."
                }
            case .databaseError:
                errorMessage = "Server error. Please try again later."
            case .networkError:
                errorMessage = "Connection failed. Please check your internet."
            default:
                errorMessage = "Something went wrong. Please try again."
            }
        } else {
            // Generic error
            errorMessage = "An unexpected error occurred. Please try again."
        }
    }

    // MARK: - UI Actions

    /// Toggle between sign in and sign up modes
    func toggleAuthMode() {
        authMode.toggle()
        errorMessage = nil // Clear errors when switching modes
    }

    /// Clear all form data
    func clearForm() {
        email = ""
        password = ""
        errorMessage = nil
    }
}
