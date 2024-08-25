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

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchPhoto() throws {
        let expectation = expectation(description: "Attempt to call to server finishes")

        var retrievedResult: Result<Data, Error>!
        service.fetchPhoto(latitude: 50.889715, longitude: 5.316397) { result in
            retrievedResult = result
            expectation.fulfill()
        }


        wait(for: [expectation])

        switch retrievedResult {
        case .success(let data):
            XCTAssert(data != nil)
        case .failure(let error):
            XCTFail("Something went wrong \(error)")
        case .none:
            XCTFail("Something went wrong")
        }
    }

}
