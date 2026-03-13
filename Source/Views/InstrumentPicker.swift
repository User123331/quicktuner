import SwiftUI

struct InstrumentPicker: View {
    @Binding var selectedInstrument: InstrumentType

    var body: some View {
        Menu {
            ForEach(InstrumentType.allCases) { instrument in
                Button(action: {
                    selectedInstrument = instrument
                }) {
                    Label(
                        instrument.displayName,
                        systemImage: selectedInstrument == instrument ? "checkmark" : ""
                    )
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "guitars")
                Text(selectedInstrument.displayName)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.secondary.opacity(0.1))
            .cornerRadius(8)
        }
        .menuStyle(.button)
    }
}

#Preview {
    InstrumentPicker(selectedInstrument: .constant(.guitar6))
        .padding()
}
