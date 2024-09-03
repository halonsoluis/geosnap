// Created for geosnap in 2024
// Using Swift 5.0

import SwiftUI
@preconcurrency import ActivityKit

final class WalkingTracker: ObservableObject, LocationTracking, Sendable {
    @Published var distanceWalked: Double = 0.0
    @Published var elapsedTime: TimeInterval = 0.0
    private var activity: Activity<WalkingActivityAttributes>? = nil
    private var timer: Timer? = nil

    @MainActor func startTracking() {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            startWalkingActivity()
            startTimer()
        }
    }

    func stopTracking() {
        stopTimer()
        stopWalkingActivity()
    }

    @MainActor // Ensure that this function and related properties are used on the main thread
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.elapsedTime += 1.0
            self.updateWalkingActivity()
            // self.distanceWalked = ?? // TODO: Gather information
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startWalkingActivity() {
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

    private func updateWalkingActivity() {
        guard let activity = activity else { return }
        let updatedContentState = ActivityContent(state: WalkingActivityAttributes.ContentState(distanceWalked: distanceWalked, elapsedTime: elapsedTime), staleDate: nil)

        Task {
            await activity.update(updatedContentState)
        }
    }

    private func stopWalkingActivity() {
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
        }
    }
}
