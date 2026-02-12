import SwiftUI

@main
struct BreakReminderDesktopApp: App {
    @StateObject private var quickViewModel: QuickControlViewModel
    @StateObject private var settingsViewModel: SettingsViewModel

    init() {
        let coordinator = ReminderCoordinator()
        _quickViewModel = StateObject(wrappedValue: QuickControlViewModel(coordinator: coordinator))
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(coordinator: coordinator))
        DesignAssetLoader.shared.prepare()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarQuickControlView(viewModel: quickViewModel)
        } label: {
            Label("休息提醒", systemImage: quickViewModel.menuBarSymbolName)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsWindowView(viewModel: settingsViewModel)
        }
    }
}
