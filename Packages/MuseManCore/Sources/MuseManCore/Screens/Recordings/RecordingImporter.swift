import SwiftUI

extension View {
    func recordingImporter(isPresented: Binding<Bool>, onImport: @escaping (Data, Date?) -> Void) -> some View {
        fileImporter(isPresented: isPresented, allowedContentTypes: [.audio], allowsMultipleSelection: true) { result in
            for url in (try? result.get()) ?? [] {
                let accessing = url.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                if let audio = try? Data(contentsOf: url) {
                    onImport(audio, try? url.resourceValues(forKeys: [.creationDateKey]).creationDate)
                }
            }
        }
    }
}
