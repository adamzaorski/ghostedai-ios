//
//  GhostedAIApp.swift
//  GhostedAI
//
//  Created by Adam Zaorski on 10/5/25.
//

import SwiftUI
import SwiftData

@main
struct GhostedAIApp: App {

    init() {
        // FORCE BLACK TAB BAR - Configure EVERY appearance property
        let appearance = UITabBarAppearance()

        // Start with opaque configuration
        appearance.configureWithOpaqueBackground()

        // Force black background in EVERY way possible
        appearance.backgroundColor = .black
        appearance.backgroundEffect = nil
        appearance.shadowColor = nil
        appearance.shadowImage = nil

        // Configure ALL layout appearances (stacked, inline, compact)
        let inactiveColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        let activeColor = UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)

        // Stacked layout (default for iPhone)
        appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: inactiveColor]
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = activeColor

        appearance.stackedLayoutAppearance.selected.iconColor = activeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: activeColor]
        appearance.stackedLayoutAppearance.selected.badgeBackgroundColor = activeColor

        // Inline layout
        appearance.inlineLayoutAppearance.normal.iconColor = inactiveColor
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: inactiveColor]
        appearance.inlineLayoutAppearance.selected.iconColor = activeColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: activeColor]

        // Compact layout
        appearance.compactInlineLayoutAppearance.normal.iconColor = inactiveColor
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: inactiveColor]
        appearance.compactInlineLayoutAppearance.selected.iconColor = activeColor
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: activeColor]

        // Apply to ALL tab bar states
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        // iOS 15+
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        // Force properties directly on UITabBar
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().backgroundColor = .black
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Root View

/// Root view that swaps between auth flow and main app based on authentication state
/// This prevents users from swiping back to login screens once authenticated
struct RootView: View {
    @StateObject private var authState = AuthStateManager()

    var body: some View {
        Group {
            if authState.isLoading {
                // Show loading screen while checking auth status
                LoadingView()
            } else if authState.isAuthenticated {
                // User is authenticated → Show main app (NO navigation stack)
                MainTabView()
                    .environmentObject(authState)
            } else {
                // User not authenticated → Show auth flow
                WelcomeView()
                    .environmentObject(authState)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authState.isAuthenticated)
    }
}

// MARK: - Loading View

/// Simple loading screen shown while checking initial auth status
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.DS.primaryBlack
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ProgressView()
                    .tint(Color(hex: 0xFF6B35))
                    .scaleEffect(1.5)

                Text("GhostedAI")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
