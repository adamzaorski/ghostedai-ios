import SwiftUI

/// Instagram Stories-style visual progress bar (no text)
struct OnboardingProgressBar: View {
    let current: Int
    let total: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(
                        index < current
                            ? LinearGradient(
                                colors: [Color.DS.accentOrangeStart, Color.DS.accentOrangeEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [Color(hex: 0x2C2C2E), Color(hex: 0x2C2C2E)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .frame(height: 2)
            }
        }
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
