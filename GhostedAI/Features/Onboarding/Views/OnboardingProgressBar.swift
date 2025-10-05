import SwiftUI

/// Progress bar showing X/20 completion for onboarding
struct OnboardingProgressBar: View {
    let current: Int
    let total: Int
    let progress: Double

    var body: some View {
        // Simple text counter - minimal and orange
        Text("\(current)/\(total)")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color.DS.accentOrangeStart)
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        VStack(spacing: Spacing.xxl) {
            OnboardingProgressBar(current: 1, total: 20, progress: 0.05)
            OnboardingProgressBar(current: 10, total: 20, progress: 0.5)
            OnboardingProgressBar(current: 20, total: 20, progress: 1.0)
        }
        .padding()
    }
}
