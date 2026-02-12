import Foundation

public final class ReminderEngine: ReminderEngineProtocol {
    public var onStateChange: ((ReminderState) -> Void)?

    public var currentState: ReminderState {
        queue.sync { state }
    }

    private let queue = DispatchQueue(label: "break.reminder.engine", qos: .userInitiated)
    private let nowProvider: () -> Date
    private let tickInterval: TimeInterval

    private var stateMachine: ReminderStateMachine
    private var timer: DispatchSourceTimer?
    private var state: ReminderState

    public init(
        config: ReminderConfig = ReminderConfig(),
        nowProvider: @escaping () -> Date = Date.init,
        tickInterval: TimeInterval = 1
    ) {
        let machine = ReminderStateMachine(config: config)
        self.stateMachine = machine
        self.state = machine.state
        self.nowProvider = nowProvider
        self.tickInterval = tickInterval
    }

    deinit {
        timer?.cancel()
    }

    public func start() {
        queue.async {
            self.ensureTimerLocked()
            self.stateMachine.start(now: self.nowProvider())
            self.syncAndNotifyLocked()
        }
    }

    public func pause() {
        queue.async {
            self.stateMachine.pause(now: self.nowProvider())
            self.syncAndNotifyLocked()
        }
    }

    public func resume() {
        queue.async {
            self.stateMachine.resume(now: self.nowProvider())
            self.syncAndNotifyLocked()
        }
    }

    public func skipCurrentBreak() {
        queue.async {
            self.stateMachine.skipCurrentBreak(now: self.nowProvider())
            self.syncAndNotifyLocked()
        }
    }

    public func snooze(minutes: Int) {
        queue.async {
            self.stateMachine.snooze(now: self.nowProvider(), minutes: minutes)
            self.syncAndNotifyLocked()
        }
    }

    public func apply(config: ReminderConfig) {
        queue.async {
            self.stateMachine.apply(config: config)
        }
    }

    public func beginBreakNow() {
        queue.async {
            self.stateMachine.beginBreak(now: self.nowProvider())
            self.syncAndNotifyLocked()
        }
    }

    public func forceTickForTesting() {
        queue.async {
            self.stateMachine.tick(now: self.nowProvider())
            self.syncAndNotifyLocked()
        }
    }

    private func ensureTimerLocked() {
        guard timer == nil else {
            return
        }

        let source = DispatchSource.makeTimerSource(queue: queue)
        source.schedule(deadline: .now().advanced(by: tickInterval), repeating: tickInterval)
        source.setEventHandler { [weak self] in
            guard let self else { return }
            self.stateMachine.tick(now: self.nowProvider())
            self.syncAndNotifyLocked()
        }
        source.resume()
        timer = source
    }

    private func syncAndNotifyLocked() {
        let nextState = stateMachine.state
        guard nextState != state else {
            return
        }
        state = nextState
        DispatchQueue.main.async { [weak self] in
            self?.onStateChange?(nextState)
        }
    }
}
