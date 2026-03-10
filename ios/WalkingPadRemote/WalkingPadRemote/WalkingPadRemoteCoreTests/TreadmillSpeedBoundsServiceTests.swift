import XCTest
@testable import WalkingPadCoreLogic

final class TreadmillSpeedBoundsServiceTests: XCTestCase {
    func testNormalizedUsesFallbacksForInvalidValues() {
        let bounds = TreadmillSpeedBoundsService.normalized(
            min: .nan,
            max: -1,
            increment: 0
        )

        XCTAssertEqual(bounds.min, 0.5, accuracy: 0.0001)
        XCTAssertEqual(bounds.max, 12.0, accuracy: 0.0001)
        XCTAssertEqual(bounds.increment, 0.1, accuracy: 0.0001)
    }

    func testNormalizedAppliesHardCaps() {
        let bounds = TreadmillSpeedBoundsService.normalized(
            min: 1.0,
            max: 40.0,
            increment: 2.0
        )

        XCTAssertEqual(bounds.min, 1.0, accuracy: 0.0001)
        XCTAssertEqual(bounds.max, 25.0, accuracy: 0.0001)
        XCTAssertEqual(bounds.increment, 1.0, accuracy: 0.0001)
    }

    func testClampRunningSpeedHonorsMinMax() {
        let bounds = TreadmillSpeedBoundsService.Bounds(min: 2.0, max: 6.0, increment: 0.1)
        XCTAssertEqual(TreadmillSpeedBoundsService.clampRunningSpeed(1.0, bounds: bounds), 2.0, accuracy: 0.0001)
        XCTAssertEqual(TreadmillSpeedBoundsService.clampRunningSpeed(4.5, bounds: bounds), 4.5, accuracy: 0.0001)
        XCTAssertEqual(TreadmillSpeedBoundsService.clampRunningSpeed(7.0, bounds: bounds), 6.0, accuracy: 0.0001)
    }

    func testClampAnySpeedAllowsZeroButCapsAtMax() {
        let bounds = TreadmillSpeedBoundsService.Bounds(min: 2.0, max: 6.0, increment: 0.1)
        XCTAssertEqual(TreadmillSpeedBoundsService.clampAnySpeed(-0.5, bounds: bounds), 0.0, accuracy: 0.0001)
        XCTAssertEqual(TreadmillSpeedBoundsService.clampAnySpeed(5.5, bounds: bounds), 5.5, accuracy: 0.0001)
        XCTAssertEqual(TreadmillSpeedBoundsService.clampAnySpeed(7.5, bounds: bounds), 6.0, accuracy: 0.0001)
    }

    func testClampSpeedTenths() {
        XCTAssertEqual(TreadmillSpeedBoundsService.clampSpeedTenths(-1.0), 0)
        XCTAssertEqual(TreadmillSpeedBoundsService.clampSpeedTenths(1.26), 13)
        XCTAssertEqual(TreadmillSpeedBoundsService.clampSpeedTenths(40.0), 120)
    }
}
