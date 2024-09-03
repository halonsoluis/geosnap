// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

class ErrorHandlingPhotoService: ErrorHandling, PhotoService {
    let primaryPhotoService: PhotoService

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
            try await primaryPhotoService.fetchPhoto(latitude: latitude, longitude: longitude)

            errorMessage = ""
            shouldHandleInvalidKey = false
        } catch let error as PhotoError {
            switch error {
            case .invalidURL:
                errorMessage = "Invalid URL"
            case .noData:
                break
            case .withFlickrError(let flickrFailResponse) where flickrFailResponse.invalidAPIKey:
                shouldHandleInvalidKey = true
            case .withFlickrError(let flickrFailResponse):
                errorMessage = flickrFailResponse.message
            }
            throw error
        } catch let error {
            errorMessage = error.localizedDescription
            throw error
        }
    }


}
