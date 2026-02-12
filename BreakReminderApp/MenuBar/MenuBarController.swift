import AppKit
import Combine
import CoreText
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
final class ReminderCoordinator: ObservableObject {
    @Published private(set) var currentState: ReminderState = .idle

    let settingsStore: SettingsStore

    var menuBarSymbolName: String {
        switch currentState {
        case .idle:
            return "clock.badge"
        case .focusing:
            return "timer"
        case .breakDue:
            return "exclamationmark.circle.fill"
        case .onBreak:
            return "cup.and.saucer.fill"
        case .snoozed:
            return "zzz"
        case .paused:
            return "pause.circle.fill"
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

    func openSettingsWindow() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
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

@MainActor
final class QuickControlViewModel: ObservableObject {
    private let coordinator: ReminderCoordinator
    private var cancellables = Set<AnyCancellable>()

    init(coordinator: ReminderCoordinator) {
        self.coordinator = coordinator

        coordinator.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var menuBarSymbolName: String { coordinator.menuBarSymbolName }
    var statusLine: String { coordinator.statusLine }

    var primaryActionTitle: String {
        switch coordinator.currentState {
        case .idle:
            return "开始专注"
        case .paused:
            return "恢复"
        default:
            return "重新开始"
        }
    }

    func startOrResume() { coordinator.startOrResume() }
    func pause() { coordinator.pause() }
    func beginBreakNow() { coordinator.beginBreakNow() }
    func snooze() { coordinator.snooze() }
    func skipCurrentBreak() { coordinator.skipCurrentBreak() }
    func openSettingsWindow() { coordinator.openSettingsWindow() }
    func checkForUpdatesNow() { coordinator.checkForUpdatesNow() }
    func quit() { NSApp.terminate(nil) }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    let settingsStore: SettingsStore
    private let coordinator: ReminderCoordinator
    private var cancellables = Set<AnyCancellable>()

    init(coordinator: ReminderCoordinator) {
        self.coordinator = coordinator
        settingsStore = coordinator.settingsStore

        coordinator.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var statusLine: String { coordinator.statusLine }

    func playPreviewSound() {
        coordinator.playPreviewSound()
    }

    func checkForUpdatesNow() {
        coordinator.checkForUpdatesNow()
    }

    func closeWindow() {
        NSApp.keyWindow?.performClose(nil)
    }
}

struct MenuBarQuickControlView: View {
    @ObservedObject var viewModel: QuickControlViewModel
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            animatedRow(delay: 0.00) {
                Text(viewModel.statusLine)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            animatedRow(delay: 0.04) {
                HStack(spacing: 8) {
                    Button(viewModel.primaryActionTitle) {
                        viewModel.startOrResume()
                    }
                    Button("暂停") {
                        viewModel.pause()
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            animatedRow(delay: 0.08) {
                HStack(spacing: 8) {
                    Button("开始休息") {
                        viewModel.beginBreakNow()
                    }
                    Button("稍后提醒") {
                        viewModel.snooze()
                    }
                    Button("跳过本次") {
                        viewModel.skipCurrentBreak()
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            Divider()

            animatedRow(delay: 0.12) {
                Button("打开设置") {
                    viewModel.openSettingsWindow()
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            animatedRow(delay: 0.16) {
                Button("立即检查更新") {
                    viewModel.checkForUpdatesNow()
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            animatedRow(delay: 0.20) {
                Button("退出") {
                    viewModel.quit()
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(12)
        .frame(minWidth: 350)
        .onAppear { appeared = true }
    }

    @ViewBuilder
    private func animatedRow<Content: View>(delay: Double, @ViewBuilder content: () -> Content) -> some View {
        content()
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)
            .animation(.easeOut(duration: 0.24).delay(delay), value: appeared)
    }
}

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

@MainActor
final class DesignAssetLoader {
    static let shared = DesignAssetLoader()

    private var isPrepared = false
    private var titleFontName: String?
    private var bodyFontName: String?

    private init() {}

    func prepare() {
        guard !isPrepared else {
            return
        }
        isPrepared = true

        titleFontName = registerFont(name: "font_title")
        bodyFontName = registerFont(name: "font_body")
    }

    func image(named name: String) -> NSImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "DesignAssets") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }

    func titleFont(size: CGFloat) -> Font {
        guard let titleFontName else {
            return .system(size: size, weight: .bold)
        }
        return .custom(titleFontName, size: size)
    }

    func bodyFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        guard let bodyFontName else {
            return .system(size: size, weight: weight)
        }
        return .custom(bodyFontName, size: size)
    }

    private func registerFont(name: String) -> String? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "DesignAssets") else {
            return nil
        }

        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)

        guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor],
              let descriptor = descriptors.first,
              let postScriptName = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String else {
            return nil
        }

        return postScriptName
    }
}
