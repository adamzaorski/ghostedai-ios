import SwiftUI

/// Glassmorphic secure text field matching design system
/// Used for password inputs with masked characters
struct GlassSecureField: View {
    let placeholder: String
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        SecureField(placeholder, text: $text)
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
            .textContentType(.password)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .focused($isFocused)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        VStack(spacing: Spacing.l) {
            GlassSecureField(placeholder: "Password", text: .constant(""))
            GlassSecureField(placeholder: "Confirm password", text: .constant("secretpassword"))
        }
        .padding()
    }
}
