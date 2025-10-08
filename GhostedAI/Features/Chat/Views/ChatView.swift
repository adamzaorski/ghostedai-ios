import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            // Background - pure black like reference
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Messages ScrollView
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Top padding
                            Color.clear.frame(height: 20)

                            // Messages
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }

                            // Typing indicator
                            if viewModel.isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }

                            // Bottom padding for input area
                            Color.clear.frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                    }
                    .onChange(of: viewModel.messages.count) { oldValue, newValue in
                        scrollToBottom(proxy)
                    }
                    .onChange(of: viewModel.isTyping) { oldValue, newValue in
                        scrollToBottom(proxy)
                    }
                }

                Spacer()
            }

            // Input area at bottom
            VStack {
                Spacer()
                messageInputArea
            }
        }
        .onAppear {
            loadSampleMessages()
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation {
            if viewModel.isTyping {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let lastMessage = viewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    private func loadSampleMessages() {
        // Load sample messages for demonstration
        viewModel.messages = [
            ChatMessage(text: "I understand that going through a breakup is incredibly tough. I'm here to listen and support you. How are you feeling today?", isUser: false),
            ChatMessage(text: "I'm feeling really down. It's been two weeks, and I still miss them so much.", isUser: true),
            ChatMessage(text: "It's completely normal to feel that way. Healing takes time. What's one thing you could do for yourself today, no matter how small, that might bring a moment of comfort?", isUser: false),
            ChatMessage(text: "Maybe I'll try to go for a short walk. I haven't left the house much.", isUser: true)
        ]
    }

    // MARK: - Input Area (Bottom)

    private var messageInputArea: some View {
        HStack(spacing: 12) {
            // Text input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .lineLimit(1...6)
                    .padding(.leading, 20)
                    .padding(.trailing, 8)
                    .padding(.vertical, 14)
                    .focused($isInputFocused)

                // Microphone button (inside text field)
                if messageText.isEmpty {
                    Button {
                        // Voice input action
                        print("🎤 Microphone tapped")
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: 0x8E8E93))
                    }
                    .padding(.trailing, 16)
                }
            }
            .background(Color(hex: 0x1C1C1E))
            .cornerRadius(25)

            // Send button
            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundColor(messageText.isEmpty ? Color(hex: 0x3A3A3C) : Color(hex: 0xFF6B35))
                    .frame(width: 50, height: 50)
                    .background(Color(hex: 0x1C1C1E))
                    .clipShape(Circle())
            }
            .disabled(messageText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let text = messageText
        messageText = ""
        isInputFocused = false

        // Add user message
        let userMessage = ChatMessage(text: text, isUser: true)
        viewModel.messages.append(userMessage)

        // Trigger AI response
        viewModel.isTyping = true

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            await MainActor.run {
                let aiResponse = ChatMessage(text: "That's a wonderful step. Even a short walk can help clear your mind and lift your spirits a bit. I'm proud of you for considering it.", isUser: false)
                viewModel.messages.append(aiResponse)
                viewModel.isTyping = false
            }
        }
    }
}

#Preview {
    ChatView()
}
