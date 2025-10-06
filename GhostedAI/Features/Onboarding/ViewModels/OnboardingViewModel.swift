import Foundation
import SwiftUI
import Combine
import Auth

/// Manages the onboarding flow state and user answers
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var answers: [Int: OnboardingAnswer] = [:]
    @Published var showExitConfirmation: Bool = false
    @Published var navigateToPaywall: Bool = false
    @Published var navigateToDashboard: Bool = false
    @Published var isUserAuthenticated: Bool = false

    let questions: [OnboardingQuestion] = [
        // SECTION 1: THE DAMAGE REPORT

        // Screen 1: Section break
        OnboardingQuestion(
            id: 1,
            questionText: "",
            questionType: .sectionBreak(
                title: "THE DAMAGE REPORT",
                subtitle: "Let's get the heartbreak deets first",
                singleLineText: nil,
                twoLineText: nil
            )
        ),

        // Screen 2
        OnboardingQuestion(
            id: 2,
            questionText: "What's their first name or nickname?",
            questionType: .textInput,
            placeholder: "enter name",
            subtitle: "we'll use it to roast them later."
        ),

        // Screen 3
        OnboardingQuestion(
            id: 3,
            questionText: "How long were you two together?",
            questionType: .multipleChoice(options: [
                "under 3 months (a fling that hit hard)",
                "3–12 months (just enough to destroy me)",
                "1–3 years (we built a fake life together)",
                "3+ years (soulmate-core, now I'm dead inside)"
            ])
        ),

        // Screen 4
        OnboardingQuestion(
            id: 4,
            questionText: "When did the breakup go down?",
            questionType: .datePicker,
            alternativeButtonText: "i don't remember"
        ),

        // Screen 5
        OnboardingQuestion(
            id: 5,
            questionText: "Who ended it?",
            questionType: .multipleChoice(options: [
                "i did",
                "they did",
                "mutual… but not really",
                "idk, it kinda just happened"
            ])
        ),

        // Screen 6: Section break
        OnboardingQuestion(
            id: 6,
            questionText: "",
            questionType: .sectionBreak(
                title: nil,
                subtitle: nil,
                singleLineText: "Okay, we got the tea. Let's keep going.",
                twoLineText: nil
            )
        ),

        // SECTION 2: BTW, WHO ARE YOU?

        // Screen 7: Section break
        OnboardingQuestion(
            id: 7,
            questionText: "",
            questionType: .sectionBreak(
                title: "BTW, WHO ARE YOU?",
                subtitle: "Because we actually care.",
                singleLineText: nil,
                twoLineText: nil
            )
        ),

        // Screen 8
        OnboardingQuestion(
            id: 8,
            questionText: "What's your first name?",
            questionType: .textInput,
            placeholder: "your name"
        ),

        // Screen 9
        OnboardingQuestion(
            id: 9,
            questionText: "How old are you?",
            questionType: .numberPicker(min: 18, max: 100)
        ),

        // Screen 10
        OnboardingQuestion(
            id: 10,
            questionText: "What's your gender identity?",
            questionType: .multipleChoice(options: [
                "male",
                "female",
                "prefer not to say"
            ])
        ),

        // Screen 11
        OnboardingQuestion(
            id: 11,
            questionText: "What's your ex's gender identity?",
            questionType: .multipleChoice(options: [
                "male",
                "female",
                "prefer not to say"
            ])
        ),

        // Screen 12
        OnboardingQuestion(
            id: 12,
            questionText: "How old were they?",
            questionType: .numberPicker(min: 18, max: 100),
            alternativeButtonText: "i don't know / who cares…"
        ),

        // Screen 13: Section break
        OnboardingQuestion(
            id: 13,
            questionText: "",
            questionType: .sectionBreak(
                title: nil,
                subtitle: nil,
                singleLineText: ("Logged. You = you. Them = not your problem anymore."),
                twoLineText: nil,
            )
        ),

        // SECTION 3: YOUR BREAKUP SITUATION

        // Screen 14: Section break
        OnboardingQuestion(
            id: 14,
            questionText: "",
            questionType: .sectionBreak(
                title: "YOUR BREAKUP SITUATION",
                subtitle: "This is where we start mapping your spiral.",
                singleLineText: nil,
                twoLineText: nil
            )
        ),

        // Screen 15
        OnboardingQuestion(
            id: 15,
            questionText: "What's your current breakup status?",
            questionType: .multipleChoice(options: [
                "i want them back",
                "i want to move on",
                "i'm still unsure",
                "i feel completely lost"
            ])
        ),

        // Screen 16
        OnboardingQuestion(
            id: 16,
            questionText: "Are you two still in contact?",
            questionType: .multipleChoice(options: [
                "hell no",
                "i keep slipping",
                "we talk sometimes",
                "i stalk them like a detective"
            ])
        ),

        // Screen 17
        OnboardingQuestion(
            id: 17,
            questionText: "What's your biggest temptation right now?",
            questionType: .multipleChoice(options: [
                "texting them",
                "checking socials",
                "hooking up to distract myself",
                "overthinking everything",
                "just rotting and feeling sorry for myself"
            ])
        ),

        // Screen 18
        OnboardingQuestion(
            id: 18,
            questionText: "What hurts the most right now?",
            questionType: .multiSelect(options: [
                "loneliness",
                "jealousy",
                "missing the routine",
                "not feeling enough",
                "guilt or regret",
                "just empty af"
            ])
        ),

        // Screen 19: Section break
        OnboardingQuestion(
            id: 19,
            questionText: "",
            questionType: .sectionBreak(
                title: nil,
                subtitle: nil,
                singleLineText: nil,
                twoLineText: ("Pain: documented.", "We've all been there. No judgment.")
            )
        ),

        // SECTION 4: YOUR TRANSFORMATION GAMEPLAN

        // Screen 20: Section break
        OnboardingQuestion(
            id: 20,
            questionText: "",
            questionType: .sectionBreak(
                title: "YOUR PERSONAL GAMEPLAN",
                subtitle: "Time to turn pain into something.",
                singleLineText: nil,
                twoLineText: nil
            )
        ),

        // Screen 21
        OnboardingQuestion(
            id: 21,
            questionText: "Why are you using GhostedAI?",
            questionType: .multipleChoice(options: [
                "i need someone to talk to",
                "i need help staying no-contact",
                "i want to focus on self-improvement",
                "i want revenge success",
                "idk. I'm just broken"
            ])
        ),

        // Screen 22
        OnboardingQuestion(
            id: 22,
            questionText: "Where do you want to level up?",
            questionType: .multiSelect(options: [
                "body (gym, diet, looking hot af)",
                "mindset (less anxious, more peace)",
                "career/money (boss mode)",
                "dating confidence",
                "creativity & passions",
                "i just want to stop crying, man"
            ])
        ),

        // Screen 23
        OnboardingQuestion(
            id: 23,
            questionText: "What kind of 'anti-therapist' friend do you need?",
            questionType: .multipleChoice(options: [
                "savage reality check",
                "sarcastic soft hype friend",
                "gym bro / gal",
                "poetic moody soul",
                "i want to switch based on mood"
            ])
        ),

        // Screen 24
        OnboardingQuestion(
            id: 24,
            questionText: "Swearing?",
            questionType: .multipleChoice(options: [
                "full unhinged pls",
                "mild chaos",
                "keep it mostly clean-ish (almost impossible)"
            ])
        ),

        // Screen 25
        OnboardingQuestion(
            id: 25,
            questionText: "Last one! How did you hear about Ghosted AI?",
            questionType: .multipleChoice(options: [
                "TikTok",
                "Instagram",
                "Twitter",
                "Google",
                "Apple Store / Google Play Store",
                "word of mouth",
                "can't remember / who cares..."
            ])
        ),

        // Screen 26: Section break (moved to 28)
        OnboardingQuestion(
            id: 26,
            questionText: "",
            questionType: .sectionBreak(
                title: nil,
                subtitle: nil,
                singleLineText: nil,
                twoLineText: ("Alright, let's lock in.", "We're ready to ride.")
            )
        ),

        // Screen 27: NEW - App Store Review Prompt
        OnboardingQuestion(
            id: 27,
            questionText: "",
            questionType: .appReviewPrompt
        ),

        // Screen 28: NEW - Save Your Progress (Sign-in)
        OnboardingQuestion(
            id: 28,
            questionText: "",
            questionType: .signInPrompt
        ),

        // Screen 29: NEW - Paywall Placeholder
        OnboardingQuestion(
            id: 29,
            questionText: "",
            questionType: .paywallPlaceholder
        ),

        // Screen 30: Future Adapty Paywall (placeholder for now - handled by navigation)
    ]

    var currentQuestion: OnboardingQuestion {
        questions[currentQuestionIndex]
    }

    var currentAnswer: OnboardingAnswer {
        answers[currentQuestion.id] ?? OnboardingAnswer(questionId: currentQuestion.id)
    }

    var progress: Double {
        Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    var canGoNext: Bool {
        // Special screens can always advance (they handle their own buttons)
        switch currentQuestion.questionType {
        case .sectionBreak, .appReviewPrompt, .signInPrompt, .paywallPlaceholder:
            return true
        default:
            // Regular questions need valid answers
            return !currentAnswer.isEmpty
        }
    }

    var canGoBack: Bool {
        currentQuestionIndex > 0
    }

    var isSectionBreak: Bool {
        if case .sectionBreak = currentQuestion.questionType {
            return true
        }
        return false
    }

    var isSpecialScreen: Bool {
        // Special screens that handle their own navigation
        switch currentQuestion.questionType {
        case .appReviewPrompt, .signInPrompt, .paywallPlaceholder:
            return true
        default:
            return false
        }
    }

    // MARK: - Actions

    func updateAnswer(_ answer: OnboardingAnswer) {
        answers[currentQuestion.id] = answer
        saveAnswersLocally()
    }

    func goToNextQuestion() {
        guard canGoNext else { return }

        // Check if we're about to navigate to screen 28 (Save Progress / Sign-In)
        // Screen 28 has ID 28 in the questions array
        let nextIndex = currentQuestionIndex + 1
        if nextIndex < questions.count {
            let nextQuestion = questions[nextIndex]

            // If next screen is the sign-in prompt (screen 28) and user is authenticated, skip it
            if case .signInPrompt = nextQuestion.questionType, isUserAuthenticated {
                print("⏭️ [Onboarding] User authenticated - skipping screen 28 (Save Progress)")
                // Skip screen 28 and go directly to screen 29
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentQuestionIndex += 2 // Skip screen 28
                }
                return
            }
        }

        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentQuestionIndex += 1
            }
        } else {
            // Finished all questions
            completeOnboarding()
        }
    }

    func goToPreviousQuestion() {
        guard canGoBack else { return }

        // Check if current screen is 29 and user is authenticated (meaning we skipped 28)
        // If so, go back 2 screens to skip over the hidden screen 28
        let currentQuestion = questions[currentQuestionIndex]
        if case .paywallPlaceholder = currentQuestion.questionType, isUserAuthenticated {
            // Check if previous screen would be sign-in prompt (28)
            if currentQuestionIndex > 1 {
                let prevQuestion = questions[currentQuestionIndex - 1]
                if case .signInPrompt = prevQuestion.questionType {
                    print("⏮️ [Onboarding] User authenticated - skipping back over screen 28")
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentQuestionIndex -= 2 // Skip screen 28 going backwards
                    }
                    return
                }
            }
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentQuestionIndex -= 1
        }
    }

    func skipCurrentQuestion() {
        // Mark as skipped and advance
        var answer = currentAnswer
        answer.skipped = true
        updateAnswer(answer)
        goToNextQuestion()
    }

    func completeOnboarding() {
        print("🎉 [Onboarding] Completing onboarding - saving to Supabase...")

        // Save completion state locally
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        saveAnswersLocally()

        // Save to Supabase asynchronously
        Task {
            await saveToSupabase()
        }

        // Navigate to paywall
        navigateToPaywall = true
    }

    /// Save onboarding answers and user profile to Supabase
    private func saveToSupabase() async {
        print("💾 [Onboarding] Starting Supabase save...")

        do {
            // Get current user
            guard let user = try await SupabaseService.shared.getCurrentUser() else {
                print("❌ [Onboarding] No authenticated user - cannot save to Supabase")
                return
            }

            let userId = user.id
            print("👤 [Onboarding] User ID: \(userId)")
            print("📝 [Onboarding] Total answers to save: \(answers.count)")
            print("📝 [Onboarding] Raw answers dictionary:")
            for (index, answer) in answers.sorted(by: { $0.key < $1.key }) {
                print("   Q\(index): text=\(answer.textAnswer ?? "nil"), option=\(answer.selectedOption ?? "nil"), number=\(answer.numberAnswer?.description ?? "nil")")
            }

            // Convert answers to dictionary format for Supabase
            var answersDict: [String: Any] = [:]
            for (questionIndex, answer) in answers {
                answersDict["\(questionIndex)"] = answer.toDictionary()
            }

            print("📦 [Onboarding] Converted answers: \(answersDict.keys.sorted())")
            print("📦 [Onboarding] Sample converted answer for Q2: \(answersDict["2"] ?? "nil")")

            // Save onboarding answers to Supabase
            print("⬆️ [Onboarding] Saving onboarding answers to Supabase...")
            try await SupabaseService.shared.saveOnboardingAnswers(
                userId: userId,
                answers: answersDict
            )
            print("✅ [Onboarding] Onboarding answers saved successfully!")

            // Extract user profile data from answers
            var firstName = "User"
            var age = 25
            var gender: String?
            var relationshipOrientation: String?

            // Question 8 is typically the user's name
            if let nameAnswer = answers[8], let name = nameAnswer.textAnswer, !name.isEmpty {
                firstName = name
                print("👤 [Onboarding] Found first name: \(firstName)")
            }

            // Question 9 is typically age
            if let ageAnswer = answers[9], let ageValue = ageAnswer.numberAnswer {
                age = ageValue
                print("🎂 [Onboarding] Found age: \(age)")
            }

            // Question 10 might be gender
            if let genderAnswer = answers[10], let genderValue = genderAnswer.selectedOption {
                gender = genderValue
                print("👥 [Onboarding] Found gender: \(genderValue)")
            }

            // Save user profile to Supabase
            print("⬆️ [Onboarding] Saving user profile to Supabase...")
            try await SupabaseService.shared.saveUserProfile(
                userId: userId,
                firstName: firstName,
                age: age,
                gender: gender,
                relationshipOrientation: relationshipOrientation
            )
            print("✅ [Onboarding] User profile saved successfully!")
            print("🎊 [Onboarding] ALL DATA SAVED TO SUPABASE!")

        } catch {
            print("❌ [Onboarding] Failed to save to Supabase: \(error)")
            print("❌ [Onboarding] Error details: \(error.localizedDescription)")
        }
    }

    func completePaywall() {
        print("🎉 [Onboarding] Paywall complete - ensuring data is saved before navigating...")

        // Save to Supabase synchronously BEFORE navigating
        Task {
            await saveToSupabase()

            // Only navigate after save completes
            print("✅ [Onboarding] Data saved, now navigating to Dashboard")
            navigateToDashboard = true
        }
    }

    // MARK: - Local Storage

    private func saveAnswersLocally() {
        // Convert answers to JSON and save
        if let encoded = try? JSONEncoder().encode(answers) {
            UserDefaults.standard.set(encoded, forKey: "onboardingAnswers")
        }
    }

    func loadAnswers() {
        // Load saved answers from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "onboardingAnswers"),
           let decoded = try? JSONDecoder().decode([Int: OnboardingAnswer].self, from: data) {
            answers = decoded
        }
    }

    /// Check if user is currently authenticated
    func checkAuthentication() async {
        print("🔐 [Onboarding] Checking authentication status...")
        do {
            let user = try await SupabaseService.shared.getCurrentUser()
            isUserAuthenticated = user != nil
            if isUserAuthenticated {
                print("✅ [Onboarding] User is authenticated - will skip screen 28")
            } else {
                print("ℹ️ [Onboarding] User not authenticated - will show screen 28")
            }
        } catch {
            print("⚠️ [Onboarding] Auth check failed: \(error.localizedDescription)")
            isUserAuthenticated = false
        }
    }

    func resetOnboarding() {
        currentQuestionIndex = 0
        answers = [:]
        UserDefaults.standard.removeObject(forKey: "onboardingAnswers")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
}
