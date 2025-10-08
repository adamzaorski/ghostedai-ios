//
//  AuthStateManager.swift
//  GhostedAI
//
//  Manages global authentication state for the app
//  Controls view hierarchy switching between auth flow and main app
//

import SwiftUI
import Combine
import Auth

/// Global authentication state manager
/// Controls the root view hierarchy based on authentication status
@MainActor
class AuthStateManager: ObservableObject {

    // MARK: - Published Properties

    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = true

    // MARK: - Initialization

    init() {
        print("🔐 [AuthState] Initializing AuthStateManager...")
        Task {
            await checkAuthStatus()
        }
    }

    // MARK: - Authentication Status

    /// Check current authentication status on app launch
    func checkAuthStatus() async {
        print("🔐 [AuthState] Checking authentication status...")
        isLoading = true

        do {
            if let user = try await SupabaseService.shared.getCurrentUser() {
                self.isAuthenticated = true
                self.currentUser = user
                print("✅ [AuthState] User authenticated: \(user.id)")
                print("   Email: \(user.email ?? "N/A")")
            } else {
                self.isAuthenticated = false
                self.currentUser = nil
                print("⚠️ [AuthState] No authenticated user found")
            }
        } catch {
            print("❌ [AuthState] Error checking auth status: \(error.localizedDescription)")
            self.isAuthenticated = false
            self.currentUser = nil
        }

        isLoading = false
        print("🔐 [AuthState] Auth check complete - isAuthenticated: \(isAuthenticated)")
    }

    // MARK: - Sign In

    /// Update state after successful sign in
    /// Called by sign-in ViewModels after authentication succeeds
    func signIn(user: User) {
        print("🔐 [AuthState] User signed in: \(user.id)")
        self.isAuthenticated = true
        self.currentUser = user
        print("✅ [AuthState] View hierarchy will switch to MainTabView")
    }

    // MARK: - Sign Out

    /// Sign out current user and reset auth state
    func signOut() async {
        print("🔐 [AuthState] Signing out user...")

        do {
            try await SupabaseService.shared.signOut()

            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
            }

            print("✅ [AuthState] User signed out successfully")
            print("✅ [AuthState] View hierarchy will switch to WelcomeView")
        } catch {
            print("❌ [AuthState] Sign out failed: \(error.localizedDescription)")
            // Still reset local state even if API call fails
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }

    // MARK: - Debug Helpers

    /// Print current auth state for debugging
    func debugPrintState() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔐 AUTH STATE DEBUG")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("isAuthenticated: \(isAuthenticated)")
        print("currentUser: \(currentUser?.id.uuidString ?? "nil")")
        print("userEmail: \(currentUser?.email ?? "nil")")
        print("isLoading: \(isLoading)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}
