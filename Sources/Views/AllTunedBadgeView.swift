import SwiftUI

/// Completion badge shown when all strings are tuned
/// Minimal text design with checkmark icon and dismiss on tap
struct AllTunedBadgeView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
                .symbolRenderingMode(.multicolor)

            VStack(spacing: 4) {
                Text("All")
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                Text("Tuned")
                    .font(.system(.title2, design: .rounded).weight(.semibold))
            }
            .foregroundColor(.primary)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.5), lineWidth: 2)
                )
        )
        .onTapGesture {
            onDismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()

        AllTunedBadgeView(onDismiss: {})
    }
}
