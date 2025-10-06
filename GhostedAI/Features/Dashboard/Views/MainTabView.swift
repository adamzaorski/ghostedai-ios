import SwiftUI

/// Main tab navigation container for the app
struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
        // Configure tab bar appearance BEFORE view loads
        configureTabBarAppearance()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: selectedTab == 0 ? "square.grid.2x2.fill" : "square.grid.2x2")
                }
                .tag(0)

            // Chat Tab
            ChatPlaceholderView()
                .tabItem {
                    Label("Chat", systemImage: selectedTab == 1 ? "message.fill" : "message")
                }
                .tag(1)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 2 ? "person.fill" : "person")
                }
                .tag(2)
        }
        .tint(Color(hex: 0xFF6B35)) // Orange tint for selected tab
        .toolbarBackground(.black, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

    /// Configure unified tab bar appearance across all tabs
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // UNIFIED: Solid black background for all tabs
        appearance.backgroundColor = UIColor(hex: 0x000000)

        // UNIFIED: Subtle top border (1pt, white with 0.05 opacity)
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.05)
        appearance.shadowImage = nil // Use default shadow line

        // Remove blur/transparency effects
        appearance.backgroundEffect = nil

        // STANDARD SIZING: Icon size 25x25pt (Apple HIG compliant)
        // Note: iOS automatically sizes icons to 25x25pt when using SF Symbols

        // INACTIVE TAB STATE: Gray icons and labels
        let inactiveColor = UIColor(hex: 0x666666)
        appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: inactiveColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium) // SF Pro Text
        ]
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = UIColor(hex: 0xFF6B35)

        // ACTIVE TAB STATE: Orange icons and labels
        let activeColor = UIColor(hex: 0xFF6B35)
        appearance.stackedLayoutAppearance.selected.iconColor = activeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: activeColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold) // SF Pro Text
        ]
        appearance.stackedLayoutAppearance.selected.badgeBackgroundColor = activeColor

        // Apply UNIFIED appearance to all states
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        // Ensure tab bar respects safe area for home indicator
        UITabBar.appearance().isTranslucent = false

        // Remove any extra shadow effects (we only want the top border)
        UITabBar.appearance().layer.shadowColor = UIColor.clear.cgColor
        UITabBar.appearance().layer.shadowOffset = .zero
        UITabBar.appearance().layer.shadowOpacity = 0
        UITabBar.appearance().layer.shadowRadius = 0
    }
}

// MARK: - Chat Placeholder

struct ChatPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.DS.primaryBlack
                    .ignoresSafeArea()

                VStack(spacing: Spacing.xl) {
                    Spacer()

                    // Icon
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color(hex: 0xFF6B35))

                    // Title
                    VStack(spacing: 12) {
                        Text("AI Chat")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.DS.textPrimary)

                        Text("Coming soon! Chat with our AI companion for personalized support and guidance through your healing journey.")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.DS.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 32)
                    }

                    // Feature list
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "brain.head.profile", text: "AI trained on breakup recovery")
                        FeatureRow(icon: "heart.fill", text: "Empathetic, Gen Z-friendly tone")
                        FeatureRow(icon: "lock.fill", text: "100% private & confidential")
                        FeatureRow(icon: "sparkles", text: "Personalized advice & exercises")
                    }
                    .padding(24)
                    .background(Color(hex: 0x1A1A1A))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 32)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Profile Placeholder

struct ProfilePlaceholderView: View {
    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.DS.primaryBlack
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Header
                        VStack(spacing: 16) {
                            // Avatar placeholder
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)

                                Image(systemName: "person.fill")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Profile")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.DS.textPrimary)

                            Text("Manage your account and preferences")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.DS.textSecondary)
                        }
                        .padding(.top, Spacing.xxl)

                        // Settings sections (placeholder)
                        VStack(spacing: 12) {
                            ProfileMenuItem(icon: "person.circle", title: "Account", subtitle: "Edit profile & preferences")
                            ProfileMenuItem(icon: "bell", title: "Notifications", subtitle: "Manage notifications")
                            ProfileMenuItem(icon: "lock.shield", title: "Privacy", subtitle: "Data & privacy settings")
                            ProfileMenuItem(icon: "questionmark.circle", title: "Help & Support", subtitle: "FAQs and contact us")
                        }
                        .padding(.horizontal, Spacing.l)

                        // Sign out button
                        Button(action: {
                            showSignOutConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18, weight: .semibold))

                                Text("Sign Out")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.DS.errorRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: 0x1A1A1A))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, Spacing.l)

                        Spacer(minLength: Spacing.xxl)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Sign Out", isPresented: $showSignOutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    handleSignOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    private func handleSignOut() {
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
}

// MARK: - Profile Menu Item

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        Button(action: {
            print("Tapped: \(title)")
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: 0xFF6B35))
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.DS.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.DS.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: 0x8E8E93))
            }
            .padding(16)
            .background(Color(hex: 0x1A1A1A))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
