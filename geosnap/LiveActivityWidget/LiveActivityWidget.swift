// Created for geosnap in 2024
// Using Swift 5.0

import WidgetKit
import SwiftUI

struct LiveActivityWidget: Widget {
    let kind: String = "LiveActivityWidget"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WalkingActivityAttributes.self) { context in
            WalkingLiveActivityView(context: context.state)
                .activityBackgroundTint(Color.black.opacity(0.25))
        } dynamicIsland: { context in
            DynamicIsland {
                expandedContent(contentState: context.state, isStale: false)
            } compactLeading: {
                Text("GeoSnap")
            } compactTrailing: {
                Image(systemName: "figure.walk")
            } minimal: {
                Text("Every 100 meters")
            }

        }
    }
}

@DynamicIslandExpandedContentBuilder
private func expandedContent(contentState: WalkingActivityAttributes.ContentState,
                             isStale: Bool) -> DynamicIslandExpandedContent<some View> {
    DynamicIslandExpandedRegion(.leading) {
        Text("Capturing Photos")
    }

    DynamicIslandExpandedRegion(.trailing) {
        Text("Every 100 meters")
    }

    DynamicIslandExpandedRegion(.bottom) {
        Image(systemName: "figure.walk")
    }
}

