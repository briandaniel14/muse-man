import SwiftUI

struct PlaybackKeyPress: Equatable {
    enum Key: Equatable {
        case playPause
        case skip(Skip)
    }

    let key: Key
    let id = UUID()
}

struct PlaybackKeys: ViewModifier {
    let isEnabled: Bool
    @Binding var keyPress: PlaybackKeyPress?
    @FocusState private var isScreenFocused: Bool
    @FocusState private var isFieldFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFieldFocused)
            .focusable(isEnabled, interactions: .edit)
            .focusEffectDisabled()
            .focused($isScreenFocused)
            .onKeyPress(.space) { press(.playPause) }
            .onKeyPress(.leftArrow) { press(.skip(.back)) }
            .onKeyPress(.rightArrow) { press(.skip(.forward)) }
            .onAppear {
                isScreenFocused = isEnabled
            }
    }

    private func press(_ key: PlaybackKeyPress.Key) -> KeyPress.Result {
        guard isEnabled, !isFieldFocused else {
            return .ignored
        }
        keyPress = PlaybackKeyPress(key: key)
        return .handled
    }
}
