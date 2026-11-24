import SwiftUI

public struct SettingsScreen: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                PracticeNextSection()
                InstrumentsSection()
            }
            .padding(.horizontal, Theme.margin)
        }
        .modifier(PaperScreen(title: "Settings", kind: .sheet))
        #if os(macOS)
            .frame(width: Theme.settingsWindowSize.width, height: Theme.settingsWindowSize.height)
            .tint(Theme.accent)
        #endif
    }
}

#if os(iOS)
    struct SettingsSheet: View {
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationStack {
                SettingsScreen()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                dismiss()
                            }
                        }
                    }
            }
        }
    }
#endif
