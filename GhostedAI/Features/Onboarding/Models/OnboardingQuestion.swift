import Foundation

/// Represents a single onboarding screen (question or section break)
struct OnboardingQuestion: Identifiable {
    let id: Int
    let questionText: String
    let questionType: QuestionType
    let placeholder: String?
    let subtitle: String?
    let alternativeButtonText: String?

    enum QuestionType {
        case textInput
        case multilineText
        case multipleChoice(options: [String])
        case multiSelect(options: [String])
        case slider(min: Int, max: Int)
        case numberPicker(min: Int, max: Int)
        case datePicker
        case sectionBreak(title: String?, subtitle: String?, singleLineText: String?, twoLineText: (String, String)?)
        case appReviewPrompt
        case signInPrompt
        case paywallPlaceholder
    }

    init(id: Int, questionText: String, questionType: QuestionType, placeholder: String? = nil, subtitle: String? = nil, alternativeButtonText: String? = nil) {
        self.id = id
        self.questionText = questionText
        self.questionType = questionType
        self.placeholder = placeholder
        self.subtitle = subtitle
        self.alternativeButtonText = alternativeButtonText
    }
}

/// User's answer to an onboarding question
struct OnboardingAnswer: Codable {
    let questionId: Int
    var textAnswer: String?
    var selectedOption: String?
    var selectedOptions: [String]?
    var numberAnswer: Int?
    var dateAnswer: Date?
    var skipped: Bool?

    var isEmpty: Bool {
        // Section breaks don't need answers
        if skipped == true { return false }
        if let text = textAnswer, !text.isEmpty { return false }
        if let option = selectedOption, !option.isEmpty { return false }
        if let options = selectedOptions, !options.isEmpty { return false }
        if let number = numberAnswer { return number > 0 }
        if dateAnswer != nil { return false }
        return true
    }

    /// Convert to dictionary for Supabase storage
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = ["questionId": questionId]

        if let text = textAnswer {
            dict["textAnswer"] = text
        }
        if let option = selectedOption {
            dict["selectedOption"] = option
        }
        if let options = selectedOptions {
            dict["selectedOptions"] = options
        }
        if let number = numberAnswer {
            dict["numberAnswer"] = number
        }
        if let date = dateAnswer {
            dict["dateAnswer"] = ISO8601DateFormatter().string(from: date)
        }
        if let skip = skipped {
            dict["skipped"] = skip
        }

        return dict
    }
}
