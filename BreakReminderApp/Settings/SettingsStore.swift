import Combine
import Foundation

public final class SettingsStore: ObservableObject {
    public var onConfigChanged: ((ReminderConfig) -> Void)?

    @Published public var workDurationMinutes: Int {
        didSet {
            let clamped = ReminderConfig.clamp(workDurationMinutes, range: ReminderConfig.workDurationRange)
            if clamped != workDurationMinutes {
                workDurationMinutes = clamped
                return
            }
            persistIfNeeded()
        }
    }

    @Published public var breakDurationMinutes: Int {
        didSet {
            let clamped = ReminderConfig.clamp(breakDurationMinutes, range: ReminderConfig.breakDurationRange)
            if clamped != breakDurationMinutes {
                breakDurationMinutes = clamped
                return
            }
            persistIfNeeded()
        }
    }

    @Published public var enableSystemNotification: Bool {
        didSet { persistIfNeeded() }
    }

    @Published public var enableOverlayPopup: Bool {
        didSet { persistIfNeeded() }
    }

    @Published public var soundEnabled: Bool {
        didSet { persistIfNeeded() }
    }

    @Published public var snoozeMinutes: Int {
        didSet {
            let clamped = ReminderConfig.clamp(snoozeMinutes, range: ReminderConfig.snoozeRange)
            if clamped != snoozeMinutes {
                snoozeMinutes = clamped
                return
            }
            persistIfNeeded()
        }
    }

    public var config: ReminderConfig {
        ReminderConfig(
            workDurationMinutes: workDurationMinutes,
            breakDurationMinutes: breakDurationMinutes,
            enableSystemNotification: enableSystemNotification,
            enableOverlayPopup: enableOverlayPopup,
            soundEnabled: soundEnabled,
            snoozeMinutes: snoozeMinutes
        ).sanitized()
    }

    private let defaults: UserDefaults
    private var isApplying = false

    private enum Keys {
        static let workDurationMinutes = "break_reminder.work_duration_minutes"
        static let breakDurationMinutes = "break_reminder.break_duration_minutes"
        static let enableSystemNotification = "break_reminder.enable_system_notification"
        static let enableOverlayPopup = "break_reminder.enable_overlay_popup"
        static let soundEnabled = "break_reminder.sound_enabled"
        static let snoozeMinutes = "break_reminder.snooze_minutes"
    }

    public init(userDefaults: UserDefaults = .standard) {
        defaults = userDefaults

        let initialConfig = ReminderConfig(
            workDurationMinutes: userDefaults.object(forKey: Keys.workDurationMinutes) as? Int ?? 30,
            breakDurationMinutes: userDefaults.object(forKey: Keys.breakDurationMinutes) as? Int ?? 5,
            enableSystemNotification: userDefaults.object(forKey: Keys.enableSystemNotification) as? Bool ?? true,
            enableOverlayPopup: userDefaults.object(forKey: Keys.enableOverlayPopup) as? Bool ?? true,
            soundEnabled: userDefaults.object(forKey: Keys.soundEnabled) as? Bool ?? true,
            snoozeMinutes: userDefaults.object(forKey: Keys.snoozeMinutes) as? Int ?? 5
        ).sanitized()

        workDurationMinutes = initialConfig.workDurationMinutes
        breakDurationMinutes = initialConfig.breakDurationMinutes
        enableSystemNotification = initialConfig.enableSystemNotification
        enableOverlayPopup = initialConfig.enableOverlayPopup
        soundEnabled = initialConfig.soundEnabled
        snoozeMinutes = initialConfig.snoozeMinutes

        persistIfNeeded(force: true)
    }

    public func apply(_ config: ReminderConfig) {
        isApplying = true
        let safeConfig = config.sanitized()

        workDurationMinutes = safeConfig.workDurationMinutes
        breakDurationMinutes = safeConfig.breakDurationMinutes
        enableSystemNotification = safeConfig.enableSystemNotification
        enableOverlayPopup = safeConfig.enableOverlayPopup
        soundEnabled = safeConfig.soundEnabled
        snoozeMinutes = safeConfig.snoozeMinutes

        isApplying = false
        persistIfNeeded(force: true)
    }

    private func persistIfNeeded(force: Bool = false) {
        guard force || !isApplying else {
            return
        }

        let safeConfig = config

        defaults.set(safeConfig.workDurationMinutes, forKey: Keys.workDurationMinutes)
        defaults.set(safeConfig.breakDurationMinutes, forKey: Keys.breakDurationMinutes)
        defaults.set(safeConfig.enableSystemNotification, forKey: Keys.enableSystemNotification)
        defaults.set(safeConfig.enableOverlayPopup, forKey: Keys.enableOverlayPopup)
        defaults.set(safeConfig.soundEnabled, forKey: Keys.soundEnabled)
        defaults.set(safeConfig.snoozeMinutes, forKey: Keys.snoozeMinutes)

        onConfigChanged?(safeConfig)
    }
}
