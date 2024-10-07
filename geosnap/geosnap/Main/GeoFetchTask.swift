// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import UIKit

@MainActor
class GeoFetchTask: LocationManagerDelegate {

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    let fetchPhoto: @Sendable (Double, Double) async throws -> Void

    init(photoService: @Sendable @escaping (Double, Double) async throws -> Void) {
        self.fetchPhoto = photoService
    }

    // Begin a background task
     private func beginBackgroundTask() {
        if backgroundTask == .invalid {
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "FetchPhotos") { [weak self] in
                guard let self = self else { return }
                self.endBackgroundTask()
            }
        }
    }

    // End the background task
    @MainActor private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    nonisolated func didUpdateLocation(latitude: Double, longitude: Double) {
        Task {
            do {
                await beginBackgroundTask()
                try await fetchPhoto(latitude, longitude)
                await endBackgroundTask()
            } catch {
                print("Failed to fetch photos: \(error)")
                await endBackgroundTask()
            }

        }
    }
}
