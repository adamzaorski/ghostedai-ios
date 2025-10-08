import Foundation
import SwiftUI
import Combine
import Auth

/// ViewModel for profile view - manages user data and preferences
@MainActor
class ProfileViewModel: ObservableObject {

    // MARK: - Published Properties

    // User Info
    @Published var userName: String = "User"
    @Published var userEmail: String = "user@example.com"
    @Published var userAge: Int = 25
    @Published var userGender: String = "Not specified"
    @Published var relationshipOrientation: String = "Not specified"

    // Personalization
    @Published var primaryGoal: String = "Move on"
    @Published var aiVoiceStyle: String = "Supportive Friend"
    @Published var cursingAllowed: Bool = false
    @Published var exName: String = "Your ex"

    // Subscription
    @Published var subscriptionPlan: String = "Free Trial"
    @Published var subscriptionStatus: String = "2 days left"

    // Notifications
    @Published var dailyReminders: Bool = true {
        didSet { savePreference("dailyReminders", value: dailyReminders) }
    }
    @Published var streakNotifications: Bool = true {
        didSet { savePreference("streakNotifications", value: streakNotifications) }
    }
    @Published var aiMessages: Bool = true {
        didSet { savePreference("aiMessages", value: aiMessages) }
    }
    @Published var weeklyReports: Bool = false {
        didSet { savePreference("weeklyReports", value: weeklyReports) }
    }

    // UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Computed
    var userInitial: String {
        String(userName.prefix(1).uppercased())
    }

    // MARK: - Data Loading

    /// Load user data from Supabase
    func loadUserData() async {
        print("👤 [Profile] Loading user data...")
        isLoading = true
        errorMessage = nil

        do {
            // Get current user
            guard let user = try await SupabaseService.shared.getCurrentUser() else {
                print("⚠️ [Profile] No authenticated user found")
                errorMessage = "Please sign in to continue"
                isLoading = false
                return
            }

            print("✅ [Profile] User authenticated: \(user.id)")
            userEmail = user.email ?? "No email"

            // Load onboarding answers
            if let answers = try await SupabaseService.shared.getOnboardingAnswers(userId: user.id) {
                print("✅ [Profile] Loaded onboarding answers")
                extractUserDataFromAnswers(answers)
            } else {
                print("⚠️ [Profile] No onboarding answers found")
            }

            // Load preferences from UserDefaults
            loadPreferences()

            print("✅ [Profile] Profile data loaded successfully")

        } catch {
            print("❌ [Profile] Failed to load data: \(error.localizedDescription)")
            errorMessage = "Failed to load profile data"
        }

        isLoading = false
    }

    /// Extract user data from onboarding answers
    private func extractUserDataFromAnswers(_ answers: [String: Any]) {
        // Question 8: User's name
        if let nameAnswer = answers["8"] as? [String: Any],
           let name = nameAnswer["textAnswer"] as? String {
            userName = name
            print("👤 [Profile] Name: \(name)")
        }

        // Question 9: Age
        if let ageAnswer = answers["9"] as? [String: Any],
           let age = ageAnswer["numberAnswer"] as? Int {
            userAge = age
            print("🎂 [Profile] Age: \(age)")
        }

        // Question 10: Gender
        if let genderAnswer = answers["10"] as? [String: Any],
           let gender = genderAnswer["selectedOption"] as? String {
            userGender = gender
            print("👥 [Profile] Gender: \(gender)")
        }

        // Question 2: Ex's name
        if let exNameAnswer = answers["2"] as? [String: Any],
           let name = exNameAnswer["textAnswer"] as? String {
            exName = name
            print("💔 [Profile] Ex's name: \(name)")
        }

        // Question 11: Relationship orientation
        if let orientationAnswer = answers["11"] as? [String: Any],
           let orientation = orientationAnswer["selectedOption"] as? String {
            relationshipOrientation = orientation
            print("❤️ [Profile] Relationship orientation: \(orientation)")
        }

        // Question 12: Primary goal (if exists)
        if let goalAnswer = answers["12"] as? [String: Any],
           let goal = goalAnswer["selectedOption"] as? String {
            primaryGoal = goal
            print("🎯 [Profile] Primary goal: \(goal)")
        }
    }

    // MARK: - Update Fields

    /// Update a profile field
    func updateField(_ field: ProfileField, value: String) {
        print("📝 [Profile] Updating \(field.title): \(value)")

        switch field {
        case .name:
            userName = value
        case .email:
            userEmail = value
        case .age:
            if let age = Int(value) {
                userAge = age
            }
        case .gender:
            userGender = value
        case .relationshipOrientation:
            relationshipOrientation = value
        case .exName:
            exName = value
        }

        // TODO: Save to Supabase
        Task {
            await saveToSupabase()
        }
    }

    /// Save user data to Supabase
    private func saveToSupabase() async {
        print("💾 [Profile] Saving to Supabase...")

        do {
            guard let user = try await SupabaseService.shared.getCurrentUser() else {
                print("❌ [Profile] No authenticated user")
                return
            }

            // Save user profile
            try await SupabaseService.shared.saveUserProfile(
                userId: user.id,
                firstName: userName,
                age: userAge,
                gender: userGender,
                relationshipOrientation: relationshipOrientation
            )

            print("✅ [Profile] Saved to Supabase successfully")

        } catch {
            print("❌ [Profile] Failed to save: \(error.localizedDescription)")
        }
    }

    // MARK: - Preferences

    /// Load preferences from UserDefaults
    private func loadPreferences() {
        dailyReminders = UserDefaults.standard.bool(forKey: "dailyReminders")
        streakNotifications = UserDefaults.standard.bool(forKey: "streakNotifications")
        aiMessages = UserDefaults.standard.bool(forKey: "aiMessages")
        weeklyReports = UserDefaults.standard.bool(forKey: "weeklyReports")

        print("✅ [Profile] Loaded preferences from UserDefaults")
    }

    /// Save a preference to UserDefaults
    private func savePreference(_ key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
        print("💾 [Profile] Saved preference: \(key) = \(value)")
    }

    // MARK: - Actions

    /// Sign out the user
    func signOut() {
        print("🚪 [Profile] Signing out...")

        Task {
            do {
                try await SupabaseService.shared.signOut()
                print("✅ [Profile] Sign out successful")
                // TODO: Navigate back to welcome screen
            } catch {
                print("❌ [Profile] Sign out failed: \(error.localizedDescription)")
            }
        }
    }

    /// Delete user account
    func deleteAccount() {
        print("🗑️ [Profile] Deleting account...")

        Task {
            do {
                guard let user = try await SupabaseService.shared.getCurrentUser() else {
                    print("❌ [Profile] No authenticated user")
                    return
                }

                try await SupabaseService.shared.deleteUserData(userId: user.id)
                print("✅ [Profile] Account deleted successfully")
                // TODO: Navigate back to welcome screen
            } catch {
                print("❌ [Profile] Account deletion failed: \(error.localizedDescription)")
            }
        }
    }

    /// DEBUG: Reset all check-ins for current user
    func resetAllCheckIns() async {
        print("🔄 [Profile] Resetting all check-ins...")

        do {
            guard let user = try await SupabaseService.shared.getCurrentUser() else {
                print("❌ [Profile] No authenticated user")
                return
            }

            try await SupabaseService.shared.deleteAllCheckIns(userId: user.id)
            print("✅ [Profile] All check-ins deleted successfully")
            print("ℹ️ [Profile] Dashboard will refresh when you return to it")
        } catch {
            print("❌ [Profile] Failed to reset check-ins: \(error.localizedDescription)")
        }
    }
}
