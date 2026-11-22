import SwiftUI

struct DateTimeButton: View {
    @Binding var date: Date
    let latest: Date
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 6) {
                Text(date.formatted(date: .abbreviated, time: .shortened))
                Image(systemName: "chevron.down")
                    .font(Theme.caption)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isPresented, arrowEdge: .bottom) {
            DatePicker("Started", selection: $date, in: ...latest)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(Theme.accent)
                .padding()
                .presentationCompactAdaptation(.popover)
        }
    }
}
