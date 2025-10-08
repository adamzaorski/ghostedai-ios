import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    @State private var appeared = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
                // Clock icon for AI messages
                Image(systemName: "clock")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: 0x3A3A3C))
                    .frame(width: 32, height: 32)
            }

            // Message text bubble
            Text(message.text)
                .font(.system(size: 17))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    message.isUser
                        ? LinearGradient(
                            colors: [Color(hex: 0xD2691E), Color(hex: 0xA0522D)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color(hex: 0x2C2C2E), Color(hex: 0x2C2C2E)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .cornerRadius(22)

            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = true
            }
        }
    }
}
