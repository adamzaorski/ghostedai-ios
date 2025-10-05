import SwiftUI

/// Glassmorphic date picker for breakup date selection
struct GlassDatePicker: View {
    @Binding var selectedDate: Date

    var body: some View {
        VStack(spacing: Spacing.l) {
            // Selected date display - large orange text
            Text(formattedDate)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.DS.accentOrangeStart)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedDate)

            // Date picker with white text
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 180)
            .colorScheme(.dark) // Force dark mode for white text
            .accentColor(Color.DS.accentOrangeStart)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: selectedDate)
    }
}

#Preview {
    ZStack {
        Color.DS.primaryBlack
            .ignoresSafeArea()

        GlassDatePicker(selectedDate: .constant(Date()))
            .padding()
    }
}
