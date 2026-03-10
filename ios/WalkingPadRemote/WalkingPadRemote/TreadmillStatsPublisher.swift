import Foundation

actor TreadmillStatsPublisher {
    // Input state
    private var lastDistMeters: Double = 0
    private var lastSteps: Int = 0
    private var lastEmitAt: Date = .distantPast

    // Config
    private let minMetersDelta: Double = 1.0
    private let throttle: TimeInterval = 1.5

    // Output closure (injected)
    private var sink: ((Double, Int) -> Void)?

    func setSink(_ sink: @escaping (Double, Int) -> Void) {
        self.sink = sink
    }

    func reset(currentDistMeters: Double, currentSteps: Int) {
        lastDistMeters = max(0, currentDistMeters)
        lastSteps = max(0, currentSteps)
        lastEmitAt = .distantPast
    }

    func ingest(currentDistMeters: Double, currentSteps: Int) {
        let now = Date()
        let distDelta = max(0, currentDistMeters - lastDistMeters)
        let stepsDelta = max(0, currentSteps - lastSteps)
        let elapsed = now.timeIntervalSince(lastEmitAt)

        guard distDelta >= minMetersDelta || stepsDelta > 0 else { return }
        guard elapsed >= throttle else { return }

        lastDistMeters = currentDistMeters
        lastSteps = currentSteps
        lastEmitAt = now

        sink?(distDelta, stepsDelta)
    }
}
