import SwiftUI
import PhotosUI
import StoreKit

/// Comprehensive profile view with user settings and account management
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authState: AuthStateManager
    @State private var showEditProfile = false
    @State private var showEditField: ProfileField? = nil
    @State private var showChangePassword = false
    @State private var showDeleteAccount = false
    @State private var showSignOutConfirmation = false
    @State private var showComingSoon = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Profile Header
                        profileHeader
                            .padding(.top, 32)

                        // Referral Banner
                        referralBanner
                            .padding(.horizontal, 20)

                        // Personal Details
                        personalDetailsSection
                            .padding(.horizontal, 20)

                        // Personalization
                        personalizationSection
                            .padding(.horizontal, 20)

                        // Subscription
                        subscriptionSection
                            .padding(.horizontal, 20)

                        // Notifications
                        notificationsSection
                            .padding(.horizontal, 20)

                        // Support & Feedback
                        supportSection
                            .padding(.horizontal, 20)

                        // Legal
                        legalSection
                            .padding(.horizontal, 20)

                        // Account Settings
                        accountSection
                            .padding(.horizontal, 20)

                        // Sign Out
                        signOutButton
                            .padding(.top, 8)
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $showEditField) { field in
                EditFieldSheet(field: field, viewModel: viewModel)
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordSheet()
            }
            .alert("Coming Soon", isPresented: $showComingSoon) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("This feature will be available soon!")
            }
            .alert("Sign Out", isPresented: $showSignOutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authState.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccount) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteAccount()
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
            .task {
                await viewModel.loadUserData()
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Photo
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
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

                    Text(viewModel.userInitial)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.95))

            // Name
            Text(viewModel.userName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            // Email
            Text(viewModel.userEmail)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))

            // Edit Profile button
            Button(action: {
                showEditField = .name
            }) {
                Text("Edit Profile")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: 0xFF6B35))
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.98))
        }
    }

    // MARK: - Referral Banner

    private var referralBanner: some View {
        Button(action: {
            showComingSoon = true
        }) {
            GlassCard(style: .premium) {
                HStack(spacing: 16) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: 0xFF6B35))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Invite Friends")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Get 1 month free for each friend")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: 0x999999))
                    }

                    Spacer()

                    Text("COMING SOON")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: 0xFF6B35))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: 0xFF6B35).opacity(0.2))
                        .clipShape(Capsule())
                }
                .padding(16)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: 0xFF6B35).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }

    // MARK: - Personal Details Section

    private var personalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("PERSONAL DETAILS")

            VStack(spacing: 1) {
                settingsRow(icon: "person.fill", label: "Name", value: viewModel.userName) {
                    showEditField = .name
                }
                settingsRow(icon: "envelope.fill", label: "Email", value: viewModel.userEmail) {
                    showEditField = .email
                }
                settingsRow(icon: "calendar", label: "Age", value: "\(viewModel.userAge)") {
                    showEditField = .age
                }
                settingsRow(icon: "person.2.fill", label: "Gender", value: viewModel.userGender) {
                    showEditField = .gender
                }
                settingsRow(icon: "heart.fill", label: "Relationship Orientation", value: viewModel.relationshipOrientation) {
                    showEditField = .relationshipOrientation
                }
            }
        }
    }

    // MARK: - Personalization Section

    private var personalizationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("PERSONALIZATION")

            VStack(spacing: 1) {
                settingsRow(icon: "target", label: "Your Goals", value: viewModel.primaryGoal) {
                    showComingSoon = true
                }
                settingsRow(icon: "message.fill", label: "AI Voice Style", value: viewModel.aiVoiceStyle) {
                    showComingSoon = true
                }

                // Cursing toggle
                HStack(spacing: 16) {
                    Image(systemName: "exclamationmark.bubble.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(viewModel.cursingAllowed ? Color(hex: 0xFF6B35) : Color(hex: 0x666666))
                        .frame(width: 24)

                    Text("Cursing Allowed")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)

                    Spacer()

                    Toggle("", isOn: $viewModel.cursingAllowed)
                        .tint(Color(hex: 0xFF6B35))
                        .labelsHidden()
                }
                .padding(16)
                .background(Color(hex: 0x0D0D0D))

                settingsRow(icon: "person.crop.circle", label: "Ex's Name", value: viewModel.exName) {
                    showEditField = .exName
                }
                settingsRow(icon: "doc.text.fill", label: "Relationship Details", value: "View Summary") {
                    showComingSoon = true
                }
            }
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("SUBSCRIPTION")

            VStack(spacing: 16) {
                // Current plan info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.subscriptionPlan)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)

                        Text(viewModel.subscriptionStatus)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: 0x999999))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: 0x666666))
                }
                .padding(16)
                .background(Color(hex: 0x0D0D0D))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    // TODO: Integrate with Adapty subscription management
                    showComingSoon = true
                }
            }
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("NOTIFICATIONS")

            VStack(spacing: 1) {
                toggleRow(icon: "bell.fill", label: "Daily Check-in Reminders", isOn: $viewModel.dailyReminders)
                toggleRow(icon: "flame.fill", label: "Streak Notifications", isOn: $viewModel.streakNotifications)
                toggleRow(icon: "message.fill", label: "AI Messages", isOn: $viewModel.aiMessages)
                toggleRow(icon: "chart.bar.fill", label: "Weekly Progress Reports", isOn: $viewModel.weeklyReports)
            }
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("HELP & FEEDBACK")

            VStack(spacing: 1) {
                settingsRow(icon: "envelope.fill", label: "Support Email", value: "") {
                    // TODO: Open mail composer to support@ghostedai.com
                    showComingSoon = true
                }
                settingsRow(icon: "lightbulb.fill", label: "Feature Requests", value: "") {
                    // TODO: Open mail with feature request template
                    showComingSoon = true
                }
                settingsRow(icon: "star.fill", label: "Rate the App", value: "") {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
            }
        }
    }

    // MARK: - Legal Section

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("LEGAL")

            VStack(spacing: 1) {
                settingsRow(icon: "doc.text.fill", label: "Terms & Conditions", value: "") {
                    // TODO: Open Safari with ghostedai.com/terms
                    showComingSoon = true
                }
                settingsRow(icon: "lock.shield.fill", label: "Privacy Policy", value: "") {
                    // TODO: Open Safari with ghostedai.com/privacy
                    showComingSoon = true
                }
            }
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("ACCOUNT")

            VStack(spacing: 1) {
                settingsRow(icon: "key.fill", label: "Change Password", value: "") {
                    showChangePassword = true
                }

                // DEBUG: Reset Check-ins
                settingsRow(icon: "arrow.counterclockwise.circle.fill", label: "Reset Check-ins (DEBUG)", value: "", isDestructive: true) {
                    Task {
                        await viewModel.resetAllCheckIns()
                    }
                }

                settingsRow(icon: "trash.fill", label: "Delete Account", value: "", isDestructive: true) {
                    showDeleteAccount = true
                }
            }
        }
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        Button(action: {
            showSignOutConfirmation = true
        }) {
            Text("Sign Out")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: 0x999999))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }

    // MARK: - Helper Views

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color(hex: 0x666666))
            .tracking(0.5)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private func settingsRow(
        icon: String,
        label: String,
        value: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDestructive ? Color(hex: 0xFF3B30) : Color(hex: 0x666666))
                    .frame(width: 24)

                Text(label)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(isDestructive ? Color(hex: 0xFF3B30) : .white)

                Spacer()

                if !value.isEmpty {
                    Text(value)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(hex: 0x999999))
                        .lineLimit(1)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: 0x666666))
            }
            .padding(16)
            .background(Color(hex: 0x0D0D0D))
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }

    private func toggleRow(icon: String, label: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isOn.wrappedValue ? Color(hex: 0xFF6B35) : Color(hex: 0x666666))
                .frame(width: 24)

            Text(label)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: isOn)
                .tint(Color(hex: 0xFF6B35))
                .labelsHidden()
        }
        .padding(16)
        .background(Color(hex: 0x0D0D0D))
    }
}

