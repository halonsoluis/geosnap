// Created for geosnap in 2024
// Using Swift 5.0

import XCTest
@testable import geosnap

final class FlickPhotoServiceTests: XCTestCase {

    var service: FlickrPhotoService!
    private let expiredKey = "6a704fa13e809d5b0e65010950af64d2"
    private let validKey = "6ace69042a6f0c80417a8e2e12f5abcf" // will be expired soon, this is a book definition flaky test

    override func setUp() {
        service = FlickrPhotoService(apiKey: validKey)
    }

    override func tearDown() {
        service = nil
    }

    func testFetchPhoto() async throws {
        do {
            let photo = try await service.fetchPhoto(latitude: 50.889715, longitude: 5.316397)

            guard let url = photo.url else {
                XCTFail("url malformed")
                return
            }
            print(url.absoluteString)
        } catch (let error as PhotoError) {
            let errorMessage: String
            switch error {
            case .invalidURL:
                errorMessage = "Invalid URL"
            case .noData:
                errorMessage = "No data returned"
            case .withFlickrError(let flickrError):
                errorMessage = "Flickr API returned an error: \(flickrError.message) (Code: \(flickrError.code))"
            }
            XCTFail(errorMessage)
        }
        catch(let error) {
            XCTFail("Something went wrong \(error)")
        }
    }
}
