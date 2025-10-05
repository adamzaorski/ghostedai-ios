import SwiftUI

/// Glassmorphic card for multiple choice/multi-select options
struct GlassOptionCard: View {
    let text: String
    let isSelected: Bool
    let isMultiSelect: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Selection indicator - larger and bolder
                if isMultiSelect {
                    // Checkbox for multi-select
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? Color.DS.accentOrangeStart : .DS.textSecondary.opacity(0.6))
                } else {
                    // Radio button for single select
                    Image(systemName: isSelected ? "circle.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? Color.DS.accentOrangeStart : .DS.textSecondary.opacity(0.6))
                }

                // Option text
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.DS.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(16)
            .background(
                ZStack {
                    // Solid dark background (no glass)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: 0x3A3A3C))

                    // Border - orange glow when selected
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient.DS.orangeAccent,
                                lineWidth: 2
                            )
                            .shadow(
                                color: Color.DS.accentOrangeStart.opacity(0.4),
                                radius: 8,
                                x: 0,
                                y: 0
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    }
                }
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.97))
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        VStack(spacing: Spacing.m) {
            GlassOptionCard(
                text: "Single select - Not selected",
                isSelected: false,
                isMultiSelect: false,
                action: {}
            )

            GlassOptionCard(
                text: "Single select - Selected",
                isSelected: true,
                isMultiSelect: false,
                action: {}
            )

            GlassOptionCard(
                text: "Multi-select - Not selected",
                isSelected: false,
                isMultiSelect: true,
                action: {}
            )

            GlassOptionCard(
                text: "Multi-select - Selected",
                isSelected: true,
                isMultiSelect: true,
                action: {}
            )
        }
        .padding()
    }
}
