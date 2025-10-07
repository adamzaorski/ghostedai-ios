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

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            // Layer 1: Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                        .padding(.top, 16)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasAppeared)

                    // Welcome Section
                    welcomeSection
                        .padding(.top, 32)

                    // Hero Card - Total Days
                    totalDaysCard
                        .padding(.top, 24)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.0), value: hasAppeared)

                    // Dual Streak Cards
                    streakCardsSection
                        .padding(.top, 28)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: hasAppeared)

                    // Progress Chart
                    progressChartCard
                        .padding(.top, 32)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: hasAppeared)

                    // Milestones Section
                    milestonesSection
                        .padding(.top, 28)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: hasAppeared)

                    // Bottom padding for floating button
                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 20)
            }

            // Layer 2: Floating Check-In Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    checkInButton
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                }
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

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            // App branding - premium sizing
            Text("GhostedAI")
                .font(.system(size: 32, weight: .bold))
                .kerning(-0.5)
                .foregroundColor(.white)

            Spacer()

            // Streak button - pill shape with glow
            Button(action: {
                showStreakAlert()
            }) {
                HStack(spacing: 6) {
                    Text("🔥")
                        .font(.system(size: 16))
                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(22)
                .shadow(color: Color(hex: 0xFF6B35).opacity(0.3), radius: 8, x: 0, y: 2)
            }
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

    // MARK: - Total Days Card (Hero - Premium)

    private var totalDaysCard: some View {
        VStack(spacing: 24) {
            // Number and "days" text
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(viewModel.totalDaysNoContact)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: 0xFF6B35).opacity(0.5), radius: 20, x: 0, y: 8)

                Text("days")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundColor(Color(hex: 0xFF8E53))
                    .opacity(0.6)
            }

            // Progress bar - FIXED with proper ZStack
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track (FULL WIDTH - always visible)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: 0x2A2A2A))
                            .frame(height: 6)

                        // Progress fill (PERCENTAGE of width)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressToNextMilestone, height: 6)
                            .animation(.easeOut(duration: 1.2), value: progressToNextMilestone)
                    }
                }
                .frame(height: 6)
                .frame(maxWidth: .infinity)

                // Subtitle
                Text(milestoneSubtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: 0x999999))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(32)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x1E1E1E), Color(hex: 0x0A0A0A)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.6), radius: 24, x: 0, y: 8)
        .shadow(color: Color(hex: 0xFF6B35).opacity(0.15), radius: 16, x: 0, y: 4)
    }

    // MARK: - Streak Cards Section (Unified Premium)

    private var streakCardsSection: some View {
        HStack(spacing: 16) {
            // Current Streak Card
            VStack(spacing: 8) {
                Text("🔥")
                    .font(.system(size: 48))
                    .shadow(color: Color(hex: 0xFF6B35).opacity(0.4), radius: 8, x: 0, y: 0)

                Text("Current streak")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: 0x999999))

                Text("\(viewModel.currentStreak) days")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: 0xFF6B35).opacity(0.3), radius: 8, x: 0, y: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(28)
            .background(Color(hex: 0x1A1A1A))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)

            // Best Streak Card
            VStack(spacing: 8) {
                Text("🏆")
                    .font(.system(size: 48))
                    .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 8, x: 0, y: 0)

                Text("Best streak")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: 0x999999))

                Text("\(viewModel.personalBestStreak) days")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.white.opacity(0.2), radius: 8, x: 0, y: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(28)
            .background(Color(hex: 0x1A1A1A))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
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

    // MARK: - Milestones Section (Premium)

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Milestones")
                    .font(.system(size: 22, weight: .semibold))
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

            // Preview milestones
            HStack(spacing: 20) {
                ForEach(previewMilestones, id: \.days) { milestone in
                    milestoneIcon(milestone: milestone)
                }
            }
        }
    }

    private func milestoneIcon(milestone: Milestone) -> some View {
        let achieved = viewModel.totalDaysNoContact >= milestone.days

        return VStack(spacing: 12) {
            ZStack {
                if achieved {
                    // Achieved: Filled with glow
                    Circle()
                        .fill(Color(hex: 0xFF6B35))
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(hex: 0xFF6B35).opacity(0.5), radius: 12, x: 0, y: 4)
                } else {
                    // Not achieved: Outline only
                    Circle()
                        .strokeBorder(Color(hex: 0x333333), lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .opacity(0.4)
                }

                VStack(spacing: 4) {
                    Text(milestone.isStreak ? "🔥" : "⭐")
                        .font(.system(size: 40))

                    Text("\(milestone.days)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(achieved ? .white : Color(hex: 0x666666))
                }
            }

            Text("\(milestone.days) \(milestone.isStreak ? "day streak" : "days")")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))
        }
    }

    // MARK: - Check-In Button (Floating Premium)

    private var checkInButton: some View {
        Button(action: {
            if !viewModel.hasLoggedToday {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                showCheckInModal = true
            }
        }) {
            Text(buttonText)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 120, height: 56)
                .background(
                    buttonBackground
                )
                .cornerRadius(28)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                .shadow(color: viewModel.hasLoggedToday ? Color.black.opacity(0.3) : Color(hex: 0xFF6B35).opacity(0.6), radius: viewModel.hasLoggedToday ? 8 : 20, x: 0, y: viewModel.hasLoggedToday ? 2 : 8)
                .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .disabled(viewModel.hasLoggedToday)
    }

    private var buttonText: String {
        if viewModel.hasLoggedToday {
            return "Next:\n\(timeUntilNextCheckIn)"
        } else {
            return "Check In"
        }
    }

    private var buttonBackground: some View {
        Group {
            if viewModel.hasLoggedToday {
                Color(hex: 0x333333)
            } else {
                LinearGradient(
                    colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
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
                            milestoneIcon(milestone: milestone)
                        }
                    }
                    .padding(24)
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Helper Functions

    private func showStreakAlert() {
        let alert = UIAlertController(
            title: "Current Streak",
            message: "\(viewModel.currentStreak) days",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }

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
