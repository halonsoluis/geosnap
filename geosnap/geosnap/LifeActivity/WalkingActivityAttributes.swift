// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import ActivityKit

struct WalkingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var distanceWalked: Double //TODO: Gather and publish it
        var elapsedTime: TimeInterval
    }
}
