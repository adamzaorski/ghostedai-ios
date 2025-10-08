import SwiftUI

/// Main coordinator for the 20-question onboarding flow
struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authState: AuthStateManager

    @State private var showExitConfirmation = false
    @State private var navigateToPaywall = false

    var body: some View {
        ZStack {
            // Animated gradient background
            animatedBackground

            VStack(spacing: 0) {
                // Top spacing for Back button & Progress bar overlay
                Spacer()
                    .frame(height: 60)

                // Question content with smooth transitions
                ScrollView {
                    VStack(spacing: Spacing.l) {
                        QuestionView(
                            question: viewModel.currentQuestion,
                            answer: Binding(
                                get: { viewModel.currentAnswer },
                                set: { viewModel.updateAnswer($0) }
                            ),
                            onSkip: {
                                viewModel.skipCurrentQuestion()
                            },
                            onPaywallComplete: {
                                viewModel.completePaywall()
                            },
                            onBack: {
                                handleBack()
                            }
                        )
                        .id(viewModel.currentQuestion.id)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    .padding(.horizontal, 0)
                    .padding(.top, 0)
                }

                // Bottom spacing for Continue button
                if !viewModel.isSpecialScreen {
                    Spacer()
                        .frame(height: 40)

                    // Navigation buttons (hidden on special screens that have their own CTAs)
                    navigationButtons
                        .padding(.horizontal, Spacing.l)
                        .padding(.bottom, Spacing.xxl)
                }
            }

            // Back button & progress (hidden only on special screens like review/signin/paywall)
            if !viewModel.isSpecialScreen {
                backButton
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToPaywall) {
            PaywallView()
        }
        .alert("Exit Onboarding?", isPresented: $showExitConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Your progress will be saved. You can continue later.")
        }
        .onChange(of: viewModel.navigateToPaywall) { _, newValue in
            if newValue {
                navigateToPaywall = true
            }
        }
        .onChange(of: viewModel.navigateToDashboard) { _, newValue in
            if newValue {
                // User completed onboarding - update auth state
                // This will trigger view hierarchy swap to MainTabView at root level
                print("✅ [Onboarding] Complete - updating auth state")
                Task {
                    if let user = try? await SupabaseService.shared.getCurrentUser() {
                        await MainActor.run {
                            authState.signIn(user: user)
                        }
                    }
                }
            }
        }
        .task {
            // Check authentication status and load saved answers
            await viewModel.checkAuthentication()
            viewModel.loadAnswers()
        }
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
                    Color.DS.accentOrangeStart.opacity(0.1),
                    Color.DS.accentOrangeEnd.opacity(0.05),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 500
            )
            .blur(radius: 60)
            .ignoresSafeArea()
        }
    }

    // MARK: - Back Button & Progress

    private var backButton: some View {
        VStack {
            HStack(spacing: 16) {
                // Back button
                Button(action: handleBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))

                        Text("Back")
                            .typography(.labelLarge)
                    }
                    .foregroundColor(.DS.textSecondary)
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, Spacing.s)
                }
                .buttonStyle(ScaleButtonStyle(scale: 0.95))

                // Progress indicator (stories-style, next to Back button)
                OnboardingProgressBar(
                    current: viewModel.currentQuestionIndex + 1,
                    total: viewModel.questions.count,
                    progress: viewModel.progress
                )

                Spacer()
            }
            .padding(.horizontal, Spacing.m)
            .padding(.top, Spacing.m)

            Spacer()
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        // Continue button (removed Previous button - Back arrow at top handles it)
        Button(action: viewModel.goToNextQuestion) {
            HStack(spacing: Spacing.s) {
                Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Finish" : "Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                LinearGradient(
                    colors: [
                        Color.DS.accentOrangeStart,
                        Color.DS.accentOrangeEnd
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(
                color: Color.DS.accentOrangeStart.opacity(0.3),
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!viewModel.canGoNext)
        .animation(.easeInOut(duration: 0.2), value: viewModel.canGoNext)
    }

    // MARK: - Actions

    private func handleBack() {
        if viewModel.currentQuestionIndex > 0 {
            viewModel.goToPreviousQuestion()
        } else {
            // First question - show exit confirmation
            showExitConfirmation = true
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        OnboardingContainerView()
    }
}
