import SwiftUI

/// Paywall placeholder screen matching Cal AI design
struct PaywallPlaceholderView: View {
    var onStartTrial: () -> Void
    var onSeeAllPlans: () -> Void
    var onBack: (() -> Void)? = nil

    @State private var selectedPlan: PlanType = .individual
    @State private var isLoading = false

    enum PlanType {
        case family
        case individual
    }

    var body: some View {
        ZStack {
            // White background for paywall (different from rest of app)
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar at top (100%)
                progressBar

                ScrollView {
                    VStack(spacing: 32) {
                        // Title
                        Text("Start Your 3-Day Free Trial to Continue")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 24)

                        // Timeline
                        timelineSection

                        // Pricing cards
                        pricingSection

                        // No Payment Due Now
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)

                            Text("No Payment Due Now")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // CTA button
                ctaButton

                // Fine print
                Text("3 days free, then $29.99 per year")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)

                // Terms and Privacy
                HStack(spacing: 16) {
                    Button("Terms") {
                        // TODO: Show terms
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                    Button("Privacy Policy") {
                        // TODO: Show privacy
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            // Back button overlay (top-left)
            if let onBack = onBack {
                VStack {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(ScaleButtonStyle(scale: 0.95))
                        .padding(.leading, Spacing.m)
                        .padding(.top, 12)

                        Spacer()
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)

                // Progress (100%)
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

    // MARK: - Timeline Section

    private var timelineSection: some View {
        VStack(spacing: 24) {
            timelineItem(
                icon: "lock.open.fill",
                title: "Today",
                description: "Unlock all app features: AI chat, streak tracking, daily quotes, and more.",
                isFirst: true
            )

            timelineItem(
                icon: "bell.fill",
                title: "In 2 Days - Reminder",
                description: "We'll send you a reminder that your trial is ending soon."
            )

            timelineItem(
                icon: "star.fill",
                title: "In 3 Days - Billing Starts",
                description: "Your subscription will begin on \(formattedDate) unless you cancel before.",
                isLast: true
            )
        }
    }

    private func timelineItem(icon: String, title: String, description: String, isFirst: Bool = false, isLast: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon with connecting line
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.DS.accentOrangeStart.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(Color.DS.accentOrangeStart)
                    )

                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 40)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    // MARK: - Pricing Section

    private var pricingSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Family Plan
                pricingCard(
                    badge: "2-6 Members",
                    title: "Family Plan",
                    price: "$4.99/mo",
                    planType: .family,
                    isSelected: selectedPlan == .family
                )

                // Individual Plan
                pricingCard(
                    badge: "3 days free",
                    title: "Individual",
                    price: "$2.49/mo",
                    planType: .individual,
                    isSelected: selectedPlan == .individual
                )
            }

            Button(action: onSeeAllPlans) {
                Text("See all plans")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                    .underline()
            }
        }
    }

    private func pricingCard(badge: String, title: String, price: String, planType: PlanType, isSelected: Bool) -> some View {
        Button(action: { selectedPlan = planType }) {
            VStack(alignment: .leading, spacing: 12) {
                // Badge
                Text(badge)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.black : Color.gray)
                    )

                // Title
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)

                // Price
                Text(price)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color.DS.accentOrangeStart : .gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.DS.accentOrangeStart : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button(action: handleStartTrial) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                }

                Text(isLoading ? "Starting Trial..." : "Start My 3-Day Free Trial")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 24)
        .disabled(isLoading)
    }

    // MARK: - Actions

    private func handleStartTrial() {
        // Show loading state
        isLoading = true

        // TODO: Replace with actual Adapty subscription flow
        // Simulate subscription process with 1 second delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            onStartTrial()
        }
    }

    // MARK: - Helper

    private var formattedDate: String {
        let date = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    PaywallPlaceholderView(
        onStartTrial: {},
        onSeeAllPlans: {},
        onBack: { print("Back tapped") }
    )
}
