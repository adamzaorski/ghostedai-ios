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
        // Start with empty state - data will be loaded when view appears
        print("🎬 [DashboardViewModel] Initialized with empty state")
    }

    // MARK: - Data Loading

    /// Load all user data from Supabase
    func loadUserData() async {
        print("📊 [Dashboard] ==================== LOADING DASHBOARD DATA ====================")
        isLoading = true
        errorMessage = nil

        do {
            // STEP 1: Verify user authentication
            print("📊 [Dashboard] STEP 1: Verifying user authentication...")
            guard let user = try await SupabaseService.shared.getCurrentUser() else {
                print("⚠️ [Dashboard] NO AUTHENTICATED USER FOUND")
                errorMessage = "Please sign in to continue"
                isLoading = false
                return
            }
            print("✅ [Dashboard] User authenticated - user_id: \(user.id)")

            // STEP 2: Fetch ALL check-ins for this user
            print("📊 [Dashboard] STEP 2: Fetching ALL check-ins from Supabase...")
            let checkIns = try await SupabaseService.shared.getCheckIns(userId: user.id)
            print("📊 [Dashboard] Check-ins found in database: \(checkIns.count)")

            if checkIns.isEmpty {
                print("📊 [Dashboard] Detailed check-ins: NONE")
            } else {
                print("📊 [Dashboard] Detailed check-ins (first 5):")
                for (index, checkIn) in checkIns.prefix(5).enumerated() {
                    print("   [\(index + 1)] date: \(checkIn.date), type: \(checkIn.type)")
                }
            }

            // STEP 3: Determine initial state based on check-ins
            print("📊 [Dashboard] STEP 3: Calculating stats from check-ins...")

            if checkIns.isEmpty {
                print("⚠️ [Dashboard] NO CHECK-INS FOUND - Using empty state")
                totalDaysNoContact = 0
                currentStreak = 0
                personalBestStreak = 0
                hasLoggedToday = false
                heatmapData = Array(repeating: .missed, count: 91)
                print("📊 [Dashboard] Empty state applied: 0 days, 0 streak, empty heatmap")
            } else {
                print("📊 [Dashboard] Processing \(checkIns.count) check-ins...")

                // Filter success check-ins only
                let successCheckIns = checkIns.filter { $0.type == "success" }
                print("📊 [Dashboard] Success check-ins: \(successCheckIns.count)")
                print("📊 [Dashboard] Slip check-ins: \(checkIns.count - successCheckIns.count)")

                // Total days = count of success check-ins
                totalDaysNoContact = successCheckIns.count
                print("📊 [Dashboard] Total days no-contact: \(totalDaysNoContact)")

                // Calculate current streak
                currentStreak = calculateCurrentStreak(from: checkIns)
                print("📊 [Dashboard] Current streak: \(currentStreak) days")

                // Calculate longest streak
                personalBestStreak = calculateLongestStreak(from: checkIns)
                print("📊 [Dashboard] Personal best streak: \(personalBestStreak) days")

                // Check if logged today
                let today = ISO8601DateFormatter().string(from: Date()).prefix(10) // YYYY-MM-DD
                hasLoggedToday = checkIns.contains { $0.date.starts(with: today) }
                print("📊 [Dashboard] Has logged today: \(hasLoggedToday)")

                // Generate heatmap from real data
                generateHeatmapFromCheckIns(checkIns)
                print("📊 [Dashboard] Heatmap generated with \(heatmapData.count) cells")
            }

            // Load user profile for first name (non-critical)
            await loadUserProfile(userId: user.id)

            // Generate month labels for heatmap
            generateMonthLabels()

            print("✅ [Dashboard] ==================== DATA LOADED SUCCESSFULLY ====================")
            print("   📊 Total days no-contact: \(totalDaysNoContact)")
            print("   🔥 Current streak: \(currentStreak)")
            print("   🏆 Personal best: \(personalBestStreak)")
            print("   ✓ Has logged today: \(hasLoggedToday)")
            print("   🎯 Milestones unlocked: \(milestones.filter { totalDaysNoContact >= $0.days }.map { $0.days })")
            print("================================================================================")

        } catch {
            print("❌ [Dashboard] FATAL ERROR loading data: \(error.localizedDescription)")
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

    // MARK: - Streak Calculations

    /// Calculate current streak (consecutive days from today backwards)
    private func calculateCurrentStreak(from checkIns: [SupabaseService.CheckIn]) -> Int {
        print("🔥 [Dashboard] Calculating current streak...")

        let calendar = Calendar.current
        let dateFormatter = ISO8601DateFormatter()

        // Parse all check-in dates
        var checkInDates: Set<Date> = []
        for checkIn in checkIns where checkIn.type == "success" {
            if let date = dateFormatter.date(from: checkIn.date) {
                // Normalize to start of day
                if let startOfDay = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: date)) {
                    checkInDates.insert(startOfDay)
                }
            }
        }

        // Start from today and count backwards
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        while checkInDates.contains(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }

        print("🔥 [Dashboard] Current streak calculated: \(streak) days")
        return streak
    }

    /// Calculate longest streak ever
    private func calculateLongestStreak(from checkIns: [SupabaseService.CheckIn]) -> Int {
        print("🏆 [Dashboard] Calculating longest streak...")

        let calendar = Calendar.current
        let dateFormatter = ISO8601DateFormatter()

        // Parse and sort check-in dates
        var checkInDates: [Date] = []
        for checkIn in checkIns where checkIn.type == "success" {
            if let date = dateFormatter.date(from: checkIn.date) {
                if let startOfDay = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: date)) {
                    checkInDates.append(startOfDay)
                }
            }
        }

        // Remove duplicates and sort
        checkInDates = Array(Set(checkInDates)).sorted()

        guard !checkInDates.isEmpty else {
            print("🏆 [Dashboard] No check-ins found, longest streak: 0")
            return 0
        }

        var longestStreak = 1
        var currentStreakLength = 1

        for i in 1..<checkInDates.count {
            let previousDate = checkInDates[i - 1]
            let currentDate = checkInDates[i]

            // Check if dates are consecutive
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDate),
               calendar.isDate(nextDay, inSameDayAs: currentDate) {
                currentStreakLength += 1
                longestStreak = max(longestStreak, currentStreakLength)
            } else {
                currentStreakLength = 1
            }
        }

        print("🏆 [Dashboard] Longest streak calculated: \(longestStreak) days")
        return longestStreak
    }

    /// Generate heatmap from real check-ins data
    private func generateHeatmapFromCheckIns(_ checkIns: [SupabaseService.CheckIn]) {
        print("🗓️ [Dashboard] Generating heatmap from check-ins...")

        let calendar = Calendar.current
        let dateFormatter = ISO8601DateFormatter()

        // Parse all check-in dates into a set for fast lookup
        var checkInDates: Set<Date> = []
        for checkIn in checkIns where checkIn.type == "success" {
            if let date = dateFormatter.date(from: checkIn.date) {
                if let startOfDay = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: date)) {
                    checkInDates.insert(startOfDay)
                }
            }
        }

        // Generate 91 days of heatmap data (13 weeks)
        let today = calendar.startOfDay(for: Date())
        heatmapData = (0..<91).map { index in
            let daysAgo = 90 - index
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return .missed
            }

            // Check if this date has a check-in
            return checkInDates.contains(date) ? .logged : .missed
        }

        let loggedCount = heatmapData.filter { $0 == .logged }.count
        print("🗓️ [Dashboard] Heatmap generated: \(loggedCount) logged days out of 91")
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

    /// Log today's no-contact day (success check-in)
    func logTodayNoContact() async {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📥 CHECK-IN FLOW - SUCCESS")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("1️⃣ User confirmed check-in (success)")

        do {
            // Get current user
            guard let user = try await SupabaseService.shared.getCurrentUser() else {
                print("❌ [Dashboard] No authenticated user found")
                return
            }

            print("2️⃣ Saving check-in to database...")

            // Save to Supabase
            try await SupabaseService.shared.saveCheckIn(
                userId: user.id,
                date: Date(),
                type: "success"
            )

            print("3️⃣ ✅ Check-in saved successfully!")
            print("4️⃣ Reloading dashboard data to recalculate metrics...")

            // CRITICAL: Reload ALL data from database to recalculate metrics
            await loadUserData()

            print("5️⃣ ✅ Metrics updated:")
            print("   📊 Total days no-contact: \(totalDaysNoContact)")
            print("   🔥 Current streak: \(currentStreak) days")
            print("   🏆 Personal best streak: \(personalBestStreak) days")
            print("   ✓ Has logged today: \(hasLoggedToday)")
            print("6️⃣ UI updated")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━")

        } catch {
            print("❌ [Dashboard] FATAL ERROR during check-in: \(error.localizedDescription)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
    }

    /// Log today as a slip
    func logTodaySlip() async {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📥 CHECK-IN FLOW - SLIP")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("1️⃣ User logged slip")

        do {
            // Get current user
            guard let user = try await SupabaseService.shared.getCurrentUser() else {
                print("❌ [Dashboard] No authenticated user found")
                return
            }

            print("2️⃣ Saving slip to database...")

            // Save to Supabase
            try await SupabaseService.shared.saveCheckIn(
                userId: user.id,
                date: Date(),
                type: "slip"
            )

            print("3️⃣ ✅ Slip saved successfully!")
            print("4️⃣ Reloading dashboard data to recalculate metrics...")

            // CRITICAL: Reload ALL data from database to recalculate metrics
            await loadUserData()

            print("5️⃣ ✅ Metrics updated:")
            print("   📊 Total days no-contact: \(totalDaysNoContact) (unchanged - slips don't count)")
            print("   🔥 Current streak: \(currentStreak) days (reset to 0 if broken)")
            print("   🏆 Personal best streak: \(personalBestStreak) days (kept)")
            print("   ✓ Has logged today: \(hasLoggedToday)")
            print("6️⃣ UI updated")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━")

        } catch {
            print("❌ [Dashboard] FATAL ERROR during slip logging: \(error.localizedDescription)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
    }

    /// Refresh all data (pull-to-refresh)
    func refresh() async {
        print("🔄 [Dashboard] Refreshing data...")
        await loadUserData()
    }
}
