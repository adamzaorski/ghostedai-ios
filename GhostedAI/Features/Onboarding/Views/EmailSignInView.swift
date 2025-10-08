import SwiftUI
import Auth

/// Email-based authentication view (sign in / sign up)
/// Matches our glassmorphic design system with minimal, therapeutic aesthetic
struct EmailSignInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authState: AuthStateManager
    @StateObject private var viewModel = EmailSignInViewModel()
    @State private var showAlert = false
    @State private var showPassword = false
    @State private var showForgotPassword = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Black background matching our design
                Color.DS.primaryBlack
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with dismiss button
                    headerSection
                        .padding(.top, 16)
                        .padding(.horizontal, 24)

                    ScrollView {
                        VStack(spacing: Spacing.xl) {
                            // Title
                            titleSection
                                .padding(.top, Spacing.xl)

                            // Input fields
                            inputFieldsSection
                                .padding(.top, Spacing.l)

                            // Validation error (if any)
                            if let error = viewModel.validationError {
                                validationErrorView(error)
                            }

                            // Primary CTA button
                            primaryButton
                                .padding(.top, Spacing.l)

                            // Mode toggle
                            modeToggleSection
                                .padding(.top, Spacing.m)

                            Spacer(minLength: Spacing.xxl)
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Authentication Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    showAlert = false
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToOnboarding) {
                OnboardingContainerView()
            }
            .onChange(of: viewModel.shouldNavigateToDashboard) { _, newValue in
                if newValue {
                    // User signed in successfully - update auth state
                    // This will trigger view hierarchy swap to MainTabView at root level
                    print("✅ [EmailSignIn] Sign in complete - updating auth state")
                    Task {
                        if let user = try? await SupabaseService.shared.getCurrentUser() {
                            await MainActor.run {
                                authState.signIn(user: user)
                            }
                        }
                    }
                }
            }
            .onChange(of: viewModel.errorMessage) { oldValue, newValue in
                if newValue != nil {
                    showAlert = true
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            // Dismiss button (X)
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: 0x8E8E93))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }

            Spacer()
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.authMode.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.DS.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.authMode == .signIn ? "Great to see you again! Let's pick up where you left off" : "Let's get you set up! We're excited to have you here")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.DS.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(2)
        }
    }

    // MARK: - Input Fields Section

    private var inputFieldsSection: some View {
        VStack(spacing: 20) {
            // Email field with label
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.DS.textSecondary)
                    .textCase(.uppercase)
                    .kerning(0.5)

                GlassTextField(
                    placeholder: "your.email@example.com",
                    text: $viewModel.email,
                    keyboardType: .emailAddress
                )
            }

            // Password field with label and toggle
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Password")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.DS.textSecondary)
                        .textCase(.uppercase)
                        .kerning(0.5)

                    Spacer()

                    // Forgot password link (only show in sign-in mode)
                    if viewModel.authMode == .signIn {
                        Button(action: {
                            showForgotPassword = true
                        }) {
                            Text("Forgot?")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: 0xFF6B35))
                        }
                    }
                }

                // Password field with visibility toggle
                ZStack(alignment: .trailing) {
                    if showPassword {
                        GlassTextField(
                            placeholder: "Enter your password",
                            text: $viewModel.password
                        )
                    } else {
                        GlassSecureField(
                            placeholder: "Enter your password",
                            text: $viewModel.password
                        )
                    }

                    // Show/hide password toggle
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showPassword.toggle()
                        }
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: 0x8E8E93))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .padding(.trailing, 8)
                }
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }

    // MARK: - Validation Error View

    private func validationErrorView(_ error: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.DS.errorRed)

            Text(error)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.DS.errorRed)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.DS.errorRed.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.DS.errorRed.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Primary Button

    private var primaryButton: some View {
        Button(action: {
            Task {
                await viewModel.authenticate()
            }
        }) {
            HStack(spacing: 8) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Text(viewModel.authMode.buttonText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: viewModel.canSubmit
                        ? [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)]
                        : [Color(hex: 0x3A3A3C), Color(hex: 0x3A3A3C)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(viewModel.canSubmit ? 1.0 : 0.6)
        }
        .disabled(!viewModel.canSubmit)
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Mode Toggle Section

    private var modeToggleSection: some View {
        Button(action: {
            viewModel.toggleAuthMode()
        }) {
            Text(viewModel.authMode.togglePrompt)
                .font(.system(size: 15, weight: .regular))
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}

// MARK: - Forgot Password View

/// Forgot password sheet
struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.DS.primaryBlack
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: 0x8E8E93))
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    ScrollView {
                        VStack(spacing: Spacing.xl) {
                            // Icon
                            Image(systemName: "key.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: 0xFF6B35))
                                .padding(.top, Spacing.xl)

                            // Title
                            VStack(spacing: 12) {
                                Text("Reset Password")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.DS.textPrimary)

                                Text("No worries! Enter your email and we'll send you a reset link")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.DS.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                            }
                            .padding(.horizontal, 24)

                            // Email input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.DS.textSecondary)
                                    .textCase(.uppercase)
                                    .kerning(0.5)

                                GlassTextField(
                                    placeholder: "your.email@example.com",
                                    text: $email,
                                    keyboardType: .emailAddress
                                )
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, Spacing.l)

                            // Error message
                            if let error = errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.DS.errorRed)
                                    Text(error)
                                        .font(.system(size: 14))
                                        .foregroundColor(.DS.errorRed)
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                            }

                            // Success message
                            if showSuccess {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.DS.successGreen)
                                    Text("Reset link sent! Check your email")
                                        .font(.system(size: 14))
                                        .foregroundColor(.DS.successGreen)
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                            }

                            // Send button
                            Button(action: handleResetPassword) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.9)
                                    } else {
                                        Text("Send Reset Link")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
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
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .disabled(email.isEmpty || isLoading)
                            .opacity(email.isEmpty ? 0.6 : 1.0)
                            .padding(.horizontal, 24)
                            .padding(.top, Spacing.l)

                            Spacer(minLength: Spacing.xxl)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func handleResetPassword() {
        errorMessage = nil
        isLoading = true

        // TODO: Implement password reset with Supabase
        // For now, simulate success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            showSuccess = true

            // Dismiss after showing success
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
    }
}

