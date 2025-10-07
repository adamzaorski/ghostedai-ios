import SwiftUI

struct ChatView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Text("Chat - Redesigning")
                .foregroundColor(.white)
                .font(.title2)
        }
    }
}

#Preview {
    ChatView()
}
