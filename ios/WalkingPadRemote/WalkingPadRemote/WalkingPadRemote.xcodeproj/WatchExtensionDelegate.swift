import WatchKit
import SwiftUI

final class WatchExtensionDelegate: NSObject, WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        // Ensure WCSession is active and ready to receive commands in background
        WatchHeartRateManager.shared.activate()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Complete all background tasks and keep the session warm
        for task in backgroundTasks {
            task.setTaskCompletedWithSnapshot(false)
        }
    }
}
