import Foundation

public final class ReminderStateMachine {
    private enum PausedSnapshot: Equatable {
        case focusing(remaining: TimeInterval)
        case onBreak(remaining: TimeInterval)
        case snoozed(remaining: TimeInterval)
        case breakDue
    }

    public private(set) var state: ReminderState = .idle
    public private(set) var config: ReminderConfig

    private var pausedSnapshot: PausedSnapshot?

    public init(config: ReminderConfig = ReminderConfig()) {
        self.config = config.sanitized()
    }

    public func apply(config: ReminderConfig) {
        self.config = config.sanitized()
    }

    public func start(now: Date) {
        pausedSnapshot = nil
        state = .focusing(endAt: now.addingTimeInterval(config.workDuration))
    }

    public func pause(now: Date) {
        switch state {
        case .focusing(let endAt):
            pausedSnapshot = .focusing(remaining: max(0, endAt.timeIntervalSince(now)))
            state = .paused
        case .onBreak(let endAt):
            pausedSnapshot = .onBreak(remaining: max(0, endAt.timeIntervalSince(now)))
            state = .paused
        case .snoozed(let until):
            pausedSnapshot = .snoozed(remaining: max(0, until.timeIntervalSince(now)))
            state = .paused
        case .breakDue:
            pausedSnapshot = .breakDue
            state = .paused
        case .idle, .paused:
            break
        }
    }

    public func resume(now: Date) {
        guard case .paused = state else {
            return
        }

        guard let snapshot = pausedSnapshot else {
            state = .idle
            return
        }

        switch snapshot {
        case .focusing(let remaining):
            state = .focusing(endAt: now.addingTimeInterval(remaining))
        case .onBreak(let remaining):
            state = .onBreak(endAt: now.addingTimeInterval(remaining))
        case .snoozed(let remaining):
            state = .snoozed(until: now.addingTimeInterval(remaining))
        case .breakDue:
            state = .breakDue
        }
        pausedSnapshot = nil
    }

    public func beginBreak(now: Date) {
        switch state {
        case .breakDue, .snoozed:
            state = .onBreak(endAt: now.addingTimeInterval(config.breakDuration))
        case .idle, .focusing, .onBreak, .paused:
            break
        }
    }

    public func skipCurrentBreak(now: Date) {
        switch state {
        case .breakDue, .onBreak, .snoozed:
            state = .focusing(endAt: now.addingTimeInterval(config.workDuration))
        case .idle, .focusing, .paused:
            break
        }
    }

    public func snooze(now: Date, minutes: Int) {
        guard case .breakDue = state else {
            return
        }
        let duration = TimeInterval(ReminderConfig.clamp(minutes, range: ReminderConfig.snoozeRange) * 60)
        state = .snoozed(until: now.addingTimeInterval(duration))
    }

    public func tick(now: Date) {
        switch state {
        case .focusing(let endAt) where now >= endAt:
            state = .breakDue
        case .onBreak(let endAt) where now >= endAt:
            state = .focusing(endAt: now.addingTimeInterval(config.workDuration))
        case .snoozed(let until) where now >= until:
            state = .breakDue
        case .idle, .focusing, .breakDue, .onBreak, .snoozed, .paused:
            break
        }
    }
}
