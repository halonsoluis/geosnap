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

    var locationManager: LocationTracking
    var photoService: PhotoService
    var errorHandling: ErrorHandling

    init() {
        let photoService = FlickrPhotoService()
        let errorHandling = ErrorHandlingPhotoService(primaryPhotoService: photoService)

        self.photoService = errorHandling
        self.errorHandling = errorHandling

        let walkingTracker = WalkingTracker()
        let locationManager = LocationManager(photoService: errorHandling)

        self.locationManager = CompositionalLocationManager(
            locationService: [walkingTracker, locationManager]
        )
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

class ErrorHandling: ObservableObject {
    @Published var errorMessage: String = ""
    @Published var shouldHandleInvalidKey = false
}

private struct CompositionalLocationManager: LocationTracking {

    let locationService: [LocationTracking]

    func startTracking() {
        locationService.forEach { $0.startTracking() }
    }

    func stopTracking() {
        locationService.forEach { $0.stopTracking() }
    }
}

private class ErrorHandlingPhotoService: ErrorHandling, PhotoService {
    var primaryPhotoService: PhotoService

    var imageURL: ((String) -> Void)? {
        didSet {
            primaryPhotoService.imageURL = self.imageURL
        }
    }

    init(primaryPhotoService: PhotoService) {
        self.primaryPhotoService = primaryPhotoService
    }

    @MainActor
    func fetchPhoto(latitude: Double, longitude: Double) async throws {
        do {
            shouldHandleInvalidKey = false
            try await primaryPhotoService.fetchPhoto(latitude: latitude, longitude: longitude)
        } catch let error as PhotoError {
            switch error {
            case .invalidURL:
                errorMessage = "Invalid URL"
                throw error
            case .noData:
                errorMessage = "No photos available for this place"
                throw error
            case .withFlickrError(let flickrFailResponse) where flickrFailResponse.invalidAPIKey:
                // invalid API Key
                shouldHandleInvalidKey = true
                errorMessage = flickrFailResponse.message
            case .withFlickrError(let flickrFailResponse):
                errorMessage = flickrFailResponse.message
                throw error
            }
        }
    }


}
