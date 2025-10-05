import SwiftUI

/// Minimal onboarding question view - TikTok-native aesthetic
struct QuestionView: View {
    let question: OnboardingQuestion
    @Binding var answer: OnboardingAnswer
    var onSkip: (() -> Void)?

    // Local state for inputs
    @State private var textInput: String = ""
    @State private var selectedOption: String = ""
    @State private var selectedOptions: Set<String> = []
    @State private var sliderValue: Double = 5
    @State private var numberValue: Int = 25
    @State private var selectedDate: Date = Date()

    var body: some View {
        Group {
            switch question.questionType {
            case .sectionBreak:
                sectionBreakView

            case .appReviewPrompt:
                AppReviewPromptView(
                    onContinue: { onSkip?() },
                    onSkip: { onSkip?() }
                )

            case .signInPrompt:
                SaveProgressSignInView(
                    onContinue: { onSkip?() },
                    onSkip: { onSkip?() }
                )

            case .paywallPlaceholder:
                PaywallPlaceholderView(
                    onStartTrial: { onSkip?() },
                    onSeeAllPlans: { /* TODO: Show all plans */ }
                )

            default:
                // Regular question screen
                questionView
            }
        }
        .onAppear {
            loadExistingAnswer()
        }
        .onChange(of: textInput) { _, newValue in
            updateAnswer(textAnswer: newValue)
        }
        .onChange(of: selectedOption) { _, newValue in
            updateAnswer(selectedOption: newValue)
        }
        .onChange(of: selectedOptions) { _, newValue in
            updateAnswer(selectedOptions: Array(newValue))
        }
        .onChange(of: sliderValue) { _, newValue in
            updateAnswer(numberAnswer: Int(newValue))
        }
        .onChange(of: numberValue) { _, newValue in
            updateAnswer(numberAnswer: newValue)
        }
        .onChange(of: selectedDate) { _, newValue in
            updateAnswer(dateAnswer: newValue)
        }
    }

    // MARK: - Section Break View

    private var sectionBreakView: some View {
        VStack(spacing: 32) {
            Spacer()

            // 4x5 image placeholder
            imagePlaceholder

            // Content
            sectionBreakContent

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: 0x2C2C2E),
                        Color(hex: 0x1C1C1E)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .frame(width: 200, height: 250)
    }

