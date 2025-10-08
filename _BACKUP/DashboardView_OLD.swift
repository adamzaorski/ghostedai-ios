import SwiftUI

/// Main dashboard view - redesigned with Total Days No-Contact as PRIMARY hero metric
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showCheckIn = false
    @State private var showDayLoggedConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Pure black background
                Color.black
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else if viewModel.errorMessage != nil {
                    errorView
                } else {
                    mainContent
                }

                // Fixed CTA button above tab bar
                ctaButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCheckIn) {
                CheckInView()
            }
            .task {
                await viewModel.loadUserData()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. Welcome Header
                welcomeHeader
                    .padding(.top, 32)
                    .padding(.horizontal, 20)

                // 2. Total Days No-Contact (PRIMARY HERO CARD)
                totalDaysHeroCard
                    .padding(.horizontal, 20)

                // 3. Current Streak Card
                currentStreakCard
                    .padding(.horizontal, 20)

                // 4. No-Contact Progress Chart
                progressChartCard
                    .padding(.horizontal, 20)

                // 5. Milestones Strip
                milestonesSection

                // 6. Quick Stats Card
                quickStatsCard
                    .padding(.horizontal, 20)

                // Bottom padding for fixed CTA button
                Spacer()
                    .frame(height: 80)
            }
        }
    }

    // MARK: - 1. Welcome Header

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi, \(viewModel.userName)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Great work! Every action here makes you stronger. Keep it up!")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 2. Total Days No-Contact (HERO)

    private var totalDaysHeroCard: some View {
        GlassCard(style: .premium) {
            VStack(spacing: 8) {
                // Title
                Text("Days No Contact")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()
                    .frame(height: 8)

                // MASSIVE NUMBER with gradient
                Text("\(viewModel.totalDaysNoContact) days")
                    .font(.system(size: 96, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Since date
                if let breakupDate = viewModel.breakupDate {
                    Text("Since \(breakupDate, formatter: monthDayFormatter)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: 0x999999))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
        }
    }

    // MARK: - 3. Current Streak Card

    private var currentStreakCard: some View {
        GlassCard(style: .premium) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Streak")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    // Fire emoji
                    Text("🔥")
                        .font(.system(size: 40))

                    // Streak number
                    Text("\(viewModel.currentStreak) days")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text("Your longest: \(viewModel.personalBestStreak) days")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: 0x999999))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
    }

    // MARK: - 4. No-Contact Progress Chart

    private var progressChartCard: some View {
        GlassCard(style: .premium) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Last 90 Days")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                // Month labels
                monthLabels

                // GitHub-style heatmap
                heatmapGrid

                Text("Each square = one day no contact")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: 0x999999))
            }
            .padding(20)
        }
    }

    private var monthLabels: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.monthLabels, id: \.self) { label in
                Text(label)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: 0x999999))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.leading, 30) // Offset for day labels
    }

    private var heatmapGrid: some View {
        HStack(alignment: .top, spacing: 3) {
            // Day labels (S M T W T F S)
            VStack(spacing: 3) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hex: 0x999999))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.trailing, 8)

            // Heatmap cells (13 weeks × 7 days)
            LazyHGrid(rows: Array(repeating: GridItem(.fixed(10), spacing: 3), count: 7), spacing: 3) {
                ForEach(0..<91, id: \.self) { index in
                    heatmapCell(for: index)
                }
            }
        }
    }

    private func heatmapCell(for index: Int) -> some View {
        let cellData = viewModel.heatmapData[index]

        return RoundedRectangle(cornerRadius: 2)
            .fill(cellColor(for: cellData))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(cellData == .future ? Color(hex: 0xFF6B35) : Color.clear, lineWidth: 1)
            )
            .frame(width: 10, height: 10)
    }

    private func cellColor(for data: HeatmapCellData) -> Color {
        switch data {
        case .logged:
            return Color(hex: 0xFF6B35) // Orange - day logged
        case .missed:
            return Color(hex: 0x1A1A1A) // Dark - missed
        case .future:
            return Color.clear // Empty with border
        }
    }

    // MARK: - 5. Milestones Section

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.leading, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.milestones, id: \.days) { milestone in
                        milestoneCard(milestone)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func milestoneCard(_ milestone: Milestone) -> some View {
        let isUnlocked = viewModel.totalDaysNoContact >= milestone.days
        let isNext = viewModel.totalDaysNoContact + 1 == milestone.days

        return VStack(spacing: 8) {
            // Icon
            Image(systemName: isUnlocked ? "checkmark" : "lock.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(isUnlocked ? .white : (isNext ? Color(hex: 0xFF6B35) : Color(hex: 0x999999)))

            // Number
            Text("\(milestone.days)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(isUnlocked ? .white : (isNext ? Color(hex: 0xFF6B35) : Color(hex: 0x999999)))

            // Label
            Text("days")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(isUnlocked ? .white : (isNext ? Color(hex: 0xFF6B35) : Color(hex: 0x999999)))
        }
        .frame(width: 100, height: 120)
        .background(
            isUnlocked
                ? Color(hex: 0xFF6B35)
                : Color.clear
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isUnlocked ? Color.clear : (isNext ? Color(hex: 0xFF6B35) : Color(hex: 0x333333)),
                    lineWidth: isNext ? 2 : 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 6. Quick Stats Card

    private var quickStatsCard: some View {
        GlassCard(style: .premium) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Numbers")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 0) {
                    // Left column - Current Streak
                    VStack(spacing: 8) {
                        Text("\(viewModel.currentStreak) days")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Current streak")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: 0x999999))
                    }
                    .frame(maxWidth: .infinity)

                    // Divider
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1)

                    // Right column - Using App
                    VStack(spacing: 8) {
                        Text("\(viewModel.daysUsingApp) days")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)

                        Text("Using app")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: 0x999999))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(24)
        }
    }

    // MARK: - 7. Fixed CTA Button

    private var ctaButton: some View {
        Button(action: {
            if !viewModel.hasLoggedToday {
                Task {
                    await viewModel.logTodayNoContact()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showDayLoggedConfirmation = true
                    }
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showDayLoggedConfirmation = false
                    }
                }
            }
        }) {
            HStack(spacing: 8) {
                if viewModel.hasLoggedToday {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .semibold))
                }

                Text(viewModel.hasLoggedToday ? "✓ Day Logged" : "Log Today No-Contact")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
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
            )
            .clipShape(RoundedRectangle(cornerRadius: 27))
        }
        .disabled(viewModel.hasLoggedToday)
        .overlay(
            Group {
                if showDayLoggedConfirmation {
                    Text("Day logged!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(hex: 0x4CAF50))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .offset(y: -70)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        )
    }

    // MARK: - Loading & Error States

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color(hex: 0xFF6B35))
                .scaleEffect(1.5)

            Text("Loading your progress...")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))
        }
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: 0xFF6B35))

            Text(viewModel.errorMessage ?? "Something went wrong")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await viewModel.refresh()
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(hex: 0xFF6B35))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Date Formatter

    private var monthDayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
}

// MARK: - Heatmap Cell Data

enum HeatmapCellData {
    case logged   // Orange square
    case missed   // Dark square
    case future   // Empty with orange border
}

// MARK: - Milestone Model

struct Milestone {
    let days: Int
}

// MARK: - Preview

#Preview {
    DashboardView()
}
