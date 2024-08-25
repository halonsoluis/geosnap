// Created for geosnap in 2024
// Using Swift 5.0

import XCTest
@testable import geosnap

final class FlickPhotoServiceTests: XCTestCase {

    var service: FlickrPhotoService!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        service = FlickrPhotoService()
    }

    func testFetchPhoto() throws {
        let expectation = expectation(description: "Attempt to call to server finishes")

        var retrievedResult: Result<Photo, Error>!
        service.fetchPhoto(latitude: 50.889715, longitude: 5.316397) { result in
            retrievedResult = result
            expectation.fulfill()
        }


        wait(for: [expectation])

        switch retrievedResult {
        case .success(let photo):
            XCTAssertEqual(photo.id, "16250914286")
        case .failure(let error as PhotoError):
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
        case .failure(let error):
            XCTFail("Something went wrong \(error)")
        case .none:
            XCTFail("Something went wrong")
        }
    }

}
