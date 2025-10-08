import SwiftUI

struct TypingIndicatorView: View {
    @State private var dotScale: [CGFloat] = [1, 1, 1]
    @State private var appeared = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Clock icon
            Image(systemName: "clock")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: 0x3A3A3C))
                .frame(width: 32, height: 32)

            // Dots bubble
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .scaleEffect(dotScale[index])
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(Color(hex: 0x2C2C2E))
            .cornerRadius(22)

            Spacer(minLength: 60)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = true
            }
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            for index in 0..<3 {
                withAnimation(
                    Animation.easeInOut(duration: 0.4)
                        .delay(Double(index) * 0.15)
                ) {
                    dotScale[index] = dotScale[index] == 1.0 ? 1.4 : 1.0
                }
            }
        }
    }
}
