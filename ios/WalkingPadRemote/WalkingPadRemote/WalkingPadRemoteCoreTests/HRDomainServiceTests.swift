import XCTest
@testable import WalkingPadCoreLogic

final class HRDomainServiceTests: XCTestCase {
    private let thresholds = HRDomainService.AdaptiveThresholdPercents(
        deadband: 3.0,
        downLevel2Start: 8.0,
        downLevel3Start: 15.0,
        downLevel4Start: 23.0,
        upLevel2Start: 23.0,
        upLevel3Start: 31.0,
        upLevel4Start: 46.0
    )

    func testDiffPercentUsesSafeTarget() {
        XCTAssertEqual(HRDomainService.diffPercent(absDiff: 5, targetBpm: 100), 5.0, accuracy: 0.0001)
        XCTAssertEqual(HRDomainService.diffPercent(absDiff: 1, targetBpm: 0), 100.0, accuracy: 0.0001)
    }

    func testDeadbandConversionRoundsToAtLeastOneBpm() {
        XCTAssertEqual(HRDomainService.deadbandBpm(targetBpm: 140, thresholds: thresholds), 4)
        XCTAssertEqual(HRDomainService.deadbandBpm(targetBpm: 10, thresholds: thresholds), 1)
    }

    func testStepSelectionForSpeedDecreasePath() {
        XCTAssertEqual(HRDomainService.stepFromDiff(diffPercent: 4.0, isIncreasingSpeed: false, thresholds: thresholds).level, 1)
        XCTAssertEqual(HRDomainService.stepFromDiff(diffPercent: 8.0, isIncreasingSpeed: false, thresholds: thresholds).level, 2)
        XCTAssertEqual(HRDomainService.stepFromDiff(diffPercent: 15.0, isIncreasingSpeed: false, thresholds: thresholds).level, 3)
        XCTAssertEqual(HRDomainService.stepFromDiff(diffPercent: 23.0, isIncreasingSpeed: false, thresholds: thresholds).level, 4)
    }

    func testStepSelectionForSpeedIncreasePath() {
        XCTAssertEqual(HRDomainService.stepFromDiff(diffPercent: 7.0, isIncreasingSpeed: true, thresholds: thresholds).level, 1)
        XCTAssertEqual(HRDomainService.stepFromDiff(diffPercent: 23.0, isIncreasingSpeed: true, thresholds: thresholds).level, 2)
        XCTAssertEqual(HRDomainService.stepFromDiff(diffPercent: 31.0, isIncreasingSpeed: true, thresholds: thresholds).level, 3)
        XCTAssertEqual(HRDomainService.stepFromDiff(diffPercent: 46.0, isIncreasingSpeed: true, thresholds: thresholds).level, 4)
    }

    func testStepSizeForLevel() {
        XCTAssertEqual(HRDomainService.stepForLevel(1), 0.1, accuracy: 0.0001)
        XCTAssertEqual(HRDomainService.stepForLevel(4), 0.4, accuracy: 0.0001)
        XCTAssertEqual(HRDomainService.stepForLevel(7), 0.4, accuracy: 0.0001)
    }
}
