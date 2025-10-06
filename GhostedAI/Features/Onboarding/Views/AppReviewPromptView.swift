import SwiftUI
import StoreKit

/// App Store review prompt screen - redesigned for Midnight Warmth aesthetic
struct AppReviewPromptView: View {
    var onContinue: () -> Void
    var onSkip: () -> Void

    @State private var showSuccessMessage = false
    @State private var opacity: Double = 0

    // Testimonials with authentic Gen Z voice
    private let testimonials = [
        Testimonial(
            initial: "S.M.",
            quote: "finally an app that doesn't feel like therapy homework",
            stars: 5
        ),
        Testimonial(
            initial: "J.K.",
            quote: "the AI gets me better than my friends did lol",
            stars: 5
        ),
        Testimonial(
            initial: "A.R.",
            quote: "literally the only breakup app that isn't cringe",
            stars: 5
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer()
                    .frame(height: 40)

                // Header
                headerSection

                Spacer()
                    .frame(height: 8)

                // Rating Card
                ratingCard

                // Testimonials
                testimonialsSection

                Spacer()
                    .frame(height: 20)

                // CTA Buttons
                ctaButtons

                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, Spacing.l)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1
            }
        }
        .overlay(
            successMessageOverlay
        )
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Enjoying the journey so far?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.DS.textPrimary)
                .multilineTextAlignment(.center)

            Text("Your support means everything to us")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.DS.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Rating Card

    private var ratingCard: some View {
        GlassCard(style: .premium) {
            VStack(spacing: 16) {
                // Large rating number with gradient
                Text("4.8")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // 5 stars
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: 0xFF6B35))
                    }
                }

                // Rating count
                Text("Based on 100K+ ratings")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: 0x8E8E93))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Testimonials Section

    private var testimonialsSection: some View {
        VStack(spacing: 16) {
            ForEach(testimonials) { testimonial in
                testimonialCard(testimonial)
            }
        }
    }

    private func testimonialCard(_ testimonial: Testimonial) -> some View {
        GlassCard(style: .premium) {
            VStack(alignment: .leading, spacing: 12) {
                // User initial and stars
                HStack {
                    // Initial badge
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)

                        Text(testimonial.initial)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Stars
                    HStack(spacing: 2) {
                        ForEach(0..<testimonial.stars, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: 0xFF6B35))
                        }
                    }
                }

                // Quote
                Text("\"\(testimonial.quote)\"")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.DS.textPrimary)
                    .lineSpacing(4)
                    .italic()
            }
            .padding(20)
        }
    }

    // MARK: - CTA Buttons

    private var ctaButtons: some View {
        VStack(spacing: 16) {
            // Leave Review button
            Button(action: handleLeaveReview) {
                HStack(spacing: 8) {
                    Text("Leave a Review")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    Text("⭐")
                        .font(.system(size: 17))
                }
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(
                    color: Color(hex: 0xFF6B35).opacity(0.4),
                    radius: 20,
                    x: 0,
                    y: 10
                )
            }
            .buttonStyle(ScaleButtonStyle())

            // Maybe later button
            Button(action: onSkip) {
                Text("Maybe later")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: 0x8E8E93))
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.98))
        }
    }

    // MARK: - Success Message Overlay

    private var successMessageOverlay: some View {
        Group {
            if showSuccessMessage {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundColor(Color(hex: 0xFF6B35))

                        Text("Thank you!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Text("Your support helps us grow")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: 0xAAAAAA))
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(hex: 0x1C1C1E))
                    )
                    .padding(40)
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Actions

    private func handleLeaveReview() {
        // Request App Store review
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }

        // Show success message
        withAnimation(.easeInOut(duration: 0.3)) {
            showSuccessMessage = true
        }

        // Auto-advance after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSuccessMessage = false
            }

            // Continue to next screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onContinue()
            }
        }
    }
}

// MARK: - Testimonial Model

struct Testimonial: Identifiable {
    let id = UUID()
    let initial: String
    let quote: String
    let stars: Int
}

// MARK: - Preview

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
