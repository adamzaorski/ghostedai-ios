import SwiftUI

/// Glassmorphic text field matching design system
struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.DS.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Darker background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: 0x3A3A3C))

                    // Border with orange glow when focused
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ?
                                LinearGradient.DS.orangeAccent :
                                LinearGradient(
                                    colors: [Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: isFocused ? 2 : 1
                        )
                }
            )
            .keyboardType(keyboardType)
            .focused($isFocused)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        VStack(spacing: Spacing.l) {
            GlassTextField(placeholder: "Enter your name", text: .constant(""))
            GlassTextField(placeholder: "Your answer here...", text: .constant("Sample text"))
        }
        .padding()
    }
}
