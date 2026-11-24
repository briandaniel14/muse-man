import AppKit
import ApplicationServices
import CoreGraphics

struct Window {
    let id: Int
    let title: String
    let bounds: CGRect
}

func windows(pid: Int32) -> [Window] {
    let info = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
    return info
        .filter { $0[kCGWindowOwnerPID as String] as? Int32 == pid && $0[kCGWindowLayer as String] as? Int == 0 }
        .compactMap { window -> Window? in
            guard
                let id = window[kCGWindowNumber as String] as? Int,
                let dictionary = window[kCGWindowBounds as String] as? NSDictionary,
                let bounds = CGRect(dictionaryRepresentation: dictionary)
            else {
                return nil
            }
            return Window(id: id, title: window[kCGWindowName as String] as? String ?? "", bounds: bounds)
        }
        .sorted { $0.id < $1.id }
}

func target(pid: Int32, selector: String?) -> Window? {
    let all = windows(pid: pid)
    guard let selector else {
        return all.max { $0.bounds.width * $0.bounds.height < $1.bounds.width * $1.bounds.height }
    }
    if let number = Int(selector) {
        return all.indices.contains(number - 1) ? all[number - 1] : nil
    }
    return all.first { $0.title == selector }
}

func screenPoint(in window: Window, pixelX: String, pixelY: String) -> CGPoint {
    let center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
    let screen = NSScreen.screens.first { screen in
        let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
        return number.map { CGDisplayBounds($0).contains(center) } ?? false
    }
    let scale = (screen ?? NSScreen.main)?.backingScaleFactor ?? 2
    return CGPoint(
        x: window.bounds.minX + (Double(pixelX) ?? 0) / scale,
        y: window.bounds.minY + (Double(pixelY) ?? 0) / scale,
    )
}

func post(_ type: CGEventType, at point: CGPoint) {
    CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: point, mouseButton: .left)?
        .post(tap: .cghidEventTap)
}

func resize(pid: Int32, window: Window, width: Double, height: Double) -> Bool {
    let app = AXUIElementCreateApplication(pid)
    var value: CFTypeRef?
    AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &value)
    let elements = value as? [AXUIElement] ?? []
    let element = elements.first { element in
        var position: CFTypeRef?
        var origin = CGPoint.zero
        AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &position)
        if let position, CFGetTypeID(position) == AXValueGetTypeID() {
            AXValueGetValue(unsafeBitCast(position, to: AXValue.self), .cgPoint, &origin)
        }
        return origin == window.bounds.origin
    }
    guard let element else {
        return false
    }
    var size = CGSize(width: width, height: height)
    guard let axSize = AXValueCreate(.cgSize, &size) else {
        return false
    }
    return AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, axSize) == .success
}

let arguments = CommandLine.arguments.dropFirst().map(\.self)
let selector = ProcessInfo.processInfo.environment["MAC_APP_WINDOW"].flatMap { $0.isEmpty ? nil : $0 }

if arguments.first == "locked" {
    let session = CGSessionCopyCurrentDictionary() as? [String: Any]
    exit(session?["CGSSessionScreenIsLocked"] as? Bool == true ? 0 : 1)
}

guard let pid = arguments.dropFirst().first.flatMap(Int32.init) else {
    let usage = "usage: helper locked | windows <pid> | window <pid> | front <pid> | click <pid> <x> <y>"
        + " | drag <pid> <x1> <y1> <x2> <y2> | resize <pid> <width> <height>\n"
    FileHandle.standardError.write(Data(usage.utf8))
    exit(1)
}

if arguments.first == "windows" {
    for (index, window) in windows(pid: pid).enumerated() {
        let name = window.title.isEmpty ? "(untitled)" : window.title
        print("\(index + 1)\t\(name)\t\(Int(window.bounds.width))×\(Int(window.bounds.height))")
    }
    exit(0)
}

guard let window = target(pid: pid, selector: selector) else {
    FileHandle.standardError.write(Data("no window \(selector ?? "") found: see scripts/mac-app windows\n".utf8))
    exit(1)
}

switch arguments.first {
case "window":
    print(window.id)
case "front":
    exit(NSWorkspace.shared.frontmostApplication?.processIdentifier == pid ? 0 : 1)
case "click":
    let point = screenPoint(in: window, pixelX: arguments[2], pixelY: arguments[3])
    for type in [CGEventType.leftMouseDown, .leftMouseUp] {
        post(type, at: point)
        usleep(80000)
    }
case "drag":
    let start = screenPoint(in: window, pixelX: arguments[2], pixelY: arguments[3])
    let end = screenPoint(in: window, pixelX: arguments[4], pixelY: arguments[5])
    post(.leftMouseDown, at: start)
    usleep(400_000)
    let steps = 30
    for step in 1 ... steps {
        let fraction = Double(step) / Double(steps)
        let point = CGPoint(x: start.x + (end.x - start.x) * fraction, y: start.y + (end.y - start.y) * fraction)
        post(.leftMouseDragged, at: point)
        usleep(20000)
    }
    usleep(300_000)
    post(.leftMouseUp, at: end)
case "resize":
    exit(resize(pid: pid, window: window, width: Double(arguments[2]) ?? 0, height: Double(arguments[3]) ?? 0) ? 0 : 1)
default:
    exit(1)
}
