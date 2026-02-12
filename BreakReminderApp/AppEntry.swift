import SwiftUI

@main
struct BreakReminderDesktopApp: App {
    @StateObject private var controller = AppController()

    var body: some Scene {
        WindowGroup("休息提醒") {
            MainWindowView(controller: controller)
        }
    }
}
