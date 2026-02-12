// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "BreakReminderCore",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "BreakReminderCore", targets: ["BreakReminderCore"])
    ],
    targets: [
        .target(
            name: "BreakReminderCore",
            path: "BreakReminderApp",
            sources: [
                "Timer/ReminderTypes.swift",
                "Timer/ReminderStateMachine.swift",
                "Timer/ReminderEngine.swift",
                "Settings/SettingsStore.swift",
                "Updates/UpdateVersionComparator.swift"
            ]
        ),
        .testTarget(
            name: "BreakReminderAppTests",
            dependencies: ["BreakReminderCore"],
            path: "BreakReminderAppTests"
        )
    ]
)
