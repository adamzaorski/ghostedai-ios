import SwiftUI

/// Missions placeholder view - daily challenges coming soon
struct MissionsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Target icon with orange gradient
                    Image(systemName: "target")
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8E53)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Title
                    Text("Missions")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    // Subtitle
                    Text("Daily challenges coming soon")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: 0x999999))

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MissionsPlaceholderView()
}
