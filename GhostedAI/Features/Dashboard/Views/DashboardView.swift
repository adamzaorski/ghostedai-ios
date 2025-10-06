import SwiftUI

/// Main dashboard view - completely redesigned for visual hierarchy
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showCheckIn = false
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
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
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCheckIn) {
                CheckInView()
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [viewModel.shareProgress()])
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
                // Header with greeting
                headerSection
                    .padding(.top, 32)
                    .padding(.horizontal, 20)

                // Card 1: Heatmap (darkest, most prominent)
                heatmapCard
                    .padding(.horizontal, 20)

                // Card 2: Daily Check-in (medium background, orange border when pending)
                checkInCard
                    .padding(.horizontal, 20)

                // Card 3: Progress Stats (lighter background, clean)
                statsCard
                    .padding(.horizontal, 20)

                Spacer(minLength: 100)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi, \(viewModel.userName)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Great work! Every action here makes you stronger. Keep it up!")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Card 1: Binary Heatmap (Darkest Card)

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .center) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Text("Daily Progress")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: 0xFF6B35))

                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: 0xFF6B35))
                }
            }

            // Binary Heatmap Grid
            binaryHeatmapGrid

            // Footer
            Text("Current streak: \(viewModel.currentStreak) days")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: 0x666666))
        }
        .padding(16)
        .background(Color(hex: 0x0D0D0D))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    // Binary heatmap grid - checked in (orange) or not (dark)
    private var binaryHeatmapGrid: some View {
        VStack(spacing: 8) {
            // Month labels
            monthLabelsRow

            // Grid of squares
            heatmapGridRows
        }
    }

    private var monthLabelsRow: some View {
        HStack(spacing: 0) {
            // Offset for day labels
            Color.clear.frame(width: 20)

            ForEach(["Sep", "Oct", "Nov", "Dec"], id: \.self) { month in
                Text(month)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: 0x666666))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var heatmapGridRows: some View {
        HStack(alignment: .top, spacing: 4) {
            // Day labels (M, W, F only)
            VStack(spacing: 3) {
                Text("M")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: 0x666666))
                    .frame(width: 14, height: 10)
                Color.clear.frame(height: 10)
                Text("W")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: 0x666666))
                    .frame(width: 14, height: 10)
                Color.clear.frame(height: 10)
                Text("F")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: 0x666666))
                    .frame(width: 14, height: 10)
                Color.clear.frame(height: 10)
                Color.clear.frame(height: 10)
            }

            // Grid of 7 rows x 13 columns
            LazyHGrid(rows: Array(repeating: GridItem(.fixed(10), spacing: 3), count: 7), spacing: 3) {
                ForEach(0..<13, id: \.self) { col in
                    ForEach(0..<7, id: \.self) { row in
                        let isCheckedIn = viewModel.heatmapData[row][col] > 0
                        binaryCell(isCheckedIn: isCheckedIn)
                            .id("cell-\(row)-\(col)")
                    }
                }
            }
        }
    }

    private func binaryCell(isCheckedIn: Bool) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isCheckedIn ? Color(hex: 0xFF6B35) : Color(hex: 0x1A1A1A))
            .frame(width: 10, height: 10)
    }

    // MARK: - Card 2: Daily Check-in (Horizontal Layout)

    private var checkInCard: some View {
        HStack(spacing: 16) {
            // Left: Orange circle icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: viewModel.hasCheckedInToday ? "checkmark.circle.fill" : "clock.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Middle: Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.hasCheckedInToday ? "Checked in today!" : "Daily Check-in Pending")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineSpacing(2)

                Text(viewModel.hasCheckedInToday ? "You're doing great today" : "How are you feeling today?")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: 0x999999))
                    .lineSpacing(2)
            }

            Spacer()

            // Right: Check In button (if not checked in)
            if !viewModel.hasCheckedInToday {
                Button(action: {
                    showCheckIn = true
                }) {
                    Text("Check In")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(16)
        .background(Color(hex: 0x1A1A1A))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    viewModel.hasCheckedInToday
                        ? Color.white.opacity(0.05)
                        : Color(hex: 0xFF6B35).opacity(0.3),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Card 3: Progress Stats (Lighter Background)

    private var statsCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Text("Progress Stats")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                // Share button
                Button(action: {
                    showShareSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle(scale: 0.97))
            }

            // Two columns with separator
            HStack(spacing: 0) {
                // Left: Days since breakup
                VStack(spacing: 8) {
                    Text("\(viewModel.daysSinceBreakup)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: 0xFF6B35))

                    Text("days")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: 0xFF6B35).opacity(0.8))

                    Text("Since breakup")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: 0x999999))
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(Color(hex: 0x333333))
                    .frame(width: 1, height: 80)

                // Right: Days using app
                VStack(spacing: 8) {
                    Text("\(viewModel.daysUsingApp)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: 0x34C759))

                    Text("days")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: 0x34C759).opacity(0.8))

                    Text("Using app")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: 0x999999))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color(hex: 0x242424))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)

            Text("Loading your progress...")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))
        }
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: 0xFF6B35))

            Text(viewModel.errorMessage ?? "Something went wrong")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await viewModel.loadUserData()
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(32)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    DashboardView()
}
