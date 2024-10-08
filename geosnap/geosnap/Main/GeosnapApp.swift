import SwiftUI
import SwiftData


@main
struct GeosnapApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([StoredPhoto.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    let locationManager: any LocationTracking
    let photoService: any PhotoService
    let errorHandling: ErrorHandling

    init() {
        let photoService = FlickrPhotoService()
        let errorHandling = ErrorHandlingPhotoService(primaryPhotoService: photoService)

        let photoFetch = errorHandling.fetchPhoto
        let walkingTracker = WalkingTracker()
        let locationManager = LocationManager(
            delegate:
                GeoFetchTask(photoService: photoFetch)
        )

        self.photoService = errorHandling
        self.errorHandling = errorHandling
        self.locationManager = CompositionalLocationManager(
            locationService: [walkingTracker, locationManager]
        )

        // Want to skip the queue and set an API Key so that you don't have to fill it manually on the simulator.
        // Do it here below
        // -----------------
        UserDefaults.standard.setValue("9e3ca9a5af86c43f4e3033b7cc401a35", forKey: "apiKey")
    }

    var body: some Scene {
        WindowGroup {
            MainView(locationManager: locationManager, errorHandling: errorHandling)
                .onAppear {
                    photoService.imageURL = addNewItem
                }
        }
        .modelContainer(sharedModelContainer)
        
    }

    @MainActor
    func addNewItem(url: String) {
        Task {
            do {
                let image = try await ImageStorage.downloadAndCreateImageItem(from: url)
                try ImageStorage.saveImage(newItem: image, context: sharedModelContainer.mainContext)
            } catch {
                print("Failed to download and save image: \(error)")
            }
        }
    }
}
