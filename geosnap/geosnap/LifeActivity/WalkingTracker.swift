// Created for geosnap in 2024
// Using Swift 5.0

import SwiftUI
import ActivityKit

class WalkingTracker: ObservableObject, LocationTracking {
    @Published var distanceWalked: Double = 0.0
    @Published var elapsedTime: TimeInterval = 0.0
    private var activity: Activity<WalkingActivityAttributes>? = nil
    private var timer: Timer? = nil

    func startTracking() {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            startWalkingActivity()
            startTimer()
        }
    }

    func stopTracking() {
        stopTimer()
        stopWalkingActivity()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1.0
           // self.distanceWalked = ?? // TODO: Gather information

            self.updateWalkingActivity()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func startWalkingActivity() {
        let initialContentState = WalkingActivityAttributes.ContentState(distanceWalked: 0.0, elapsedTime: 0)
        let attributes = WalkingActivityAttributes()

        do {
            activity = try Activity<WalkingActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialContentState, staleDate: nil),
                pushType: nil // no remote updates
            )
            print("Walking activity started: \(activity!.id)")
            
        } catch {
            print("Failed to start walking activity: \(error.localizedDescription)")
        }
    }

    func updateWalkingActivity() {
        guard let activity = activity else { return }
        let updatedContentState = ActivityContent(state: WalkingActivityAttributes.ContentState(distanceWalked: distanceWalked, elapsedTime: elapsedTime), staleDate: nil)

        Task {
            await activity.update(updatedContentState)
        }
    }

    func stopWalkingActivity() {
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
        }
    }
}
