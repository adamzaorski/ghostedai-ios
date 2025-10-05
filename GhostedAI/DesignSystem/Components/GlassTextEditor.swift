import SwiftUI

/// Glassmorphic multiline text editor
struct GlassTextEditor: View {
    let placeholder: String
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background and border
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: 0x3A3A3C))
                .overlay(
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
                )

            // Text editor
            TextEditor(text: $text)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.DS.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .focused($isFocused)

            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.DS.textSecondary.opacity(0.7))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 140)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        VStack(spacing: Spacing.l) {
            GlassTextEditor(placeholder: "Tell us what's on your mind...", text: .constant(""))
            GlassTextEditor(placeholder: "Your thoughts here...", text: .constant("This is some sample text that shows how the editor looks with content"))
        }
        .padding()
    }
}
