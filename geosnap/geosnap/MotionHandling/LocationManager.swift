// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import CoreLocation
import SwiftData
import UIKit

class LocationManager: NSObject, LocationTracking, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private let distanceThreshold: Double = 100.0  // 100 meters
    private let photoService: FlickrPhotoService

    private var lastLocation: CLLocation?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    var imageURL: ((String) -> Void)?

    private var activated = false

    init(photoService: FlickrPhotoService) {
        self.photoService = photoService
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = distanceThreshold
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if activated {
                startTracking()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            if distance >= distanceThreshold {
                beginBackgroundTask()
                fetchPhotosForLocation(newLocation)
                self.lastLocation = newLocation
            }
        } else {
            lastLocation = newLocation
            fetchPhotosForLocation(newLocation)
        }
    }

    private func fetchPhotosForLocation(_ location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        Task {
            do {
                let photo = try await photoService.fetchPhoto(latitude: latitude, longitude: longitude)

                guard let url = photo.url else {
                    print("Failed to create url")
                    return
                }

                imageURL?(url.absoluteString)
                endBackgroundTask()
            } catch {
                print("Failed to fetch photos: \(error)")
                endBackgroundTask()
            }

        }
    }

    // Begin a background task
    private func beginBackgroundTask() {
        if backgroundTask == .invalid {
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "FetchPhotos") {
                // Cleanup if the task times out
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

    //MARK: - Location Tracking
    func startTracking() {
        activated = true
        beginBackgroundTask()

        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.startUpdatingLocation()
        }
    }

    func stopTracking() {
        activated = false

        locationManager.stopUpdatingLocation()
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.allowsBackgroundLocationUpdates = false

        endBackgroundTask()
    }
}
