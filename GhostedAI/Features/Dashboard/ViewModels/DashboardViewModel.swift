import Foundation
import SwiftUI
import Combine
import Auth

/// ViewModel for the main dashboard
/// Manages user data, stats, and activity tracking with Total Days No-Contact as primary metric
@MainActor
class DashboardViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var userName: String = "there"
    @Published var totalDaysNoContact: Int = 0
    @Published var breakupDate: Date?
    @Published var currentStreak: Int = 0
    @Published var personalBestStreak: Int = 0
    @Published var daysUsingApp: Int = 0
    @Published var hasLoggedToday: Bool = false
    @Published var heatmapData: [HeatmapCellData] = []
    @Published var monthLabels: [String] = []
    @Published var milestones: [Milestone] = [
        Milestone(days: 7),
        Milestone(days: 14),
        Milestone(days: 30),
        Milestone(days: 60),
        Milestone(days: 90),
        Milestone(days: 180)
    ]
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

    // MARK: - Initialization

    init() {
        generateMockData()
    }

    // MARK: - Data Loading

    /// Load all user data from Supabase
    func loadUserData() async {
        print("📊 [Dashboard] Loading dashboard data...")
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

            // Load breakup date and calculate total days no-contact
            await loadBreakupDate(userId: user.id)

            // TODO: Load real data from Supabase
            // - currentStreak from check_ins table (consecutive days logged)
            // - personalBestStreak from check_ins table (longest streak ever)
            // - daysUsingApp from user created_at date
            // - hasLoggedToday from check_ins table (check if today's date exists)
            // - heatmapData from check_ins table (last 90 days)

            // For now, use mock data based on total days
            currentStreak = totalDaysNoContact // Mock: same as total days
            personalBestStreak = totalDaysNoContact + 3 // Mock: slightly higher
            daysUsingApp = totalDaysNoContact + 6 // Mock: started using app a few days later
            hasLoggedToday = false

            // Generate mock heatmap
            generateMockHeatmap()

            print("✅ [Dashboard] Data loaded successfully")
            print("   📊 Total days no-contact: \(totalDaysNoContact)")
            print("   🔥 Current streak: \(currentStreak)")
            print("   🏆 Personal best: \(personalBestStreak)")
            print("   📱 Days using app: \(daysUsingApp)")
            print("   🎯 Milestones unlocked: \(milestones.filter { totalDaysNoContact >= $0.days }.map { $0.days })")

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

    /// Load breakup date from onboarding answers and calculate total days no-contact
    private func loadBreakupDate(userId: UUID) async {
        print("🔍 [Dashboard] Fetching breakup date for user_id: \(userId)")

        do {
            let answers = try await SupabaseService.shared.getOnboardingAnswers(userId: userId)

            if let answers = answers {
                // Look for breakup date in onboarding answers
                // Assuming question ID for breakup date (might need to adjust)
                for (key, value) in answers {
                    if let answerDict = value as? [String: Any],
                       let dateString = answerDict["dateAnswer"] as? String {

                        // Try to parse ISO8601 date
                        let formatter = ISO8601DateFormatter()
                        if let date = formatter.date(from: dateString) {
                            breakupDate = date

                            // Calculate total days no-contact
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.day], from: date, to: Date())
                            totalDaysNoContact = max(0, components.day ?? 0)

                            print("✅ [Dashboard] Breakup date loaded: \(date)")
                            print("✅ [Dashboard] Total days no-contact calculated: \(totalDaysNoContact)")
                            return
                        }
                    }
                }

                print("⚠️ [Dashboard] Breakup date not found in onboarding answers")
            }

            // Fallback: use mock date (12 days ago)
            let mockDate = Calendar.current.date(byAdding: .day, value: -12, to: Date())!
            breakupDate = mockDate
            totalDaysNoContact = 12
            print("ℹ️ [Dashboard] Using mock breakup date: 12 days ago")

        } catch {
            print("❌ [Dashboard] Failed to load breakup date: \(error.localizedDescription)")
            // Use mock data
            let mockDate = Calendar.current.date(byAdding: .day, value: -12, to: Date())!
            breakupDate = mockDate
            totalDaysNoContact = 12
        }
    }

    /// Generate mock data for initial development
    private func generateMockData() {
        print("🎨 [Dashboard] Generating mock data...")

        // Mock breakup date (12 days ago)
        breakupDate = Calendar.current.date(byAdding: .day, value: -12, to: Date())!
        totalDaysNoContact = 12
        currentStreak = 12
        personalBestStreak = 15
        daysUsingApp = 18
        hasLoggedToday = false

        generateMockHeatmap()
        generateMonthLabels()

        print("✅ [Dashboard] Mock data generated")
    }

    /// Generate mock heatmap data for last 90 days
    private func generateMockHeatmap() {
        print("🎨 [Dashboard] Generating mock heatmap (90 days)...")

        heatmapData = (0..<91).map { index in
            let daysFromToday = 90 - index

            if daysFromToday < 0 {
                // Future days (should not happen with 91 days starting from today)
                return .future
            } else if daysFromToday > totalDaysNoContact {
                // Before breakup - mark as missed (dark)
                return .missed
            } else {
                // After breakup - randomly mark as logged or missed (mock data)
                return Double.random(in: 0...1) > 0.3 ? .logged : .missed
            }
        }

        print("✅ [Dashboard] Generated \(heatmapData.count) heatmap cells")
    }

    /// Generate month labels for heatmap (last 3 months)
    private func generateMonthLabels() {
        let calendar = Calendar.current
        let today = Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        var labels: [String] = []
        for monthsAgo in (0...2).reversed() {
            if let date = calendar.date(byAdding: .month, value: -monthsAgo, to: today) {
                labels.append(formatter.string(from: date))
            }
        }

        monthLabels = labels
        print("✅ [Dashboard] Month labels: \(monthLabels)")
    }

    // MARK: - Actions

    /// Log today's no-contact day
    func logTodayNoContact() async {
        print("✅ [Dashboard] Logging today's no-contact day...")

        // TODO: Save to check_ins table in Supabase
        // - Insert record with user_id, today's date, mood, journal
        // - Update heatmap data
        // - Update current streak
        // - Check if new personal best

        // For now, just update local state
        hasLoggedToday = true

        // Update heatmap - mark today as logged (index 90 is today)
        if heatmapData.count == 91 {
            heatmapData[90] = .logged
        }

        print("✅ [Dashboard] Day logged! Total days: \(totalDaysNoContact + 1)")
    }

    /// Refresh all data (pull-to-refresh)
    func refresh() async {
        print("🔄 [Dashboard] Refreshing data...")
        await loadUserData()
    }
}
