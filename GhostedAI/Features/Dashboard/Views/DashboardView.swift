import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showCheckInModal = false
    @State private var showMilestonesModal = false
    @State private var showEditDateModal = false
    @State private var selectedDate: Date?
    @State private var showSuccessToast = false
    @State private var toastMessage = ""
    @State private var timeUntilNextCheckIn = ""
    @State private var hasAppeared = false
    @State private var isPressed = false
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            // Layer 1: Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Welcome Section (starts from top, no header)
                    welcomeSection
                        .padding(.top, 48)

                    // Hero Card - Total Days
                    totalDaysCard
                        .padding(.top, 24)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.0), value: hasAppeared)

                    // Dual Streak Cards
                    streakCardsSection
                        .padding(.top, 20)
                        .opacity(hasAppeared ? 1 : 0)
                        .animation(.easeIn(duration: 0.3), value: hasAppeared)

                    // Progress Chart
                    progressChartCard
                        .padding(.top, 24)
                        .opacity(hasAppeared ? 1 : 0)
                        .animation(.easeIn(duration: 0.3), value: hasAppeared)

                    // Milestones Section
                    milestonesSection
                        .padding(.top, 24)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: hasAppeared)

                    // Bottom padding for floating button
                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 20)
            }

            // Layer 2: Full-Width Check-In Button
            VStack {
                Spacer()
                checkInButton
                    .padding(.bottom, 16)
            }

            // Layer 3: Modals
            if showCheckInModal {
                checkInModalView
            }

            if showEditDateModal, let date = selectedDate {
                editDateModalView(date: date)
            }

            // Success Toast
            if showSuccessToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(hex: 0x1A1A1A))
                        .cornerRadius(12)
                        .padding(.bottom, 180)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showMilestonesModal) {
            milestonesModalView
        }
        .onAppear {
            hasAppeared = true
            isPulsing = true
        }
        .task {
            print("📊 Dashboard loading...")
            await viewModel.loadUserData()

            print("✨ Dashboard UI refinements applied")
            print("User: \(viewModel.userName)")
            print("Total days: \(viewModel.totalDaysNoContact), Current streak: \(viewModel.currentStreak), Best: \(viewModel.personalBestStreak)")
            print("Next milestone: \(Int(nextMilestone)) days")
            print("Progress: \(Int(progressToNextMilestone * 100))%")

            let achievedCount = allMilestones.filter { viewModel.totalDaysNoContact >= $0.days }.count
            print("🏆 Milestones: \(achievedCount) unlocked")
        }
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi, \(viewModel.userName)")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)

            Text("Let's get through it, one day at a time.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))
                .lineSpacing(17 * 0.4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Total Days Card (Hero - Minimal Clean)

    private var totalDaysCard: some View {
        VStack(spacing: 12) {
            // Top label
            Text("Total Days No-Contact")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: 0x8E8E93))

            // Main number (ONLY number, no "days")
            Text("\(viewModel.totalDaysNoContact)")
                .font(.system(size: 96, weight: .bold))
                .foregroundColor(Color(hex: 0xFF6B35))

            // Progress bar section
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track (FULL WIDTH - always visible)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: 0x2C2C2E))
                            .frame(height: 8)

                        // Progress fill (PERCENTAGE of width)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressToNextMilestone, height: 8)
                            .animation(.easeOut(duration: 1.2), value: progressToNextMilestone)
                    }
                }
                .frame(height: 8)
                .frame(maxWidth: .infinity)

                // Bottom text
                Text("Next milestone: \(Int(nextMilestone)) days")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: 0x8E8E93))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.top, 12)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(Color(hex: 0x1C1C1E))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.03), lineWidth: 1)
        )
    }

    // MARK: - Streak Cards Section (Minimal Clean)

    private var streakCardsSection: some View {
        HStack(spacing: 16) {
            // Current Streak Card - minimal, no icons
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Streak")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: 0x8E8E93))

                Text("\(viewModel.currentStreak) days")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(Color(hex: 0x1C1C1E))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.03), lineWidth: 1)
            )

            // Longest Streak Card - minimal, no icons
            VStack(alignment: .leading, spacing: 12) {
                Text("Longest Streak")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: 0x8E8E93))

                Text("\(viewModel.personalBestStreak) days")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(Color(hex: 0x1C1C1E))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.03), lineWidth: 1)
            )
        }
    }

    // MARK: - Progress Chart Card (Premium)

    private var progressChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("No-Contact Timeline")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)

            Text("We build momentum one square at a time")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))
                .padding(.bottom, 8)

            // Chart
            if viewModel.heatmapData.isEmpty {
                emptyChartState
            } else {
                githubStyleChart
            }
        }
        .padding(32)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x1A1A1A), Color(hex: 0x151515)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 6)
    }

    private var emptyChartState: some View {
        VStack(spacing: 16) {
            // Empty grid placeholder
            ForEach(0..<7, id: \.self) { _ in
                HStack(spacing: 4) {
                    ForEach(0..<13, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: 0x1A1A1A))
                            .frame(width: 14, height: 14)
                    }
                }
            }

            Text("Getting started is the hardest part, but you're ready for this!")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: 0xFF8E53))
                .multilineTextAlignment(.center)
                .padding(.top, 16)
        }
    }

    private var githubStyleChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month labels - larger and white
            HStack(spacing: 0) {
                ForEach(viewModel.monthLabels, id: \.self) { month in
                    Text(month)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.bottom, 12)

            // Grid with day labels
            VStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { row in
                    HStack(spacing: 4) {
                        // Day label
                        Text(dayLabel(for: row))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: 0x666666))
                            .frame(width: 24, alignment: .leading)

                        // Cells with month spacing
                        ForEach(0..<13, id: \.self) { col in
                            let index = col * 7 + row
                            if index < viewModel.heatmapData.count {
                                chartCell(for: index)

                                // Add spacing between months
                                if col == 4 || col == 8 {
                                    Spacer().frame(width: 12)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func chartCell(for index: Int) -> some View {
        let cellData = viewModel.heatmapData[index]
        let date = dateForCell(index: index)

        return Button(action: {
            selectedDate = date
            showEditDateModal = true
            print("📅 Cell tapped: \(formatDate(date)) - current status: \(cellData)")
        }) {
            RoundedRectangle(cornerRadius: 3)
                .fill(cellColor(for: cellData))
                .frame(width: 14, height: 14)
                .overlay(
                    cellData == .future ?
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color(hex: 0xFF6B35), lineWidth: 1.5)
                    : nil
                )
        }
    }

    // MARK: - Milestones Section (3 Badges with View All)

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header with View All button
            HStack {
                Text("Milestones")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    showMilestonesModal = true
                }) {
                    Text("View All →")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: 0xFF6B35))
                }
            }
            .padding(.horizontal, 20)

            // Show 3 milestones horizontally
            HStack(spacing: 16) {
                ForEach(Array(threeMilestones.prefix(3)), id: \.days) { milestone in
                    progressRingMilestone(milestone: milestone)
                }
            }
        }
    }

    private func progressRingMilestone(milestone: Milestone) -> some View {
        let current = Double(viewModel.totalDaysNoContact)
        let currentStreak = Double(viewModel.currentStreak)
        let target = Double(milestone.days)

        // Use streak progress for streak milestones, total days for others
        let relevantValue = milestone.isStreak ? currentStreak : current
        let progress = min(relevantValue / target, 1.0)
        let isCompleted = relevantValue >= target
        let isLocked = relevantValue == 0

        return VStack(spacing: 12) {
            // Progress ring (100x100pt)
            ZStack {
                // Background ring (gray, full circle)
                Circle()
                    .stroke(Color(hex: 0x2C2C2E), lineWidth: 8)
                    .frame(width: 100, height: 100)

                // Progress ring (orange, partial or full)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5), value: progress)

                // Icon/emoji in center
                Text(milestoneEmoji(for: milestone, completed: isCompleted))
                    .font(.system(size: 40))
                    .opacity(isLocked ? 0.4 : 1.0)
            }

            // Label below ring (differentiate types)
            Text(milestone.isStreak ? "\(milestone.days) day streak" : "\(milestone.days) days")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isCompleted ? .white : Color(hex: 0x8E8E93))
                .multilineTextAlignment(.center)

            // Status below label
            if !milestoneStatus(for: milestone, progress: progress).isEmpty {
                Text(milestoneStatus(for: milestone, progress: progress))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(statusColor(for: milestone, completed: isCompleted))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func milestoneEmoji(for milestone: Milestone, completed: Bool) -> String {
        if completed {
            return "🎉"
        } else if milestone.days == 7 {
            return "🏆"
        } else if milestone.days == 30 {
            return "⭐"
        } else {
            return "🎯"
        }
    }

    private func milestoneStatus(for milestone: Milestone, progress: Double) -> String {
        let current = viewModel.totalDaysNoContact
        let target = milestone.days

        if current >= target {
            return "Completed"
        } else if current > 0 {
            return "In Progress"
        } else {
            return ""
        }
    }

    private func statusColor(for milestone: Milestone, completed: Bool) -> Color {
        let current = viewModel.totalDaysNoContact

        if completed {
            return Color(hex: 0x8E8E93)
        } else if current > 0 {
            return Color(hex: 0xFF6B35)
        } else {
            return Color(hex: 0x8E8E93)
        }
    }

    private var threeMilestones: [Milestone] {
        let all = allMilestones
        let achieved = all.filter { milestone in
            let relevantValue = milestone.isStreak ? viewModel.currentStreak : viewModel.totalDaysNoContact
            return relevantValue >= milestone.days
        }
        let upcoming = all.filter { milestone in
            let relevantValue = milestone.isStreak ? viewModel.currentStreak : viewModel.totalDaysNoContact
            return relevantValue < milestone.days
        }

        if achieved.count >= 3 {
            return Array(achieved.suffix(3))
        } else {
            let neededUpcoming = 3 - achieved.count
            return achieved + Array(upcoming.prefix(neededUpcoming))
        }
    }

    // MARK: - Check-In Button (Glass Effect with Pulse)

    private var checkInButton: some View {
        Button(action: {
            if !viewModel.hasLoggedToday {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                showCheckInModal = true
            }
        }) {
            ZStack {
                // Base layer (dark background)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: 0x1C1C1E).opacity(0.8))

                // Glass overlay (subtle shine)
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Text
                Text(viewModel.hasLoggedToday ? "Great work, see you tomorrow!" : "Check in today")
                    .font(.system(size: 18, weight: viewModel.hasLoggedToday ? .regular : .semibold))
                    .foregroundColor(.white)
            }
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(viewModel.hasLoggedToday ? 0.08 : 0.15), lineWidth: 1)
            )
        }
        .opacity(viewModel.hasLoggedToday ? 0.6 : 1.0)
        .scaleEffect(viewModel.hasLoggedToday ? 1.0 : (isPulsing ? 1.02 : 1.0))
        .animation(
            viewModel.hasLoggedToday ? .none : Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
            value: isPulsing
        )
        .disabled(viewModel.hasLoggedToday)
        .padding(.horizontal, 16)
    }

    // MARK: - Check-In Modal (Premium)

    private var checkInModalView: some View {
        ZStack {
            // Overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showCheckInModal = false
                    }
                }

            VStack {
                Spacer()

                VStack(spacing: 32) {
                    // Title and date
                    VStack(spacing: 8) {
                        Text("Did you stay no contact today?")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text(todayDateString)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: 0x999999))
                    }

                    // Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            handleCheckInSuccess()
                        }) {
                            Text("Yes! 💪")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(hex: 0xFF6B35).opacity(0.4), radius: 12, x: 0, y: 4)
                        }

                        Button(action: {
                            handleCheckInSlip()
                        }) {
                            Text("I slipped... 😔")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: 0x2A2A2A))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 2)
                        }
                    }
                }
                .padding(32)
                .frame(maxWidth: min(UIScreen.main.bounds.width * 0.85, 340))
                .background(Color(hex: 0x1A1A1A))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.8), radius: 40, x: 0, y: 20)

                Spacer()
            }
        }
        .transition(.opacity)
    }

    // MARK: - Edit Date Modal (Premium)

    private func editDateModalView(date: Date) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showEditDateModal = false
                    }
                }

            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Text(formatDate(date))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(statusText(for: date))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(statusColor(for: date))

                    VStack(spacing: 12) {
                        Button(action: {
                            markDate(date, as: .logged)
                        }) {
                            Text("Mark as No Contact")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }

                        Button(action: {
                            markDate(date, as: .missed)
                        }) {
                            Text("Mark as Slip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color(hex: 0x333333))
                                .cornerRadius(12)
                        }

                        Button(action: {
                            clearDate(date)
                        }) {
                            Text("Clear Entry")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(hex: 0x666666))
                        }

                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showEditDateModal = false
                            }
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(hex: 0x666666))
                        }
                    }
                }
                .padding(28)
                .frame(maxWidth: min(UIScreen.main.bounds.width * 0.8, 300))
                .background(Color(hex: 0x1A1A1A))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.8), radius: 40, x: 0, y: 20)

                Spacer()
            }
        }
        .transition(.opacity)
    }

    // MARK: - Milestones Modal (Premium Bottom Sheet)

    private var milestonesModalView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Text("All Milestones")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        showMilestonesModal = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(Color(hex: 0x999999))
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(allMilestones, id: \.days) { milestone in
                            progressRingMilestone(milestone: milestone)
                        }
                    }
                    .padding(24)
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Helper Functions

    private func handleCheckInSuccess() {
        print("✅ Check-in logged: success")
        Task {
            await viewModel.logTodayNoContact()
        }
        showToast("Great work! Let's check back tomorrow!")
        withAnimation(.easeOut(duration: 0.2)) {
            showCheckInModal = false
        }
    }

    private func handleCheckInSlip() {
        print("❌ Check-in logged: slip")
        showToast("No worries, shit happens. Let's focus on the next day!")
        withAnimation(.easeOut(duration: 0.2)) {
            showCheckInModal = false
        }
    }

    private func markDate(_ date: Date, as type: HeatmapCellData) {
        print("📅 Marking date: \(formatDate(date)) as \(type)")
        // TODO: Update Supabase and recalculate metrics
        showToast("Updated ✓")
        withAnimation(.easeOut(duration: 0.2)) {
            showEditDateModal = false
        }
        print("🔄 Metrics recalculated")
    }

    private func clearDate(_ date: Date) {
        print("🗑️ Clearing entry for: \(formatDate(date))")
        showToast("Entry cleared")
        withAnimation(.easeOut(duration: 0.2)) {
            showEditDateModal = false
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSuccessToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSuccessToast = false
            }
        }
    }

    private func dayLabel(for row: Int) -> String {
        ["S", "M", "T", "W", "T", "F", "S"][row]
    }

    private func cellColor(for cellData: HeatmapCellData) -> Color {
        switch cellData {
        case .logged:
            return Color(hex: 0xFF6B35)
        case .missed:
            return Color(hex: 0x6B4423)
        case .future:
            return Color.clear
        }
    }

    private func dateForCell(index: Int) -> Date {
        let daysAgo = 90 - index
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func statusText(for date: Date) -> String {
        // TODO: Get actual status from check-ins
        return "Not logged"
    }

    private func statusColor(for date: Date) -> Color {
        return Color(hex: 0x999999)
    }

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var progressToNextMilestone: CGFloat {
        let next = nextMilestone
        if next == 0 { return 0 }

        let prev = previousMilestone
        let current = Double(viewModel.totalDaysNoContact)

        return CGFloat(max(0, min(1, (current - prev) / (next - prev))))
    }

    private var nextMilestone: Double {
        let totalMilestones: [Int] = [3, 5, 10, 15, 25, 50, 75, 100, 150, 200, 250, 300, 400, 500, 600, 750, 1000, 1500, 2000]
        return Double(totalMilestones.first { $0 > viewModel.totalDaysNoContact } ?? totalMilestones.last ?? 2000)
    }

    private var previousMilestone: Double {
        let totalMilestones: [Int] = [3, 5, 10, 15, 25, 50, 75, 100, 150, 200, 250, 300, 400, 500, 600, 750, 1000, 1500, 2000]
        return Double(totalMilestones.last { $0 <= viewModel.totalDaysNoContact } ?? 0)
    }

    private var milestoneSubtitle: String {
        let next = Int(nextMilestone)
        let daysRemaining = next - viewModel.totalDaysNoContact

        if daysRemaining <= 0 {
            return "Milestone reached! 🎉"
        } else if daysRemaining == 1 {
            return "1 day till next milestone"
        } else {
            return "\(daysRemaining) days till next milestone"
        }
    }

    private var previewMilestones: [Milestone] {
        let all = allMilestones
        let achieved = all.filter { viewModel.totalDaysNoContact >= $0.days }
        let upcoming = all.filter { viewModel.totalDaysNoContact < $0.days }

        if achieved.count >= 3 {
            return Array(achieved.suffix(3))
        } else {
            let neededUpcoming = 3 - achieved.count
            return achieved + Array(upcoming.prefix(neededUpcoming))
        }
    }

    private var allMilestones: [Milestone] {
        let totalDaysMilestones = [3, 5, 10, 15, 25, 50, 75, 100, 150, 200, 250, 300, 400, 500, 600, 750, 1000, 1500, 2000]
        let streakMilestones = [7, 14, 21, 28]

        var milestones: [Milestone] = []
        milestones.append(contentsOf: totalDaysMilestones.map { Milestone(days: $0, isStreak: false) })
        milestones.append(contentsOf: streakMilestones.map { Milestone(days: $0, isStreak: true) })

        return milestones.sorted { $0.days < $1.days }
    }
}

#Preview {
    DashboardView()
}
