import SwiftUI

struct MissionsView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Text("Missions - Redesigning")
                .foregroundColor(.white)
                .font(.title2)
        }
    }
}

#Preview {
    MissionsView()
}
