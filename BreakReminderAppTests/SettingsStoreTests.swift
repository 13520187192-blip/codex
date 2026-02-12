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
        defaults.set(3.0, forKey: "break_reminder.sound_volume")
        defaults.set("invalid_sound", forKey: "break_reminder.sound_option")

        let store = SettingsStore(userDefaults: defaults)
        XCTAssertEqual(store.workDurationMinutes, 60)
        XCTAssertEqual(store.breakDurationMinutes, 1)
        XCTAssertEqual(store.snoozeMinutes, 1)
        XCTAssertEqual(store.soundVolume, 1.0)
        XCTAssertEqual(store.soundOptionRawValue, ReminderSoundOption.glass.rawValue)

        store.workDurationMinutes = 20
        store.breakDurationMinutes = 8
        store.snoozeMinutes = 7
        store.soundOptionRawValue = ReminderSoundOption.submarine.rawValue
        store.soundVolume = 0.55
        store.forceBreakPopup = true

        XCTAssertEqual(defaults.object(forKey: "break_reminder.work_duration_minutes") as? Int, 20)
        XCTAssertEqual(defaults.object(forKey: "break_reminder.break_duration_minutes") as? Int, 8)
        XCTAssertEqual(defaults.object(forKey: "break_reminder.snooze_minutes") as? Int, 7)
        XCTAssertEqual(defaults.object(forKey: "break_reminder.sound_option") as? String, ReminderSoundOption.submarine.rawValue)
        XCTAssertEqual(defaults.object(forKey: "break_reminder.sound_volume") as? Double, 0.55)
        XCTAssertEqual(defaults.object(forKey: "break_reminder.force_break_popup") as? Bool, true)

        defaults.removePersistentDomain(forName: suiteName)
    }
}
