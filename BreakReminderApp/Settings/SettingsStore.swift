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

    @Published public var forceBreakPopup: Bool {
        didSet { persistIfNeeded() }
    }

    @Published public var soundEnabled: Bool {
        didSet { persistIfNeeded() }
    }

    @Published public var soundOptionRawValue: String {
        didSet {
            if ReminderSoundOption(rawValue: soundOptionRawValue) == nil {
                soundOptionRawValue = ReminderSoundOption.glass.rawValue
                return
            }
            persistIfNeeded()
        }
    }

    @Published public var soundVolume: Double {
        didSet {
            let clamped = ReminderConfig.clamp(soundVolume, range: ReminderConfig.soundVolumeRange)
            if clamped != soundVolume {
                soundVolume = clamped
                return
            }
            persistIfNeeded()
        }
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
            forceBreakPopup: forceBreakPopup,
            soundEnabled: soundEnabled,
            soundOption: ReminderSoundOption(rawValue: soundOptionRawValue) ?? .glass,
            soundVolume: soundVolume,
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
        static let forceBreakPopup = "break_reminder.force_break_popup"
        static let soundEnabled = "break_reminder.sound_enabled"
        static let soundOptionRawValue = "break_reminder.sound_option"
        static let soundVolume = "break_reminder.sound_volume"
        static let snoozeMinutes = "break_reminder.snooze_minutes"
    }

    public init(userDefaults: UserDefaults = .standard) {
        defaults = userDefaults

        let initialConfig = ReminderConfig(
            workDurationMinutes: userDefaults.object(forKey: Keys.workDurationMinutes) as? Int ?? 30,
            breakDurationMinutes: userDefaults.object(forKey: Keys.breakDurationMinutes) as? Int ?? 5,
            enableSystemNotification: userDefaults.object(forKey: Keys.enableSystemNotification) as? Bool ?? true,
            enableOverlayPopup: userDefaults.object(forKey: Keys.enableOverlayPopup) as? Bool ?? true,
            forceBreakPopup: userDefaults.object(forKey: Keys.forceBreakPopup) as? Bool ?? false,
            soundEnabled: userDefaults.object(forKey: Keys.soundEnabled) as? Bool ?? true,
            soundOption: ReminderSoundOption(rawValue: userDefaults.object(forKey: Keys.soundOptionRawValue) as? String ?? "") ?? .glass,
            soundVolume: userDefaults.object(forKey: Keys.soundVolume) as? Double ?? 0.8,
            snoozeMinutes: userDefaults.object(forKey: Keys.snoozeMinutes) as? Int ?? 5
        ).sanitized()

        workDurationMinutes = initialConfig.workDurationMinutes
        breakDurationMinutes = initialConfig.breakDurationMinutes
        enableSystemNotification = initialConfig.enableSystemNotification
        enableOverlayPopup = initialConfig.enableOverlayPopup
        forceBreakPopup = initialConfig.forceBreakPopup
        soundEnabled = initialConfig.soundEnabled
        soundOptionRawValue = initialConfig.soundOption.rawValue
        soundVolume = initialConfig.soundVolume
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
        forceBreakPopup = safeConfig.forceBreakPopup
        soundEnabled = safeConfig.soundEnabled
        soundOptionRawValue = safeConfig.soundOption.rawValue
        soundVolume = safeConfig.soundVolume
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
        defaults.set(safeConfig.forceBreakPopup, forKey: Keys.forceBreakPopup)
        defaults.set(safeConfig.soundEnabled, forKey: Keys.soundEnabled)
        defaults.set(safeConfig.soundOption.rawValue, forKey: Keys.soundOptionRawValue)
        defaults.set(safeConfig.soundVolume, forKey: Keys.soundVolume)
        defaults.set(safeConfig.snoozeMinutes, forKey: Keys.snoozeMinutes)

        onConfigChanged?(safeConfig)
    }
}
