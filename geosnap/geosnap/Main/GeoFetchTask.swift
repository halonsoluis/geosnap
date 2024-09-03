// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import UIKit

class GeoFetchTask: LocationManagerDelegate {

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    let photoService: PhotoService

    init(photoService: PhotoService) {
        self.photoService = photoService
    }

    // Begin a background task
    private func beginBackgroundTask() {
        if backgroundTask == .invalid {
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "FetchPhotos") {
                self.endBackgroundTask()
            }
        }
    }

    // End the background task
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func didUpdateLocation(latitude: Double, longitude: Double) {
        Task {
            do {
                beginBackgroundTask()
                try await photoService.fetchPhoto(latitude: latitude, longitude: longitude)
                endBackgroundTask()
            } catch {
                print("Failed to fetch photos: \(error)")
                endBackgroundTask()
            }

        }
    }
}