// MARK: - Profile Field Enum

enum ProfileField: Identifiable {
    case name, email, age, gender, relationshipOrientation, exName

    var id: String {
        switch self {
        case .name: return "name"
        case .email: return "email"
        case .age: return "age"
        case .gender: return "gender"
        case .relationshipOrientation: return "relationshipOrientation"
        case .exName: return "exName"
        }
    }

    var title: String {
        switch self {
        case .name: return "Name"
        case .email: return "Email"
        case .age: return "Age"
        case .gender: return "Gender"
        case .relationshipOrientation: return "Relationship Orientation"
        case .exName: return "Ex's Name"
        }
    }
}

// MARK: - Edit Field Sheet

struct EditFieldSheet: View {
    let field: ProfileField
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var value = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    GlassTextField(placeholder: "Enter \(field.title.lowercased())", text: $value)
                        .padding(.horizontal, 20)
                        .padding(.top, 32)

                    Spacer()
                }
            }
            .navigationTitle(field.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: 0x999999))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateField(field, value: value)
                        dismiss()
                    }
                    .foregroundColor(Color(hex: 0xFF6B35))
                }
            }
        }
        .onAppear {
            switch field {
            case .name: value = viewModel.userName
            case .email: value = viewModel.userEmail
            case .age: value = "\(viewModel.userAge)"
            case .gender: value = viewModel.userGender
            case .relationshipOrientation: value = viewModel.relationshipOrientation
            case .exName: value = viewModel.exName
            }
        }
    }
}

// MARK: - Change Password Sheet

struct ChangePasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    GlassSecureField(placeholder: "Current password", text: $currentPassword)
                    GlassSecureField(placeholder: "New password", text: $newPassword)
                    GlassSecureField(placeholder: "Confirm new password", text: $confirmPassword)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: 0x999999))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // TODO: Implement password change
                        dismiss()
                    }
                    .foregroundColor(Color(hex: 0xFF6B35))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