// MARK: - Dashboard Placeholder

/// Placeholder view for authenticated dashboard
struct DashboardPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentUser: Auth.User?
    @State private var isLoading = true
    @State private var showSignOutConfirmation = false

    var body: some View {
        ZStack {
            Color.DS.primaryBlack
                .ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else {
                VStack(spacing: Spacing.xl) {
                    Spacer()

                    // Success icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.DS.successGreen)

                    // Welcome message
                    VStack(spacing: 12) {
                        Text("Welcome Back!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.DS.textPrimary)

                        if let email = currentUser?.email {
                            Text(email)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.DS.textSecondary)
                        }
                    }

                    // User info card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account Information")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.DS.textSecondary)
                            .textCase(.uppercase)
                            .kerning(0.5)

                        VStack(spacing: 12) {
                            if let userId = currentUser?.id {
                                InfoRow(label: "User ID", value: userId.uuidString)
                            }
                            if let email = currentUser?.email {
                                InfoRow(label: "Email", value: email)
                            }
                            if let createdAt = currentUser?.createdAt {
                                InfoRow(label: "Member Since", value: formatDate(createdAt))
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(hex: 0x1A1A1A))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)

                    // Info text
                    Text("You're signed in! The main dashboard with AI chat, journaling, and progress tracking will be implemented here.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.DS.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, Spacing.m)

                    Spacer()

                    // Action buttons
                    VStack(spacing: 12) {
                        // Sign out button
                        Button(action: {
                            showSignOutConfirmation = true
                        }) {
                            Text("Sign Out")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color(hex: 0x3A3A3C))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(ScaleButtonStyle())

                        // Go back button
                        Button("Close") {
                            dismiss()
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.DS.textSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                handleSignOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .task {
            await loadCurrentUser()
        }
    }

    private func loadCurrentUser() async {
        print("📱 [Dashboard] Loading current user...")
        do {
            let user = try await SupabaseService.shared.getCurrentUser()
            currentUser = user
            if let user = user {
                print("✅ [Dashboard] Loaded user: \(user.email ?? "N/A")")
            } else {
                print("⚠️ [Dashboard] No current user found")
            }
        } catch {
            print("❌ [Dashboard] Failed to load user: \(error.localizedDescription)")
        }
        isLoading = false
    }

    private func handleSignOut() {
        print("🚪 [Dashboard] Signing out...")
        Task {
            do {
                try await SupabaseService.shared.signOut()
                print("✅ [Dashboard] Sign out successful")
                dismiss()
            } catch {
                print("❌ [Dashboard] Sign out failed: \(error.localizedDescription)")
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.DS.textSecondary)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.DS.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Preview

#Preview("Sign In Mode") {
    EmailSignInView()
}

#Preview("Dashboard") {
    NavigationStack {
        DashboardPlaceholderView()
    }
}
