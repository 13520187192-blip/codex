import XCTest
@testable import BreakReminderCore

final class UpdateVersionComparatorTests: XCTestCase {
    func testSemanticComparison() {
        XCTAssertTrue(UpdateVersionComparator.isRemoteVersionNewer(remote: "1.2.0", current: "1.1.9"))
        XCTAssertTrue(UpdateVersionComparator.isRemoteVersionNewer(remote: "v2.0.0", current: "1.9.9"))
        XCTAssertFalse(UpdateVersionComparator.isRemoteVersionNewer(remote: "1.0.0", current: "1.0.0"))
        XCTAssertFalse(UpdateVersionComparator.isRemoteVersionNewer(remote: "1.0.0", current: "1.0.1"))
    }
}
