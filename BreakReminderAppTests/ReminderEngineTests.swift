import XCTest
@testable import BreakReminderCore

final class ReminderEngineTests: XCTestCase {
    func testEngineTransitionsWhenTimeAdvances() {
        var now = Date(timeIntervalSince1970: 10_000)
        let engine = ReminderEngine(
            config: ReminderConfig(workDurationMinutes: 30, breakDurationMinutes: 5),
            nowProvider: { now },
            tickInterval: 60
        )

        engine.start()
        waitUntil {
            if case .focusing = engine.currentState {
                return true
            }
            return false
        }

        now = now.addingTimeInterval(30 * 60)
        engine.forceTickForTesting()
        waitUntil {
            engine.currentState == .breakDue
        }

        engine.beginBreakNow()
        waitUntil {
            if case .onBreak = engine.currentState {
                return true
            }
            return false
        }
    }

    private func waitUntil(timeout: TimeInterval = 2, file: StaticString = #filePath, line: UInt = #line, _ condition: () -> Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() {
                return
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
        }
        XCTFail("Condition not met before timeout", file: file, line: line)
    }
}
