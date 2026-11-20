import SwiftUI

struct PartScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var part: Part
    @State private var isConfirmingDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                PartFields(part: $part)
                Button("Delete Part", role: .destructive) {
                    isConfirmingDelete = true
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
            .padding(.horizontal, Theme.margin)
        }
        .onChange(of: part) {
            try? library.updatePart(part)
        }
        .confirmationDialog(
            "Delete \(part.displayName)?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible,
        ) {
            Button("Delete Part", role: .destructive) {
                try? library.deletePart(id: part.id)
                dismiss()
            }
        } message: {
            Text("This can't be undone.")
        }
        .paperScreen(title: part.displayName)
    }
}

struct PartFields: View {
    @Binding var part: Part

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldRow(label: "Song") {
                Text(part.song.title)
            }
            FieldRow(label: "Status") {
                Picker("Status", selection: $part.status) {
                    ForEach(Part.Status.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            FieldRow(label: "Part Note") {
                TextField("Chord shapes, reminders…", text: $part.note, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(4...)
            }
        }
    }
}
