import SwiftUI

/// Glassmorphic number picker for age selection
struct GlassNumberPicker: View {
    @Binding var selectedNumber: Int
    let minValue: Int
    let maxValue: Int

    var body: some View {
        VStack(spacing: Spacing.l) {
            // Current value display - BOLD and punchy
            Text("\(selectedNumber)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
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
                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: selectedNumber)

            // Picker wheel - transparent background with fade mask
            ZStack {
                // Picker
                Picker("Number", selection: $selectedNumber) {
                    ForEach(minValue...maxValue, id: \.self) { number in
                        Text("\(number)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.DS.textPrimary)
                            .tag(number)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 140)

                // Fade mask overlay for surrounding numbers
                VStack {
                    LinearGradient(
                        colors: [
                            Color(hex: 0x2C2C2E),
                            Color(hex: 0x2C2C2E).opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 40)

                    Spacer()

                    LinearGradient(
                        colors: [
                            Color(hex: 0x2C2C2E).opacity(0),
                            Color(hex: 0x2C2C2E)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 40)
                }
                .frame(height: 140)
                .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        GlassNumberPicker(
            selectedNumber: .constant(25),
            minValue: 18,
            maxValue: 100
        )
        .padding()
    }
}
