// Created for geosnap in 2024
// Using Swift 5.0

import SwiftUI
@preconcurrency import ActivityKit

@MainActor
final class WalkingTracker: ObservableObject, LocationTracking, Sendable {
    @Published var distanceWalked: Double = 0.0
    @Published var elapsedTime: TimeInterval = 0.0
    private var activity: Activity<WalkingActivityAttributes>? = nil
    private var timerTask: Task<Void, any Error>? = nil

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
        timerTask = Task(priority: .userInitiated) { [weak self] in
            while !Task.isCancelled {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                self?.updateTimer()
            }
        }
    }

    private func updateTimer() {
        elapsedTime += 1.0
        updateWalkingActivity()
        // self.distanceWalked = ?? // TODO: Gather information
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
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
