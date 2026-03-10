import Foundation

enum TreadmillSpeedBoundsService {
    struct Bounds: Equatable {
        let min: Double
        let max: Double
        let increment: Double
    }

    static func normalized(min: Double, max: Double, increment: Double) -> Bounds {
        var minV = min
        var maxV = max
        var incV = increment

        if !minV.isFinite || minV <= 0.0 { minV = 0.5 }
        if !maxV.isFinite || maxV < minV { maxV = 12.0 }
        if !incV.isFinite || incV <= 0.0 { incV = 0.1 }

        maxV = Swift.min(maxV, 25.0)
        incV = Swift.min(Swift.max(incV, 0.01), 1.0)

        return Bounds(min: minV, max: maxV, increment: incV)
    }

    static func clampRunningSpeed(_ value: Double, bounds: Bounds) -> Double {
        Swift.max(bounds.min, Swift.min(bounds.max, value))
    }

    static func clampAnySpeed(_ value: Double, bounds: Bounds) -> Double {
        Swift.max(0.0, Swift.min(bounds.max, value))
    }

    static func clampSpeedTenths(_ kmh: Double) -> Int {
        Int(Swift.max(0, Swift.min(120, (kmh * 10).rounded())))
    }
}
