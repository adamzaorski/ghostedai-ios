import SwiftUI

/// Chat view with AI companion - direct, empathetic, anti-therapist tone
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if viewModel.messages.isEmpty {
                        emptyState
                    } else {
                        messageList
                    }

                    // Message input at bottom
                    messageInput
                        .padding(.bottom, 8)
                }
            }
            .navigationTitle("Your AI Companion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your AI Companion")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ZStack(alignment: .top) {
            // Gradient overlay at top
            LinearGradient(
                colors: [Color.black, Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            .frame(height: 200)
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 120)

                // Animated chat bubble icons
                animatedBubbles

                Spacer()
                    .frame(height: 40)

                // Text section
                VStack(spacing: 12) {
                    Text("Start a conversation")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("No judgment. Just real talk.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(hex: 0x999999))
                }

                Spacer()
            }
        }
    }

    // Animated overlapping chat bubbles
    private var animatedBubbles: some View {
        ZStack {
            // Larger bubble (back)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .offset(x: -15, y: 10)
                .scaleEffect(viewModel.breathingScale)
                .animation(
                    .easeInOut(duration: 3).repeatForever(autoreverses: true),
                    value: viewModel.breathingScale
                )

            // Smaller bubble (front)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xFF8E53), Color(hex: 0xFF6B35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .offset(x: 20, y: -5)
                .scaleEffect(viewModel.breathingScale)
                .animation(
                    .easeInOut(duration: 3).repeatForever(autoreverses: true).delay(0.5),
                    value: viewModel.breathingScale
                )

            // Chat dots inside
            HStack(spacing: 8) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                }
            }
            .offset(x: 5, y: 0)
        }
        .onAppear {
            viewModel.startBreathingAnimation()
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isTyping {
                        typingIndicator
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation {
                    if let lastMessage = viewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isTyping) { _, isTyping in
                if isTyping {
                    withAnimation {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Typing Indicator

    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color(hex: 0xFF6B35))
                        .frame(width: 8, height: 8)
                        .offset(y: viewModel.typingOffset(for: index))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: 0x1A1A1A))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer()
        }
        .frame(maxWidth: .infinity * 0.75, alignment: .leading)
    }

    // MARK: - Message Input

    private var messageInput: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Text input
            ZStack(alignment: .leading) {
                if viewModel.inputText.isEmpty {
                    Text("Message...")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x999999))
                        .padding(.leading, 4)
                }

                TextEditor(text: $viewModel.inputText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 24, maxHeight: 96)
                    .focused($isInputFocused)
            }
            .frame(maxWidth: .infinity)

            // Send button
            Button(action: {
                viewModel.sendMessage()
                isInputFocused = false
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(viewModel.inputText.isEmpty ? Color(hex: 0x666666) : Color(hex: 0xFF6B35))
            }
            .disabled(viewModel.inputText.isEmpty)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(Color(hex: 0x0D0D0D))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if message.isUser {
                                LinearGradient(
                                    colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                Color(hex: 0x1A1A1A)
                            }
                        }
                    )
                    .clipShape(MessageBubbleShape(isUser: message.isUser))
            }

            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Message Bubble Shape

struct MessageBubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 20
        let tailSize: CGFloat = 8

        var path = Path()

        if isUser {
            // User bubble (right-aligned with tail on bottom-right)
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: .degrees(-90),
                       endAngle: .degrees(0),
                       clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius - tailSize))
            path.addLine(to: CGPoint(x: rect.maxX + tailSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                       radius: radius,
                       startAngle: .degrees(90),
                       endAngle: .degrees(180),
                       clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                       radius: radius,
                       startAngle: .degrees(180),
                       endAngle: .degrees(270),
                       clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: .degrees(180),
                       endAngle: .degrees(270),
                       clockwise: false)
        } else {
            // AI bubble (left-aligned with tail on bottom-left)
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: .degrees(-90),
                       endAngle: .degrees(0),
                       clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                       radius: radius,
                       startAngle: .degrees(0),
                       endAngle: .degrees(90),
                       clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX - tailSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - radius - tailSize))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                       radius: radius,
                       startAngle: .degrees(180),
                       endAngle: .degrees(270),
                       clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: .degrees(180),
                       endAngle: .degrees(270),
                       clockwise: false)
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    ChatView()
}
