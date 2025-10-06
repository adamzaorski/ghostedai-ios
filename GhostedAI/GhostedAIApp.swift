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
        // Configure tab bar appearance GLOBALLY before any views load
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.backgroundEffect = nil

        // Configure tab item colors
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)
        ]

        // Apply globally
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = false
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
            // Uncomment the view you want to test:
            ContentView()
            // DesignSystemPreviewView()
        }
        .modelContainer(sharedModelContainer)
    }
}
