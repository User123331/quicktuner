import SwiftUI

struct InputLevelMeter: View {
    let level: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary.opacity(0.1))

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * CGFloat(level)))
            }
        }
        .frame(height: 8)
        .animation(.smooth(duration: 0.15), value: level)
    }
}

#Preview {
    InputLevelMeter(level: 0.6)
        .padding()
        .frame(width: 300)
}
