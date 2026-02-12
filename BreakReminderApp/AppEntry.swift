import SwiftUI

@main
struct BreakReminderDesktopApp: App {
    @StateObject private var controller = MenuBarController()

    var body: some Scene {
        MenuBarExtra("休息提醒", systemImage: controller.menuBarSymbolName) {
            MenuBarContentView(controller: controller)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(store: controller.settingsStore)
        }
    }
}
