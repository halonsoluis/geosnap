// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

// Reference call:
// https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=6a704fa13e809d5b0e65010950af64d2&content_types=0&media=photos&has_geo=1&lat=23.1023342&lon=-82.3917388&radius=0.1&radius_units=km&per_page=1&page=1&format=json&nojsoncallback=1


final class FlickrPhotoService: PhotoService {

    var imageURL: ((String) -> Void)?

    var apiKey: String? {
        //Easiest and cleanest way to communicate between UI and service for this MVP
        UserDefaults.standard.string(forKey: "apiKey")
    }

    func fetchPhoto(latitude: Double, longitude: Double) async throws {
        let photo = try await fetchPhotoWithReturn(latitude: latitude, longitude: longitude)

        guard let url = photo.url else {
            throw PhotoError.invalidURL
        }

        imageURL?(url.absoluteString)
    }

    func fetchPhotoWithReturn(latitude: Double, longitude: Double) async throws -> JsonPhoto {
        guard let apiKey else {
            throw PhotoError.withFlickrError(FlickrFailResponse(code: 100, message: "API key not present"))
        }
        var urlComponents = URLComponents(string: "https://www.flickr.com/services/rest/")!

        urlComponents.queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "lon", value: "\(longitude)"),
            URLQueryItem(name: "radius", value: "0.1"),
            URLQueryItem(name: "radius_units", value: "km"),
            URLQueryItem(name: "per_page", value: "1"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "content_type", value: "0"),
            URLQueryItem(name: "media", value: "photos"),
            URLQueryItem(name: "has_geo", value: "1"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]

        guard let url = urlComponents.url else {
            throw PhotoError.invalidURL
        }

        print("Fetching fotos via -> \(url)")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw PhotoError.noData
        }

        // Debug print for the received data
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Received JSON String: \(jsonString)")
        } else {
            print("Failed to convert data to string")
        }

        do {
            let flickrResponse = try JSONDecoder().decode(FlickrResponse.self, from: data)

            guard flickrResponse.isOK else {
                let flickrResponse = try JSONDecoder().decode(FlickrFailResponse.self, from: data)
                throw PhotoError.withFlickrError(flickrResponse)
            }

            let flickrGoodResponse = try JSONDecoder().decode(FlickrPhotoResponse.self, from: data)

            guard let photo = flickrGoodResponse.photos.photo.first else {
                throw PhotoError.noData
            }
            
            return photo

        } catch (let parsingError) {
            throw parsingError
        }
    }
}
