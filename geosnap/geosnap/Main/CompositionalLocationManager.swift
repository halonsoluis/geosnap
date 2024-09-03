// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

struct CompositionalLocationManager: LocationTracking {

    let locationService: [any LocationTracking]

    func startTracking() {
        locationService.forEach { $0.startTracking() }
    }

    func stopTracking() {
        locationService.forEach { $0.stopTracking() }
    }
}
