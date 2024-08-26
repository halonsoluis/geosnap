import SwiftUI
import SwiftData


@main
struct GeosnapApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var locationManager: LocationManager

    init() {
        let photoService = FlickrPhotoService(apiKey: "0006d738e8153f957da524a119c8bca0")
        locationManager = LocationManager(photoService: photoService)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(locationManager: locationManager)
                .onAppear {
                    locationManager.imageURL = addNewItem
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
