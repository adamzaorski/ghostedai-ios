import SwiftUI

/// Glassmorphic slider for 1-10 scale questions
struct GlassSlider: View {
    @Binding var value: Double
    let minValue: Double
    let maxValue: Double
    let step: Double

    var body: some View {
        VStack(spacing: Spacing.m) {
            // Current value display
            Text("\(Int(value))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.DS.accentOrangeStart,
                            Color.DS.accentOrangeEnd
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // Slider
            VStack(spacing: Spacing.s) {
                Slider(
                    value: $value,
                    in: minValue...maxValue,
                    step: step
                )
                .tint(Color.DS.accentOrangeStart)

                // Min/Max labels
                HStack {
                    Text("\(Int(minValue))")
                        .typography(.labelMedium)
                        .foregroundColor(.DS.textSecondary)

                    Spacer()

                    Text("\(Int(maxValue))")
                        .typography(.labelMedium)
                        .foregroundColor(.DS.textSecondary)
                }
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        VStack(spacing: Spacing.xxl) {
            GlassSlider(
                value: .constant(5),
                minValue: 1,
                maxValue: 10,
                step: 1
            )

            GlassSlider(
                value: .constant(8),
                minValue: 1,
                maxValue: 10,
                step: 1
            )
        }
        .padding()
    }
}
