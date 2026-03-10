import Foundation

enum HRDomainService {
    struct AdaptiveStepSelection {
        let level: Int
        let stepKmh: Double
    }

    struct AdaptiveThresholdPercents {
        let deadband: Double
        let downLevel2Start: Double
        let downLevel3Start: Double
        let downLevel4Start: Double
        let upLevel2Start: Double
        let upLevel3Start: Double
        let upLevel4Start: Double
    }

    static func quantizeSpeedStep(_ value: Double) -> Double {
        max(0.1, (value * 10.0).rounded() / 10.0)
    }

    static func diffPercent(absDiff: Int, targetBpm: Int) -> Double {
        let safeTarget = max(1, targetBpm)
        return (Double(absDiff) / Double(safeTarget)) * 100.0
    }

    static func diffBpm(forPercent percent: Double, targetBpm: Int) -> Int {
        let safeTarget = max(1, targetBpm)
        return max(1, Int(round((Double(safeTarget) * percent) / 100.0)))
    }

    static func deadbandBpm(targetBpm: Int, thresholds: AdaptiveThresholdPercents) -> Int {
        diffBpm(forPercent: thresholds.deadband, targetBpm: targetBpm)
    }

    static func stepFromDiff(
        diffPercent: Double,
        isIncreasingSpeed: Bool,
        thresholds: AdaptiveThresholdPercents
    ) -> AdaptiveStepSelection {
        let level: Int
        if isIncreasingSpeed {
            if diffPercent >= thresholds.upLevel4Start {
                level = 4
            } else if diffPercent >= thresholds.upLevel3Start {
                level = 3
            } else if diffPercent >= thresholds.upLevel2Start {
                level = 2
            } else {
                level = 1
            }
        } else {
            if diffPercent >= thresholds.downLevel4Start {
                level = 4
            } else if diffPercent >= thresholds.downLevel3Start {
                level = 3
            } else if diffPercent >= thresholds.downLevel2Start {
                level = 2
            } else {
                level = 1
            }
        }

        return AdaptiveStepSelection(level: level, stepKmh: stepForLevel(level))
    }

    static func stepForLevel(_ level: Int) -> Double {
        let normalized = max(1, min(4, level))
        return Double(normalized) * 0.1
    }
}
