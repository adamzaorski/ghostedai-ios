//
//  SupabaseService.swift
//  GhostedAI
//
//  Created by Adam Zaorski on 10/6/25.
//

import Foundation
import Supabase

/// Service for managing Supabase authentication and data operations
/// Singleton pattern ensures single source of truth for auth state
final class SupabaseService {

    // MARK: - Codable Models

    /// User profile data for insertion
    private struct UserProfileInsert: Encodable {
        let id: String
        let firstName: String
        let age: Int
        let gender: String?
        let relationshipOrientation: String?
        let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id
            case firstName = "first_name"
            case age
            case gender
            case relationshipOrientation = "relationship_orientation"
            case createdAt = "created_at"
        }
    }

    /// Onboarding answers data for insertion
    private struct OnboardingAnswersInsert: Encodable {
        let userId: String
        let answers: Data // JSON-encoded answers
        let completedAt: String

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case answers
            case completedAt = "completed_at"
        }
    }

    /// Onboarding answers response
    private struct OnboardingAnswersResponse: Decodable {
        let answers: Data
    }

    /// Check-in record from database
    struct CheckIn: Decodable {
        let id: String
        let userId: String
        let date: String
        let type: String  // "success" or "slip"
        let mood: String?
        let journal: String?
        let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case date
            case type
            case mood
            case journal
            case createdAt = "created_at"
        }
    }

    // MARK: - Singleton

    static let shared = SupabaseService()

    // MARK: - Properties

    private let client: SupabaseClient

    // MARK: - Initialization

    private init() {
        guard let url = URL(string: SupabaseConfig.url) else {
            fatalError("Invalid Supabase URL")
        }

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }

    // MARK: - Authentication

    /// Sign up a new user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password (minimum 6 characters)
    /// - Returns: Authenticated user
    /// - Throws: SupabaseError if signup fails
    func signUp(email: String, password: String) async throws -> User {
        guard !email.isEmpty else {
            throw SupabaseError.invalidEmail("Email cannot be empty")
        }

        guard password.count >= 6 else {
            throw SupabaseError.invalidPassword("Password must be at least 6 characters")
        }

        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )

            // AuthResponse has a .user property that extracts user from either .session or .user case
            return response.user
        } catch {
            throw SupabaseError.authFailed("Sign up failed: \(error.localizedDescription)")
        }
    }

    /// Sign in an existing user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: Authenticated user
    /// - Throws: SupabaseError if signin fails
    func signIn(email: String, password: String) async throws -> User {
        guard !email.isEmpty else {
            throw SupabaseError.invalidEmail("Email cannot be empty")
        }

        guard !password.isEmpty else {
            throw SupabaseError.invalidPassword("Password cannot be empty")
        }

        do {
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )

            // AuthResponse has a .user property that extracts user from either .session or .user case
            return response.user
        } catch {
            throw SupabaseError.authFailed("Sign in failed: \(error.localizedDescription)")
        }
    }

    /// Sign out the current user
    /// - Throws: SupabaseError if signout fails
    func signOut() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            throw SupabaseError.authFailed("Sign out failed: \(error.localizedDescription)")
        }
    }

    /// Get the currently authenticated user
    /// - Returns: Current user if authenticated, nil otherwise
    func getCurrentUser() async throws -> User? {
        do {
            let session = try await client.auth.session
            return session.user
        } catch {
            // No active session is not an error, just return nil
            return nil
        }
    }

    // MARK: - User Profile

    /// Save user profile data to the database
    /// - Parameters:
    ///   - userId: User's unique ID
    ///   - firstName: User's first name
    ///   - age: User's age
    ///   - gender: User's gender
    ///   - relationshipOrientation: User's relationship orientation
    /// - Throws: SupabaseError if save fails
    func saveUserProfile(
        userId: UUID,
        firstName: String,
        age: Int,
        gender: String? = nil,
        relationshipOrientation: String? = nil
    ) async throws {
        print("🟢 [SupabaseService] saveUserProfile() called")
        print("🟢 [SupabaseService] User ID: \(userId)")
        print("🟢 [SupabaseService] First Name: \(firstName)")
        print("🟢 [SupabaseService] Age: \(age)")
        print("🟢 [SupabaseService] Gender: \(gender ?? "nil")")
        print("🟢 [SupabaseService] Relationship Orientation: \(relationshipOrientation ?? "nil")")

        guard !firstName.isEmpty else {
            print("❌ [SupabaseService] Error: First name is empty!")
            throw SupabaseError.invalidData("First name cannot be empty")
        }

        guard age > 0, age < 150 else {
            print("❌ [SupabaseService] Error: Invalid age: \(age)")
            throw SupabaseError.invalidData("Invalid age")
        }

        let profile = UserProfileInsert(
            id: userId.uuidString,
            firstName: firstName,
            age: age,
            gender: gender,
            relationshipOrientation: relationshipOrientation,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )

        print("⬆️ [SupabaseService] Attempting INSERT to user_profiles table...")

        do {
            let response = try await client
                .from("user_profiles")
                .insert(profile)
                .execute()

            print("✅ [SupabaseService] INSERT successful!")
            print("✅ [SupabaseService] Response status: \(response.response.statusCode ?? 0)")
        } catch {
            print("❌ [SupabaseService] INSERT failed!")
            print("❌ [SupabaseService] Error: \(error)")
            print("❌ [SupabaseService] Error localized: \(error.localizedDescription)")
            throw SupabaseError.databaseError("Failed to save user profile: \(error.localizedDescription)")
        }
    }

    // MARK: - Onboarding Data

    /// Save user's onboarding answers to the database
    /// - Parameters:
    ///   - userId: User's unique ID
    ///   - answers: Dictionary of onboarding answers (questionId -> answer data)
    /// - Throws: SupabaseError if save fails
    func saveOnboardingAnswers(userId: UUID, answers: [String: Any]) async throws {
        print("🔵 [SupabaseService] saveOnboardingAnswers() called")
        print("🔵 [SupabaseService] User ID: \(userId)")
        print("🔵 [SupabaseService] Answers count: \(answers.count)")
        print("🔵 [SupabaseService] Answers keys: \(answers.keys.sorted())")

        guard !answers.isEmpty else {
            print("❌ [SupabaseService] Error: Answers dictionary is empty!")
            throw SupabaseError.invalidData("Onboarding answers cannot be empty")
        }

        // Convert answers dictionary to JSON data
        let answersData: Data
        do {
            answersData = try JSONSerialization.data(withJSONObject: answers, options: [.prettyPrinted])
            if let jsonString = String(data: answersData, encoding: .utf8) {
                print("📄 [SupabaseService] JSON payload preview (first 500 chars):")
                print(String(jsonString.prefix(500)))
            }
        } catch {
            print("❌ [SupabaseService] Failed to encode answers to JSON: \(error)")
            throw SupabaseError.invalidData("Failed to encode onboarding answers: \(error.localizedDescription)")
        }

        let onboardingData = OnboardingAnswersInsert(
            userId: userId.uuidString,
            answers: answersData,
            completedAt: ISO8601DateFormatter().string(from: Date())
        )

        print("⬆️ [SupabaseService] Attempting INSERT to onboarding_answers table...")

        do {
            let response = try await client
                .from("onboarding_answers")
                .insert(onboardingData)
                .execute()

            print("✅ [SupabaseService] INSERT successful!")
            print("✅ [SupabaseService] Response status: \(response.response.statusCode ?? 0)")
        } catch {
            print("❌ [SupabaseService] INSERT failed!")
            print("❌ [SupabaseService] Error: \(error)")
            print("❌ [SupabaseService] Error localized: \(error.localizedDescription)")
            throw SupabaseError.databaseError("Failed to save onboarding answers: \(error.localizedDescription)")
        }
    }

    /// Retrieve user's onboarding answers from the database
    /// - Parameter userId: User's unique ID
    /// - Returns: Dictionary of onboarding answers, or nil if not found
    /// - Throws: SupabaseError if retrieval fails
    func getOnboardingAnswers(userId: UUID) async throws -> [String: Any]? {
        do {
            let response: OnboardingAnswersResponse = try await client
                .from("onboarding_answers")
                .select()
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()
                .value

            // Parse JSON data from the answers field
            if let json = try? JSONSerialization.jsonObject(with: response.answers, options: []) as? [String: Any] {
                return json
            }

            return nil
        } catch {
            // Not found is okay, return nil
            return nil
        }
    }

    // MARK: - Check-ins Data

    /// Retrieve all check-ins for a user
    /// - Parameter userId: User's unique ID
    /// - Returns: Array of check-in records
    /// - Throws: SupabaseError if retrieval fails
    func getCheckIns(userId: UUID) async throws -> [CheckIn] {
        print("🔍 [SupabaseService] Fetching check-ins for user_id: \(userId)")

        do {
            let response: [CheckIn] = try await client
                .from("check_ins")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("date", ascending: false)
                .execute()
                .value

            print("✅ [SupabaseService] Fetched \(response.count) check-ins from database")
            return response
        } catch {
            print("❌ [SupabaseService] Failed to fetch check-ins: \(error.localizedDescription)")
            // Return empty array instead of throwing - no check-ins is a valid state
            return []
        }
    }

    /// Save a new check-in to the database
    /// - Parameters:
    ///   - userId: User's unique ID
    ///   - date: Date of the check-in
    ///   - type: Type of check-in ("success" or "slip")
    ///   - mood: Optional mood description
    ///   - journal: Optional journal entry
    /// - Throws: SupabaseError if save fails
    func saveCheckIn(
        userId: UUID,
        date: Date,
        type: String,
        mood: String? = nil,
        journal: String? = nil
    ) async throws {
        print("💾 [SupabaseService] Saving check-in...")
        print("   User ID: \(userId)")
        print("   Date: \(ISO8601DateFormatter().string(from: date))")
        print("   Type: \(type)")
        print("   Mood: \(mood ?? "nil")")

        guard type == "success" || type == "slip" else {
            throw SupabaseError.invalidData("Check-in type must be 'success' or 'slip'")
        }

        // Create check-in record
        struct CheckInInsert: Encodable {
            let userId: String
            let date: String
            let type: String
            let mood: String?
            let journal: String?
            let createdAt: String

            enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case date
                case type
                case mood
                case journal
                case createdAt = "created_at"
            }
        }

        let checkIn = CheckInInsert(
            userId: userId.uuidString,
            date: ISO8601DateFormatter().string(from: date),
            type: type,
            mood: mood,
            journal: journal,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )

        do {
            let response = try await client
                .from("check_ins")
                .insert(checkIn)
                .execute()

            print("✅ [SupabaseService] Check-in saved successfully!")
            print("   Response status: \(response.response.statusCode ?? 0)")
        } catch {
            print("❌ [SupabaseService] Failed to save check-in: \(error.localizedDescription)")
            throw SupabaseError.databaseError("Failed to save check-in: \(error.localizedDescription)")
        }
    }

    // MARK: - User Data Management

    /// Update user profile with additional information
    /// - Parameters:
    ///   - userId: User's unique ID
    ///   - updates: Dictionary of fields to update
    /// - Throws: SupabaseError if update fails
    func updateUserProfile(userId: UUID, updates: [String: Any]) async throws {
        guard !updates.isEmpty else {
            throw SupabaseError.invalidData("Updates cannot be empty")
        }

        // Convert updates dictionary to JSON data for Supabase
        let updatesData: Data
        do {
            updatesData = try JSONSerialization.data(withJSONObject: updates, options: [])
        } catch {
            throw SupabaseError.invalidData("Failed to encode updates: \(error.localizedDescription)")
        }

        // Convert JSON data to raw string for update query
        guard let updatesJSON = String(data: updatesData, encoding: .utf8) else {
            throw SupabaseError.invalidData("Failed to convert updates to JSON")
        }

        do {
            // Use raw JSON string for update
            try await client
                .from("user_profiles")
                .update(updatesJSON)
                .eq("id", value: userId.uuidString)
                .execute()
        } catch {
            throw SupabaseError.databaseError("Failed to update user profile: \(error.localizedDescription)")
        }
    }

    /// Delete all user data (GDPR compliance)
    /// - Parameter userId: User's unique ID
    /// - Throws: SupabaseError if deletion fails
    func deleteUserData(userId: UUID) async throws {
        do {
            // Delete onboarding answers
            try await client
                .from("onboarding_answers")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .execute()

            // Delete user profile
            try await client
                .from("user_profiles")
                .delete()
                .eq("id", value: userId.uuidString)
                .execute()

            // Delete auth user (requires service role key in production)
            try await signOut()
        } catch {
            throw SupabaseError.databaseError("Failed to delete user data: \(error.localizedDescription)")
        }
    }
}

// MARK: - Custom Errors

/// Custom error types for Supabase operations
enum SupabaseError: LocalizedError {
    case invalidEmail(String)
    case invalidPassword(String)
    case invalidData(String)
    case authFailed(String)
    case databaseError(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail(let message),
             .invalidPassword(let message),
             .invalidData(let message),
             .authFailed(let message),
             .databaseError(let message),
             .networkError(let message):
            return message
        }
    }
}
