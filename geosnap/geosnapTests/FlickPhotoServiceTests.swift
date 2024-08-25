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
        service.fetchPhoto(latitude: 37.7749, longitude: -122.4194) { result in
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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
