import SwiftUI
import StoreKit

/// App Store review prompt screen
struct AppReviewPromptView: View {
    var onContinue: () -> Void
    var onSkip: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Title
                Text("Give us a rating")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.DS.textPrimary)

                // Social proof card
                socialProofCard

                Spacer()
                    .frame(height: 20)

                // Section title
                Text("GhostedAI was made for people like you")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.DS.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                // User avatars
                HStack(spacing: -12) {
                    ForEach(0..<3) { _ in
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.DS.surfaceElevated)
                            .background(
                                Circle()
                                    .fill(Color.DS.primaryBlack)
                                    .frame(width: 54, height: 54)
                            )
                    }
                }
                .frame(maxWidth: .infinity)

                Text("5M+ GhostedAI Users")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.DS.textSecondary)
                    .frame(maxWidth: .infinity)

                // Testimonial card
                testimonialCard

                Spacer()
                    .frame(height: 20)

                // Leave Review button
                Button(action: handleLeaveReview) {
                    HStack(spacing: 8) {
                        Text("Leave a Review")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)

                        Text("⭐")
                            .font(.system(size: 17))
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

                // Maybe later button
                Button(action: onSkip) {
                    Text("Maybe later")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.DS.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(ScaleButtonStyle(scale: 0.98))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }

    // MARK: - Social Proof Card

    private var socialProofCard: some View {
        VStack(spacing: 12) {
            // Star rating
            HStack(spacing: 4) {
                Text("4.8")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color.DS.accentOrangeStart)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color.DS.accentOrangeStart)
                        }
                    }

                    Text("100K+ App Ratings")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.DS.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Testimonial Card

    private var testimonialCard: some View {
        HStack(alignment: .top, spacing: 16) {
            // Avatar
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(.DS.surfaceElevated)

            VStack(alignment: .leading, spacing: 8) {
                // Name and stars
                HStack {
                    Text("Sarah M.")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.DS.textPrimary)

                    Spacer()

                    HStack(spacing: 2) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.DS.accentOrangeStart)
                        }
                    }
                }

                // Quote
                Text("This app actually gets it. No toxic positivity BS. Just real support when I needed it most.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.DS.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Actions

    private func handleLeaveReview() {
        // Request App Store review
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }

        // Continue to next screen
        onContinue()
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        AppReviewPromptView(
            onContinue: {},
            onSkip: {}
        )
    }
}
