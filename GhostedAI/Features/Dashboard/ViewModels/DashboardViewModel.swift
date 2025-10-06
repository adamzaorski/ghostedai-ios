import Foundation
import SwiftUI
import Combine
import Auth

/// ViewModel for the main dashboard
/// Manages user data, stats, and activity tracking
@MainActor
class DashboardViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var userName: String = "there"
    @Published var currentStreak: Int = 12
    @Published var daysSinceBreakup: Int = 12
    @Published var daysUsingApp: Int = 18
    @Published var hasCheckedInToday: Bool = false
    @Published var heatmapData: [[Int]] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

    // MARK: - Initialization

    init() {
        generateMockHeatmap()
    }

    // MARK: - Data Loading

    /// Load all user data from Supabase
    func loadUserData() async {
        print("📊 [Dashboard] Loading user data...")
        isLoading = true
        errorMessage = nil

        do {
            // Get current user
            guard let user = try await SupabaseService.shared.getCurrentUser() else {
                print("⚠️ [Dashboard] No authenticated user found")
                errorMessage = "Please sign in to continue"
                isLoading = false
                return
            }

            print("✅ [Dashboard] User authenticated: \(user.id)")

            // Load user profile for first name
            await loadUserProfile(userId: user.id)

            // TODO: Load real data from Supabase
            // - currentStreak from check_ins table
            // - daysSinceBreakup from onboarding_answers
            // - daysUsingApp from user created_at date
            // - hasCheckedInToday from check_ins table
            // - heatmapData from check_ins table (last 90 days)

            // For now, use mock data
            currentStreak = 12
            daysSinceBreakup = 12
            daysUsingApp = 18
            hasCheckedInToday = false

            print("✅ [Dashboard] Data loaded successfully")
            print("   - User: \(userName)")
            print("   - Streak: \(currentStreak) days")
            print("   - Since breakup: \(daysSinceBreakup) days")

        } catch {
            print("❌ [Dashboard] Failed to load data: \(error.localizedDescription)")
            errorMessage = "Failed to load dashboard data"
        }

        isLoading = false
    }

    /// Load user profile to get first name
    private func loadUserProfile(userId: UUID) async {
        print("🔍 [Dashboard] Fetching user profile for user_id: \(userId)")

        do {
            // Try to get answers from Supabase
            let answers = try await SupabaseService.shared.getOnboardingAnswers(userId: userId)

            print("📦 [Dashboard] Onboarding answers retrieved: \(answers != nil ? "YES" : "NO")")

            if let answers = answers {
                print("📝 [Dashboard] Total answer keys: \(answers.keys.count)")
                print("📝 [Dashboard] Available answer keys: \(Array(answers.keys).sorted())")

                // Question 8 is "What's your first name?"
                print("🔍 [Dashboard] Looking for name in question_id: 8")

                if let answerDict = answers["8"] as? [String: Any] {
                    print("📄 [Dashboard] Found answer dict for Q8: \(answerDict)")

                    // Try to extract textAnswer field
                    if let name = answerDict["textAnswer"] as? String, !name.isEmpty {
                        userName = name
                        print("✅ [Dashboard] Successfully loaded user name from Q8.textAnswer: '\(userName)'")
                        return
                    } else {
                        print("⚠️ [Dashboard] Q8 answer dict exists but textAnswer is missing or empty")
                    }
                } else {
                    print("⚠️ [Dashboard] Q8 not found or not a dictionary")
                }

                // Fallback: Try to find name in other question IDs
                print("🔍 [Dashboard] Attempting fallback search through all questions...")
                for key in answers.keys.sorted() {
                    if let answerDict = answers[key] as? [String: Any],
                       let text = answerDict["textAnswer"] as? String,
                       !text.isEmpty,
                       text.count < 50, // Names shouldn't be super long
                       !text.contains("@"), // Not an email
                       !text.contains(" ") || text.split(separator: " ").count <= 2 { // Single name or first+last
                        print("ℹ️ [Dashboard] Found potential name in Q\(key): '\(text)'")

                        // Use first reasonable name found
                        if key == "8" || key == "9" { // Prioritize likely name questions
                            userName = text
                            print("✅ [Dashboard] Using name from Q\(key): '\(userName)'")
                            return
                        }
                    }
                }

                print("⚠️ [Dashboard] User name not found in onboarding answers after full search")
            } else {
                print("⚠️ [Dashboard] No onboarding answers found for user")
            }

            // Fallback to default
            userName = "there"
            print("ℹ️ [Dashboard] Using default name: 'there'")

        } catch {
            print("❌ [Dashboard] Failed to load onboarding answers: \(error.localizedDescription)")
            userName = "there"
        }
    }

    /// Generate mock heatmap data for development
    func generateMockHeatmap() {
        print("🎨 [Dashboard] Generating mock heatmap...")

        // 7 rows (days of week) x 13 columns (weeks)
        // Values 0-4 representing activity intensity
        heatmapData = (0..<7).map { _ in
            (0..<13).map { _ in
                Int.random(in: 0...4)
            }
        }

        print("✅ [Dashboard] Generated \(heatmapData.count) x \(heatmapData[0].count) heatmap")
    }

    // MARK: - Actions

    /// Handle check-in button tap
    func handleCheckIn() {
        print("✅ [Dashboard] Check-in tapped")
        // TODO: Navigate to CheckInView
        hasCheckedInToday = true
    }

    /// Handle share button tap
    func shareProgress() -> String {
        let text = """
        My Ghosted AI Progress:

        🔥 \(currentStreak)-day streak
        📅 \(daysSinceBreakup) days since breakup
        📱 \(daysUsingApp) days using Ghosted AI

        Healing isn't linear, but I'm making progress every day.
        """

        print("📤 [Dashboard] Sharing progress...")
        return text
    }

    /// Refresh all data (pull-to-refresh)
    func refresh() async {
        print("🔄 [Dashboard] Refreshing data...")
        await loadUserData()
    }
}
