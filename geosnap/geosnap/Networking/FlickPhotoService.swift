// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

// Reference call:
// https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=6a704fa13e809d5b0e65010950af64d2&content_types=0&media=photos&has_geo=1&lat=23.1023342&lon=-82.3917388&radius=0.1&radius_units=km&per_page=1&page=1&format=json&nojsoncallback=1

enum PhotoError: Error {
    case invalidURL
    case noData
}

// MARK: - Flickr API Implementation
struct FlickrPhotoService {
    private let apiKey = "6a704fa13e809d5b0e65010950af64d2"  //TODO: Change API key and keep this in a safe place as a secret

    func fetchPhoto(latitude: Double, longitude: Double, completion: @escaping (Result<Data, Error>) -> Void) {
        let baseURL = "https://www.flickr.com/services/rest/"
        let parameters = "?method=flickr.photos.search&api_key=\(apiKey)&lat=\(latitude)&lon=\(longitude)&radius=0.1&radius_units=km&per_page=1&page=1&content_type=0&media=photos&has_geo=1&format=json&nojsoncallback=1"
        let urlString = "\(baseURL)\(parameters)"

        guard let url = URL(string: urlString) else {
            completion(.failure(PhotoError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(PhotoError.noData))
                return
            }

            completion(.success(data))
        }
        task.resume()
    }
}
