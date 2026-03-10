import Foundation
import HealthKit

actor WorkoutSessionController {
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var started: Bool = false

    func start(healthStore: HKHealthStore,
               configuration: HKWorkoutConfiguration,
               sessionDelegate: HKWorkoutSessionDelegate,
               builderDelegate: HKLiveWorkoutBuilderDelegate) throws {
        // Create session and builder
        let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        let builder = session.associatedWorkoutBuilder()
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        // Assign delegates to the provided owner (e.g., WatchHeartRateManager)
        session.delegate = sessionDelegate
        builder.delegate = builderDelegate
        // Save references
        self.session = session
        self.builder = builder
        // Start
        let startDate = Date()
        session.startActivity(with: startDate)
        builder.beginCollection(withStart: startDate) { _, _ in }
        started = true
    }

    func addStats(distanceDelta: Double?, stepsDelta: Int?) {
        guard started, let builder else { return }
        var samples: [HKSample] = []
        let now = Date()
        if let dm = distanceDelta, dm > 0,
           let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            let quantity = HKQuantity(unit: .meter(), doubleValue: dm)
            let sample = HKQuantitySample(type: distanceType, quantity: quantity, start: now.addingTimeInterval(-1), end: now)
            samples.append(sample)
        }
        if let steps = stepsDelta, steps > 0,
           let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            let quantity = HKQuantity(unit: .count(), doubleValue: Double(steps))
            let sample = HKQuantitySample(type: stepsType, quantity: quantity, start: now.addingTimeInterval(-1), end: now)
            samples.append(sample)
        }
        guard !samples.isEmpty else { return }
        builder.add(samples) { _, _ in }
    }

    func addEvent(_ value: String) {
        guard started, let builder else { return }
        let type: HKWorkoutEventType?
        switch value.lowercased() {
        case "pause": type = .pause
        case "resume": type = .resume
        default: type = nil
        }
        guard let type else { return }
        let now = Date()
        let interval = DateInterval(start: now, duration: 0)
        let event = HKWorkoutEvent(type: type, dateInterval: interval, metadata: nil)
        builder.addWorkoutEvents([event]) { _, _ in }
    }

    func endAndFinish() {
        guard started else { return }
        started = false
        let end = Date()
        let session = self.session
        let builder = self.builder
        // Clear references early to avoid reentrancy issues
        self.session = nil
        self.builder = nil
        if let builder {
            builder.endCollection(withEnd: end) { _, _ in
                session?.end()
                builder.finishWorkout { _, _ in }
            }
        } else {
            session?.end()
        }
    }

    func currentBuilder() -> HKLiveWorkoutBuilder? { builder }
}

