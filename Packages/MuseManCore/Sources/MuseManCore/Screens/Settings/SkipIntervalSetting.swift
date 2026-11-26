import SwiftUI

@propertyWrapper
struct SkipIntervalSetting: DynamicProperty {
    @AppStorage("skipInterval") private var interval = SkipInterval.standard

    var wrappedValue: SkipInterval {
        get { interval }
        nonmutating set { interval = newValue }
    }

    var projectedValue: Binding<SkipInterval> {
        $interval
    }
}
