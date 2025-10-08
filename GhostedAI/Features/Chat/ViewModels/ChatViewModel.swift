import Foundation
import SwiftUI
import Combine

/// Chat message model
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date

    init(id: UUID = UUID(), text: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

/// ViewModel for AI companion chat
/// Handles message sending, mock AI responses, and typing animations
@MainActor
class ChatViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isTyping: Bool = false
    @Published var breathingScale: CGFloat = 1.0

    // MARK: - Private Properties

    private var typingAnimationTimer: Timer?
    private var typingDotOffsets: [CGFloat] = [0, 0, 0]

    // MARK: - Initialization

    init() {
        startTypingAnimation()
    }

    deinit {
        typingAnimationTimer?.invalidate()
    }

    // MARK: - Public Methods

    /// Start breathing animation for empty state bubbles
    func startBreathingAnimation() {
        breathingScale = 1.05
    }

    /// Send user message and trigger AI response
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else { return }

        print("💬 [Chat] User message sent: \(trimmedText)")

        // Add user message
        let userMessage = ChatMessage(text: trimmedText, isUser: true)
        messages.append(userMessage)

        // Clear input
        inputText = ""

        // Generate AI response after delay
        Task {
            await generateAIResponse(to: trimmedText)
        }
    }

    /// Get typing indicator offset for animated dot
    func typingOffset(for index: Int) -> CGFloat {
        guard index < typingDotOffsets.count else { return 0 }
        return typingDotOffsets[index]
    }

    // MARK: - Private Methods

    /// Generate mock AI response based on user message
    private func generateAIResponse(to userMessage: String) async {
        print("🤖 [Chat] AI responding...")

        // Show typing indicator
        isTyping = true

        // Wait 1.5 seconds (simulating AI "thinking")
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Generate response based on keywords
        let response = mockAIResponse(for: userMessage)

        print("🤖 [Chat] AI response: \(response)")

        // Hide typing indicator
        isTyping = false

        // Add AI message
        let aiMessage = ChatMessage(text: response, isUser: false)
        messages.append(aiMessage)
    }

    /// Generate mock AI response based on keywords (will be replaced with real AI later)
    private func mockAIResponse(for message: String) -> String {
        let lowercased = message.lowercased()

        // Keyword-based responses (direct, empathetic, anti-therapist tone)
        if lowercased.contains("miss") || lowercased.contains("missing") {
            return "Missing them doesn't mean you should text them. It means you cared."
        }

        if lowercased.contains("text") || lowercased.contains("message") || lowercased.contains("call") {
            return "Put the phone down. Seriously."
        }

        if lowercased.contains("why") {
            return "Some things don't have answers. That's not your fault."
        }

        if lowercased.contains("help") || lowercased.contains("what do i do") {
            return "You're already doing the hard part by not reaching out."
        }

        if lowercased.contains("sad") || lowercased.contains("hurt") || lowercased.contains("pain") {
            return "Feel it. Don't fight it. It'll pass. Not today, but it will."
        }

        if lowercased.contains("closure") {
            return "Closure is something you give yourself. Stop waiting for permission."
        }

        if lowercased.contains("mistake") || lowercased.contains("wrong") {
            return "You're not overreacting. You're finally reacting correctly."
        }

        if lowercased.contains("back") || lowercased.contains("together") {
            return "The version of them you miss doesn't exist anymore. Let it go."
        }

        if lowercased.contains("heal") || lowercased.contains("better") {
            return "Healing isn't linear. Some days you'll feel like you're back at zero. You're not."
        }

        if lowercased.contains("alone") || lowercased.contains("lonely") {
            return "Being alone isn't the same as being lonely. Give it time."
        }

        // Default response
        return "I hear you. What do you need right now?"
    }

    /// Start typing indicator animation (bouncing dots)
    private func startTypingAnimation() {
        typingAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            for i in 0..<3 {
                let delay = Double(i) * 0.2
                let phase = Date().timeIntervalSince1970 + delay
                let offset = sin(phase * 4) * 3 // Bounce between -3 and 3

                Task { @MainActor in
                    self.typingDotOffsets[i] = offset
                }
            }
        }
    }
}
