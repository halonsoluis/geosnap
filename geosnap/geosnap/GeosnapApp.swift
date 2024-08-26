// Created for geosnap in 2024
// Using Swift 5.0

import SwiftUI
import SwiftData

@main
struct GeosnapApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(
                locationManager: LocationManager(
                    photoService: FlickrPhotoService(apiKey: "6ace69042a6f0c80417a8e2e12f5abcf"),
                    modelContext: sharedModelContainer.mainContext
                )
            )
        }
        .modelContainer(sharedModelContainer)

    }
}
