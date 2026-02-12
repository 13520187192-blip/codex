import XCTest
@testable import BreakReminderCore

final class SettingsStoreTests: XCTestCase {
    func testStoreClampsAndPersistsValues() {
        let suiteName = "settings-store-tests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create isolated UserDefaults")
            return
        }
        defaults.removePersistentDomain(forName: suiteName)

        defaults.set(999, forKey: "break_reminder.work_duration_minutes")
        defaults.set(1, forKey: "break_reminder.break_duration_minutes")
        defaults.set(0, forKey: "break_reminder.snooze_minutes")

        let store = SettingsStore(userDefaults: defaults)
        XCTAssertEqual(store.workDurationMinutes, ReminderConfig.workDurationRange.upperBound)
        XCTAssertEqual(store.breakDurationMinutes, ReminderConfig.breakDurationRange.lowerBound)
        XCTAssertEqual(store.snoozeMinutes, ReminderConfig.snoozeRange.lowerBound)

        store.workDurationMinutes = 20
        store.breakDurationMinutes = 8
        store.snoozeMinutes = 7

        XCTAssertEqual(defaults.object(forKey: "break_reminder.work_duration_minutes") as? Int, 20)
        XCTAssertEqual(defaults.object(forKey: "break_reminder.break_duration_minutes") as? Int, 8)
        XCTAssertEqual(defaults.object(forKey: "break_reminder.snooze_minutes") as? Int, 7)

        defaults.removePersistentDomain(forName: suiteName)
    }
}