    @ViewBuilder
    private var sectionBreakContent: some View {
        if case .sectionBreak(let title, let subtitle, let singleLine, let twoLine) = question.questionType {
            VStack(spacing: 16) {
                // Title
                if let title = title {
                    Text(title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.DS.textPrimary)
                        .multilineTextAlignment(.center)
                        .textCase(.uppercase)
                        .tracking(1.2)
                }

                // Subtitle
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.DS.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Single line text
                if let singleLine = singleLine {
                    Text(singleLine)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.DS.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                // Two line text
                if let twoLine = twoLine {
                    VStack(spacing: 12) {
                        Text(twoLine.0)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.DS.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(twoLine.1)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.DS.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Question View (Minimal, No Card)

    private var questionView: some View {
        VStack(spacing: 32) {
            // Question text - large, white, center-aligned
            VStack(spacing: 12) {
                Text(question.questionText)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.DS.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Subtitle (if present)
                if let subtitle = question.subtitle {
                    Text(subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.DS.textSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }

            // Question input
            questionInput

            // Alternative button (skip/alternative action)
            if let altText = question.alternativeButtonText {
                Button(action: { onSkip?() }) {
                    Text(altText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.DS.accentOrangeStart)
                }
                .buttonStyle(ScaleButtonStyle(scale: 0.98))
                .padding(.top, 16)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Question Input View

    @ViewBuilder
    private var questionInput: some View {
        switch question.questionType {
        case .textInput:
            MinimalTextField(
                placeholder: question.placeholder ?? "Your answer...",
                text: $textInput
            )

        case .multilineText:
            MinimalTextField(
                placeholder: question.placeholder ?? "Tell us more...",
                text: $textInput
            )

        case .multipleChoice(let options):
            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    MinimalOptionButton(
                        text: option,
                        isSelected: selectedOption == option,
                        isMultiSelect: false,
                        action: {
                            selectedOption = option
                        }
                    )
                }
            }

        case .multiSelect(let options):
            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    MinimalOptionButton(
                        text: option,
                        isSelected: selectedOptions.contains(option),
                        isMultiSelect: true,
                        action: {
                            if selectedOptions.contains(option) {
                                selectedOptions.remove(option)
                            } else {
                                selectedOptions.insert(option)
                            }
                        }
                    )
                }
            }

        case .slider(let min, let max):
            GlassSlider(
                value: $sliderValue,
                minValue: Double(min),
                maxValue: Double(max),
                step: 1
            )

        case .numberPicker(let min, let max):
            MinimalNumberPicker(
                selectedNumber: $numberValue,
                minValue: min,
                maxValue: max
            )

        case .datePicker:
            GlassDatePicker(selectedDate: $selectedDate)

        case .sectionBreak, .appReviewPrompt, .signInPrompt, .paywallPlaceholder:
            EmptyView()
        }
    }

    // MARK: - Answer Management

    private func loadExistingAnswer() {
        if let text = answer.textAnswer {
            textInput = text
        }
        if let option = answer.selectedOption {
            selectedOption = option
        }
        if let options = answer.selectedOptions {
            selectedOptions = Set(options)
        }
        if let number = answer.numberAnswer {
            sliderValue = Double(number)
            numberValue = number
        }
        if let date = answer.dateAnswer {
            selectedDate = date
        }
    }

    private func updateAnswer(
        textAnswer: String? = nil,
        selectedOption: String? = nil,
        selectedOptions: [String]? = nil,
        numberAnswer: Int? = nil,
        dateAnswer: Date? = nil
    ) {
        var updatedAnswer = answer

        if let text = textAnswer {
            updatedAnswer.textAnswer = text
        }
        if let option = selectedOption {
            updatedAnswer.selectedOption = option
        }
        if let options = selectedOptions {
            updatedAnswer.selectedOptions = options
        }
        if let number = numberAnswer {
            updatedAnswer.numberAnswer = number
        }
        if let date = dateAnswer {
            updatedAnswer.dateAnswer = date
        }

        answer = updatedAnswer
    }
}

// MARK: - Minimal Components

/// Minimal text field - no background, just border
struct MinimalTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 18, weight: .regular))
            .foregroundColor(.DS.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ?
                            Color.DS.accentOrangeStart :
                            Color.white.opacity(0.2),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .focused($isFocused)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

/// Minimal option button - pill shape with subtle border
struct MinimalOptionButton: View {
    let text: String
    let isSelected: Bool
    let isMultiSelect: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Checkmark/radio for multi-select
                if isMultiSelect {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? Color.DS.accentOrangeStart : .DS.textSecondary.opacity(0.5))
                }

                // Option text
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.DS.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ?
                            Color.DS.accentOrangeStart :
                            Color.white.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1
                    )
                    .shadow(
                        color: isSelected ? Color.DS.accentOrangeStart.opacity(0.3) : Color.clear,
                        radius: isSelected ? 8 : 0,
                        x: 0,
                        y: 0
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}

/// Minimal number picker - huge orange number
struct MinimalNumberPicker: View {
    @Binding var selectedNumber: Int
    let minValue: Int
    let maxValue: Int

    var body: some View {
        VStack(spacing: 24) {
            // Huge orange number
            Text("\(selectedNumber)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
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
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedNumber)

            // Picker wheel with white text
            Picker("Number", selection: $selectedNumber) {
                ForEach(minValue...maxValue, id: \.self) { number in
                    Text("\(number)")
                        .font(.system(size: 20))
                        .foregroundColor(.DS.textPrimary)
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .colorScheme(.dark)
        }
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        QuestionView(
            question: OnboardingQuestion(
                id: 2,
                questionText: "What's their first name or nickname?",
                questionType: .textInput,
                placeholder: "Enter name",
                subtitle: "we'll use it to roast them later."
            ),
            answer: .constant(OnboardingAnswer(questionId: 2))
        )
    }
}
