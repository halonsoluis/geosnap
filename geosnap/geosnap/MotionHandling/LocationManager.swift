// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import CoreLocation
import SwiftData
import UIKit

protocol LocationManagerDelegate {
    func didUpdateLocation(latitude: Double, longitude: Double)
}

@MainActor
class LocationManager: NSObject, LocationTracking, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private let distanceThreshold: Double = 100.0  // 100 meters
    private var lastLocation: CLLocation?
    private var activated = false
    private let locationDelegate: any LocationManagerDelegate

    init(delegate locationDelegate: any LocationManagerDelegate) {
        self.locationDelegate = locationDelegate
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = distanceThreshold
    }


    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            MainActor.assumeIsolated {
                if activated {
                    startTracking()
                }
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        MainActor.assumeIsolated {
            if let lastLocation = lastLocation {
                let distance = newLocation.distance(from: lastLocation)
                if distance >= distanceThreshold {
                    reportLocation(newLocation)
                    self.lastLocation = newLocation
                }
            } else {
                lastLocation = newLocation
                reportLocation(newLocation)
            }
        }
    }

    private func reportLocation(_ location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        locationDelegate
            .didUpdateLocation(latitude: latitude, longitude: longitude)
    }

    //MARK: - Location Tracking
    func startTracking() {
        activated = true

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
    }
}
