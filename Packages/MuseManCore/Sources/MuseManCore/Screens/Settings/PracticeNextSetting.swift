import SwiftUI

@propertyWrapper
struct PracticeNextSetting: DynamicProperty {
    @AppStorage("isPracticeNextOn") private var isOn = true

    var wrappedValue: Bool {
        get { isOn }
        nonmutating set { isOn = newValue }
    }

    var projectedValue: Binding<Bool> {
        $isOn
    }
}
