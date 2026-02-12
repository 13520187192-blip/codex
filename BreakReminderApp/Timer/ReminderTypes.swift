import Foundation

public enum ReminderSoundOption: String, CaseIterable, Equatable {
    case glass
    case ping
    case pop
    case submarine

    public var displayName: String {
        switch self {
        case .glass:
            return "Glass"
        case .ping:
            return "Ping"
        case .pop:
            return "Pop"
        case .submarine:
            return "Submarine"
        }
    }
}

public struct ReminderConfig: Equatable {
    public static let workDurationRange = 1...60
    public static let breakDurationRange = 1...60
    public static let snoozeRange = 1...60
    public static let soundVolumeRange: ClosedRange<Double> = 0...1

    public var workDurationMinutes: Int
    public var breakDurationMinutes: Int
    public var enableSystemNotification: Bool
    public var enableOverlayPopup: Bool
    public var forceBreakPopup: Bool
    public var soundEnabled: Bool
    public var soundOption: ReminderSoundOption
    public var soundVolume: Double
    public var snoozeMinutes: Int

    public init(
        workDurationMinutes: Int = 30,
        breakDurationMinutes: Int = 5,
        enableSystemNotification: Bool = true,
        enableOverlayPopup: Bool = true,
        forceBreakPopup: Bool = false,
        soundEnabled: Bool = true,
        soundOption: ReminderSoundOption = .glass,
        soundVolume: Double = 0.8,
        snoozeMinutes: Int = 5
    ) {
        self.workDurationMinutes = workDurationMinutes
        self.breakDurationMinutes = breakDurationMinutes
        self.enableSystemNotification = enableSystemNotification
        self.enableOverlayPopup = enableOverlayPopup
        self.forceBreakPopup = forceBreakPopup
        self.soundEnabled = soundEnabled
        self.soundOption = soundOption
        self.soundVolume = soundVolume
        self.snoozeMinutes = snoozeMinutes
    }

    public var workDuration: TimeInterval {
        TimeInterval(workDurationMinutes * 60)
    }

    public var breakDuration: TimeInterval {
        TimeInterval(breakDurationMinutes * 60)
    }

    public func sanitized() -> ReminderConfig {
        ReminderConfig(
            workDurationMinutes: Self.clamp(workDurationMinutes, range: Self.workDurationRange),
            breakDurationMinutes: Self.clamp(breakDurationMinutes, range: Self.breakDurationRange),
            enableSystemNotification: enableSystemNotification,
            enableOverlayPopup: enableOverlayPopup,
            forceBreakPopup: forceBreakPopup,
            soundEnabled: soundEnabled,
            soundOption: soundOption,
            soundVolume: Self.clamp(soundVolume, range: Self.soundVolumeRange),
            snoozeMinutes: Self.clamp(snoozeMinutes, range: Self.snoozeRange)
        )
    }

    public static func clamp(_ value: Int, range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }

    public static func clamp(_ value: Double, range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }
}

public enum ReminderState: Equatable {
    case idle
    case focusing(endAt: Date)
    case breakDue
    case onBreak(endAt: Date)
    case snoozed(until: Date)
    case paused
}

public protocol ReminderEngineProtocol: AnyObject {
    var currentState: ReminderState { get }
    var onStateChange: ((ReminderState) -> Void)? { get set }

    func start()
    func pause()
    func resume()
    func skipCurrentBreak()
    func snooze(minutes: Int)
    func apply(config: ReminderConfig)
}

public protocol NotificationServicing {
    func requestAuthorization() async -> Bool
    func showBreakDueNotification()
    func showBreakStartedNotification(durationMinutes: Int)
}

public protocol Updating {
    func checkForUpdatesInBackground()
    func checkForUpdatesManually()
}
