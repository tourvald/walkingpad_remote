import SwiftUI

@main
struct WalkingPadRemoteApp: App {
    @StateObject private var manager = BluetoothManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
    }
}
