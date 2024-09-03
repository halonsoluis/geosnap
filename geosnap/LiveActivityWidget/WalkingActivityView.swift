// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import SwiftUI
import ActivityKit
import WidgetKit
import SwiftUI

struct WalkingLiveActivityView: View {
    let context: Activity<WalkingActivityAttributes>.ContentState

    var body: some View {
        HStack {
            Image(systemName: "figure.walk")

            Spacer()

            VStack(alignment: .leading) {
                Text("GeoSnap is gathering memories")
                    .font(.headline)

                Text("Time: \(formatTimeInterval(context.elapsedTime))")
            }
        }

        .padding()
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .short
        return formatter.string(from: interval) ?? ""
    }
}

struct WalkingActivityAttributes_Previews: PreviewProvider {
    static var previews: some View {
        let state = Activity<WalkingActivityAttributes>.ContentState(distanceWalked: 10, elapsedTime: Date().timeIntervalSince1970)

        return WalkingLiveActivityView(
            context: state
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(for: .widget, alignment: .center) {}
        .previewDisplayName("Live Activity Widget")
    }
}

#Preview {
    let state = Activity<WalkingActivityAttributes>.ContentState(distanceWalked: 10, elapsedTime: Date().timeIntervalSince1970)
    return WalkingLiveActivityView(
        context: state
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))
}
