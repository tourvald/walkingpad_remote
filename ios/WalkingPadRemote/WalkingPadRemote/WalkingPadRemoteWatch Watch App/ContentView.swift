import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject private var hr: WatchHeartRateManager

    var body: some View {
        let hasHr = hr.bpm > 0 && hr.isActive
        let hrColor: Color = {
            guard hasHr else { return .secondary }
            let diff = hr.bpm - hr.targetBpm
            if diff > 3 { return .red }
            if diff < -3 { return .orange }
            return .green
        }()

        VStack(spacing: 8) {
            Text("Heart Rate")
                .font(.headline)
            Text("\(hr.bpm) bpm")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(hrColor)
            if hr.isActive {
                Text("Live")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("Tap to start")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Button(hr.isActive ? "Stop" : "Start") {
                if hr.isActive {
                    hr.stop()
                } else {
                    hr.start()
                }
            }
        }
        .padding()
    }
}
