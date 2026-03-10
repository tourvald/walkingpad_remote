import Foundation
import XCTest
@testable import WalkingPadCoreLogic

final class CommandQueueServiceTests: XCTestCase {
    private func isSpeed(_ label: String) -> Bool {
        label.lowercased().hasPrefix("speed")
    }

    func testEnqueueRegularCoalescesOlderSpeedCommands() {
        var queue: [CommandQueueService.Command] = [
            .init(data: Data([0x01]), label: "SPEED 3.0"),
            .init(data: Data([0x02]), label: "PING"),
            .init(data: Data([0x03]), label: "SPEED 3.2")
        ]

        let result = CommandQueueService.enqueueRegular(
            queue: &queue,
            command: .init(data: Data([0x04]), label: "SPEED 4.0"),
            isSpeedLabel: isSpeed
        )

        XCTAssertEqual(result.coalescedSpeedCount, 2)
        XCTAssertEqual(queue.map(\.label), ["PING", "SPEED 4.0"])
    }

    func testEnqueueRegularKeepsNonSpeedCommands() {
        var queue: [CommandQueueService.Command] = [
            .init(data: Data([0x01]), label: "PING")
        ]

        let result = CommandQueueService.enqueueRegular(
            queue: &queue,
            command: .init(data: Data([0x02]), label: "STATUS"),
            isSpeedLabel: isSpeed
        )

        XCTAssertEqual(result.coalescedSpeedCount, 0)
        XCTAssertEqual(queue.map(\.label), ["PING", "STATUS"])
    }

    func testReplaceWithHighPriorityDropsPendingCommands() {
        var queue: [CommandQueueService.Command] = [
            .init(data: Data([0x01]), label: "SPEED 3.0"),
            .init(data: Data([0x02]), label: "PING")
        ]

        CommandQueueService.replaceWithHighPriority(
            queue: &queue,
            command: .init(data: Data([0xFF]), label: "STOP")
        )

        XCTAssertEqual(queue.count, 1)
        XCTAssertEqual(queue.first?.label, "STOP")
    }

    func testClearReturnsDroppedCount() {
        var queue: [CommandQueueService.Command] = [
            .init(data: Data([0x01]), label: "A"),
            .init(data: Data([0x02]), label: "B"),
            .init(data: Data([0x03]), label: "C")
        ]

        let dropped = CommandQueueService.clear(queue: &queue)
        XCTAssertEqual(dropped, 3)
        XCTAssertTrue(queue.isEmpty)
    }
}
