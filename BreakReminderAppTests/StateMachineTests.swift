import XCTest
@testable import BreakReminderCore

final class StateMachineTests: XCTestCase {
    func testFocusBreakCycleAndSkip() {
        let config = ReminderConfig(workDurationMinutes: 30, breakDurationMinutes: 5)
        let machine = ReminderStateMachine(config: config)
        let startTime = Date(timeIntervalSince1970: 1_000)

        machine.start(now: startTime)
        XCTAssertEqual(machine.state, .focusing(endAt: startTime.addingTimeInterval(30 * 60)))

        machine.tick(now: startTime.addingTimeInterval(30 * 60))
        XCTAssertEqual(machine.state, .breakDue)

        machine.beginBreak(now: startTime.addingTimeInterval(30 * 60))
        XCTAssertEqual(machine.state, .onBreak(endAt: startTime.addingTimeInterval(35 * 60)))

        machine.tick(now: startTime.addingTimeInterval(35 * 60))
        XCTAssertEqual(machine.state, .focusing(endAt: startTime.addingTimeInterval(65 * 60)))

        machine.tick(now: startTime.addingTimeInterval(65 * 60))
        XCTAssertEqual(machine.state, .breakDue)

        machine.skipCurrentBreak(now: startTime.addingTimeInterval(65 * 60))
        XCTAssertEqual(machine.state, .focusing(endAt: startTime.addingTimeInterval(95 * 60)))
    }

    func testSnoozeAndPauseResume() {
        let machine = ReminderStateMachine(config: ReminderConfig())
        let now = Date(timeIntervalSince1970: 2_000)

        machine.start(now: now)
        machine.tick(now: now.addingTimeInterval(30 * 60))
        XCTAssertEqual(machine.state, .breakDue)

        machine.snooze(now: now.addingTimeInterval(30 * 60), minutes: 5)
        XCTAssertEqual(machine.state, .snoozed(until: now.addingTimeInterval(35 * 60)))

        machine.pause(now: now.addingTimeInterval(31 * 60))
        XCTAssertEqual(machine.state, .paused)

        machine.resume(now: now.addingTimeInterval(40 * 60))
        if case .snoozed(let until) = machine.state {
            XCTAssertGreaterThan(until, now.addingTimeInterval(40 * 60))
        } else {
            XCTFail("Expected snoozed state after resume")
        }
    }
}
