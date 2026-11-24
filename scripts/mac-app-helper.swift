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

func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    AXUIElementCopyAttributeValue(element, name as CFString, &value)
    return value
}

func text(_ element: AXUIElement, _ name: String) -> String {
    attribute(element, name) as? String ?? ""
}

func axWindow(pid: Int32, window: Window) -> AXUIElement? {
    let elements = attribute(AXUIElementCreateApplication(pid), kAXWindowsAttribute) as? [AXUIElement] ?? []
    return elements.first { element in
        var origin = CGPoint.zero
        if let position = attribute(element, kAXPositionAttribute), CFGetTypeID(position) == AXValueGetTypeID() {
            AXValueGetValue(unsafeBitCast(position, to: AXValue.self), .cgPoint, &origin)
        }
        return origin == window.bounds.origin
    }
}

func resize(_ element: AXUIElement, width: Double, height: Double) -> Bool {
    var size = CGSize(width: width, height: height)
    guard let axSize = AXValueCreate(.cgSize, &size) else {
        return false
    }
    return AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, axSize) == .success
}

func children(_ element: AXUIElement) -> [AXUIElement] {
    attribute(element, kAXChildrenAttribute) as? [AXUIElement] ?? []
}

func descendants(_ element: AXUIElement) -> [AXUIElement] {
    children(element).flatMap { [$0] + descendants($0) }
}

func actions(_ element: AXUIElement) -> [String] {
    var names: CFArray?
    AXUIElementCopyActionNames(element, &names)
    return names as? [String] ?? []
}

func labels(_ element: AXUIElement) -> [String] {
    [kAXTitleAttribute, kAXDescriptionAttribute, kAXPlaceholderValueAttribute]
        .map { text(element, $0) }
        .filter { !$0.isEmpty }
}

func value(_ element: AXUIElement) -> String {
    switch attribute(element, kAXValueAttribute) {
    case let string as String: string
    case let number as NSNumber: number.stringValue
    default: ""
    }
}

func role(_ element: AXUIElement) -> String {
    String(text(element, kAXRoleAttribute).trimmingPrefix("AX"))
}

func describe(_ element: AXUIElement) -> String {
    let label = labels(element).first.map { " \"\($0)\"" } ?? ""
    let current = value(element)
    return role(element) + label + (current.isEmpty ? "" : " = \(current)")
}

func printTree(_ element: AXUIElement, depth: Int) {
    let shown = !labels(element).isEmpty || !value(element).isEmpty
    if shown {
        print(String(repeating: "  ", count: depth) + describe(element))
    }
    for child in children(element) {
        printTree(child, depth: shown ? depth + 1 : depth)
    }
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

func matches(_ label: String, in elements: [AXUIElement]) -> [AXUIElement] {
    let exact = elements.filter { labels($0).contains(label) }
    guard exact.isEmpty else {
        return exact
    }
    return elements.filter { labels($0).contains { $0.localizedCaseInsensitiveContains(label) } }
}

func choose(_ label: String, from found: [AXUIElement], number: String?) -> AXUIElement {
    if let number {
        guard let index = Int(number), found.indices.contains(index - 1) else {
            fail("no match \(number) for \"\(label)\": \(found.count) found")
        }
        return found[index - 1]
    }
    guard found.count == 1 else {
        guard !found.isEmpty else {
            fail("nothing labelled \"\(label)\": see scripts/mac-app elements")
        }
        let list = found.enumerated().map { "  \($0.offset + 1)\t\(describe($0.element))" }.joined(separator: "\n")
        fail("\(found.count) match \"\(label)\"; pass the number of the one you mean:\n" + list)
    }
    return found[0]
}

func press(_ element: AXUIElement) {
    guard AXUIElementPerformAction(element, kAXPressAction as CFString) == .success else {
        fail("press failed on \(describe(element))")
    }
}

func pressable(_ element: AXUIElement) -> Bool {
    actions(element).contains(kAXPressAction)
}

func menuItems(pid: Int32) -> [AXUIElement] {
    guard let bar = attribute(AXUIElementCreateApplication(pid), kAXMenuBarAttribute),
          CFGetTypeID(bar) == AXUIElementGetTypeID()
    else {
        return []
    }
    return descendants(unsafeBitCast(bar, to: AXUIElement.self)).filter { role($0) == "MenuItem" }
}

let arguments = CommandLine.arguments.dropFirst().map(\.self)
let selector = ProcessInfo.processInfo.environment["MAC_APP_WINDOW"].flatMap { $0.isEmpty ? nil : $0 }

if arguments.first == "locked" {
    let session = CGSessionCopyCurrentDictionary() as? [String: Any]
    exit(session?["CGSSessionScreenIsLocked"] as? Bool == true ? 0 : 1)
}

guard let pid = arguments.dropFirst().first.flatMap(Int32.init) else {
    let usage = "usage: helper locked | windows <pid> | window <pid> | front <pid> | click <pid> <x> <y>"
        + " | drag <pid> <x1> <y1> <x2> <y2> | resize <pid> <width> <height> | elements <pid>"
        + " | press <pid> <label> [n] | fill <pid> <label> <text> [n] | pick <pid> <label> <item> [n]\n"
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
    guard let element = axWindow(pid: pid, window: window) else {
        exit(1)
    }
    exit(resize(element, width: Double(arguments[2]) ?? 0, height: Double(arguments[3]) ?? 0) ? 0 : 1)
case "elements", "press", "fill", "pick":
    guard let element = axWindow(pid: pid, window: window) else {
        fail("no accessibility window: is Accessibility allowed for this terminal?")
    }
    let all = descendants(element)
    let label = arguments.count > 2 ? arguments[2] : ""
    switch arguments.first {
    case "press":
        let found = matches(label, in: all.filter(pressable))
        let candidates = found.isEmpty ? matches(label, in: menuItems(pid: pid)) : found
        press(choose(label, from: candidates, number: arguments[safe: 3]))
    case "fill":
        let fields = all.filter { ["TextField", "TextArea", "ComboBox"].contains(role($0)) }
        let field = choose(label, from: matches(label, in: fields), number: arguments[safe: 4])
        AXUIElementSetAttributeValue(field, kAXFocusedAttribute as CFString, kCFBooleanTrue)
        let text = arguments[3] as CFString
        guard AXUIElementSetAttributeValue(field, kAXValueAttribute as CFString, text) == .success else {
            fail("fill failed on \(describe(field))")
        }
    case "pick":
        let popups = all.filter { role($0) == "PopUpButton" }
        let popup = choose(label, from: matches(label, in: popups), number: arguments[safe: 4])
        press(popup)
        usleep(300_000)
        let items = descendants(popup).filter { role($0) == "MenuItem" }
        let found = matches(arguments[3], in: items)
        guard found.count == 1 else {
            children(popup).forEach { AXUIElementPerformAction($0, kAXCancelAction as CFString) }
            fail("pick \"\(arguments[3])\" from: " + items.compactMap { labels($0).first }.joined(separator: ", "))
        }
        press(found[0])
    default:
        printTree(element, depth: 0)
    }
default:
    exit(1)
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
