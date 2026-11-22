import AppKit
import CoreGraphics

func mainWindow(pid: Int32) -> (id: Int, bounds: CGRect)? {
    let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
    return windows
        .filter { $0[kCGWindowOwnerPID as String] as? Int32 == pid && $0[kCGWindowLayer as String] as? Int == 0 }
        .compactMap { window -> (id: Int, bounds: CGRect)? in
            guard
                let id = window[kCGWindowNumber as String] as? Int,
                let dictionary = window[kCGWindowBounds as String] as? NSDictionary,
                let bounds = CGRect(dictionaryRepresentation: dictionary)
            else {
                return nil
            }
            return (id, bounds)
        }
        .max { $0.bounds.width * $0.bounds.height < $1.bounds.width * $1.bounds.height }
}

let arguments = CommandLine.arguments.dropFirst().map(\.self)
guard let pid = arguments.dropFirst().first.flatMap(Int32.init), let window = mainWindow(pid: pid) else {
    FileHandle.standardError.write(Data("usage: helper window <pid> | click <pid> <x> <y>; no window found\n".utf8))
    exit(1)
}

switch arguments.first {
case "window":
    print(window.id)
case "click":
    let scale = NSScreen.main?.backingScaleFactor ?? 2
    let point = CGPoint(
        x: window.bounds.minX + (Double(arguments[2]) ?? 0) / scale,
        y: window.bounds.minY + (Double(arguments[3]) ?? 0) / scale,
    )
    for type in [CGEventType.leftMouseDown, .leftMouseUp] {
        CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: point, mouseButton: .left)?
            .post(tap: .cghidEventTap)
        usleep(80000)
    }
default:
    exit(1)
}
