import SwiftUI
import WatchKit

final class WatchExtensionDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        // Ensure WCSession/HealthKit are ready to receive commands in background
        WatchHeartRateManager.shared.activate()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            task.setTaskCompletedWithSnapshot(false)
        }
    }
}

@main
struct WalkingPadRemoteWatchApp: App {
    @WKApplicationDelegateAdaptor(WatchExtensionDelegate.self) var appDelegate
    @StateObject private var hr = WatchHeartRateManager.shared

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(hr)
                .onAppear { hr.activate() }
        }
    }
}
