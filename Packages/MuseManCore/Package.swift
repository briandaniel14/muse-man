// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MuseManCore",
    platforms: [.iOS("26.6"), .macOS("26.6")],
    products: [
        .library(name: "MuseManCore", targets: ["MuseManCore"]),
    ],
    targets: [
        .target(
            name: "MuseManCore",
            resources: [.process("Resources")],
            swiftSettings: [.defaultIsolation(MainActor.self)],
        ),
        .testTarget(
            name: "MuseManCoreTests",
            dependencies: ["MuseManCore"],
            swiftSettings: [.defaultIsolation(MainActor.self)],
        ),
    ],
)
