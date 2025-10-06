import SwiftUI

/// Placeholder for daily check-in feature
struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.DS.primaryBlack
                    .ignoresSafeArea()

                VStack(spacing: Spacing.xl) {
                    Spacer()

                    // Icon
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color(hex: 0xFF6B35))

                    // Title
                    VStack(spacing: 12) {
                        Text("Daily Check-in")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.DS.textPrimary)

                        Text("Coming soon! We're building a personalized daily check-in to track your emotional journey and progress.")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.DS.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 32)
                    }

                    // Feature list
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "face.smiling", text: "Track your mood daily")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "See emotional trends over time")
                        FeatureRow(icon: "flame.fill", text: "Build & maintain your streak")
                        FeatureRow(icon: "trophy.fill", text: "Earn badges for consistency")
                    }
                    .padding(24)
                    .background(Color(hex: 0x1A1A1A))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 32)

                    Spacer()

                    // Close button
                    Button(action: { dismiss() }) {
                        Text("Got it")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
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
                    .padding(.horizontal, 32)
                    .padding(.bottom, Spacing.xl)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: 0xFF6B35))
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.DS.textPrimary)
        }
    }
}

#Preview {
    CheckInView()
}
