import AppKit
import Foundation
import SwiftUI

protocol SoundPlaying {
    func playReminder(option: ReminderSoundOption, volume: Double)
}

protocol BreakOverlayPresenting: AnyObject {
    func showBreakDue(forceBreakPopup: Bool, onStartBreak: @escaping () -> Void, onSnooze: @escaping () -> Void, onSkip: @escaping () -> Void)
    func dismiss()
}

@MainActor
final class AppController: ObservableObject {
    @Published private(set) var currentState: ReminderState = .idle

    let settingsStore: SettingsStore

    var primaryActionTitle: String {
        switch currentState {
        case .idle:
            return "开始专注"
        case .paused:
            return "恢复专注"
        default:
            return "重新开始"
        }
    }

    var statusLine: String {
        switch currentState {
        case .idle:
            return "当前状态：空闲"
        case .paused:
            return "当前状态：已暂停"
        case .breakDue:
            return "当前状态：该休息了"
        case .focusing(let endAt):
            return "专注中，还剩 \(remainingText(until: endAt))"
        case .onBreak(let endAt):
            return "休息中，还剩 \(remainingText(until: endAt))"
        case .snoozed(let until):
            return "已稍后提醒，还剩 \(remainingText(until: until))"
        }
    }

    private let engine: ReminderEngine
    private let notifier: NotificationServicing
    private let soundPlayer: SoundPlaying
    private let overlay: BreakOverlayPresenting
    private let updater: Updating

    private var updateTimer: Timer?
    private var countdownRefreshTimer: Timer?

    init(
        settingsStore: SettingsStore = SettingsStore(),
        notifier: NotificationServicing = NotificationService(),
        soundPlayer: SoundPlaying = SoundPlayer(),
        overlay: BreakOverlayPresenting = BreakOverlayPanelController(),
        updater: Updating = UpdaterController()
    ) {
        self.settingsStore = settingsStore
        self.notifier = notifier
        self.soundPlayer = soundPlayer
        self.overlay = overlay
        self.updater = updater
        engine = ReminderEngine(config: settingsStore.config)

        engine.onStateChange = { [weak self] nextState in
            Task { @MainActor in
                self?.handleStateChange(nextState)
            }
        }

        settingsStore.onConfigChanged = { [weak self] nextConfig in
            self?.engine.apply(config: nextConfig)
        }

        Task {
            _ = await notifier.requestAuthorization()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            updater.checkForUpdatesInBackground()
        }

        updateTimer = Timer.scheduledTimer(withTimeInterval: 12 * 60 * 60, repeats: true) { [updater] _ in
            updater.checkForUpdatesInBackground()
        }

        countdownRefreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            switch self.currentState {
            case .focusing, .onBreak, .snoozed:
                self.objectWillChange.send()
            case .idle, .breakDue, .paused:
                break
            }
        }

        currentState = engine.currentState
    }

    deinit {
        updateTimer?.invalidate()
        countdownRefreshTimer?.invalidate()
    }

    func startOrResume() {
        switch currentState {
        case .paused:
            engine.resume()
        default:
            engine.start()
        }
    }

    func pause() {
        engine.pause()
    }

    func beginBreakNow() {
        engine.beginBreakNow()
    }

    func skipCurrentBreak() {
        engine.skipCurrentBreak()
    }

    func snooze() {
        engine.snooze(minutes: settingsStore.snoozeMinutes)
    }

    func checkForUpdatesNow() {
        updater.checkForUpdatesManually()
    }

    func playPreviewSound() {
        let option = ReminderSoundOption(rawValue: settingsStore.soundOptionRawValue) ?? .glass
        soundPlayer.playReminder(option: option, volume: settingsStore.soundVolume)
    }

    private func handleStateChange(_ nextState: ReminderState) {
        currentState = nextState

        switch nextState {
        case .breakDue:
            if settingsStore.soundEnabled {
                playPreviewSound()
            }
            if settingsStore.enableSystemNotification {
                notifier.showBreakDueNotification()
            }
            if settingsStore.enableOverlayPopup {
                overlay.showBreakDue(
                    forceBreakPopup: settingsStore.forceBreakPopup,
                    onStartBreak: { [weak self] in self?.beginBreakNow() },
                    onSnooze: { [weak self] in self?.snooze() },
                    onSkip: { [weak self] in self?.skipCurrentBreak() }
                )
            }
        case .onBreak:
            overlay.dismiss()
            if settingsStore.enableSystemNotification {
                notifier.showBreakStartedNotification(durationMinutes: settingsStore.breakDurationMinutes)
            }
        case .idle, .focusing, .snoozed, .paused:
            overlay.dismiss()
        }
    }

    private func remainingText(until: Date) -> String {
        let remaining = max(0, Int(until.timeIntervalSinceNow.rounded()))
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct MainWindowView: View {
    @ObservedObject var controller: AppController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("定时休息提醒器")
                .font(.system(size: 28, weight: .bold))

            Text(controller.statusLine)
                .font(.headline)

            HStack(spacing: 8) {
                Button(controller.primaryActionTitle) {
                    controller.startOrResume()
                }
                Button("暂停") {
                    controller.pause()
                }
                Button("开始休息") {
                    controller.beginBreakNow()
                }
                Button("稍后提醒") {
                    controller.snooze()
                }
                Button("跳过本次") {
                    controller.skipCurrentBreak()
                }
            }

            SettingsView(store: controller.settingsStore) {
                controller.playPreviewSound()
            }

            HStack(spacing: 10) {
                Button("立即检查更新") {
                    controller.checkForUpdatesNow()
                }

                Button("退出应用") {
                    NSApp.terminate(nil)
                }
            }
        }
        .padding(20)
        .frame(minWidth: 760, minHeight: 620)
    }
}
