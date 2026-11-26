import Foundation

extension String {
    var trimmedName: String? {
        let name = trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? nil : name
    }
}
