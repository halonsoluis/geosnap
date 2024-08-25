// Created for geosnap in 2024
// Using Swift 5.0

import XCTest

/*
 Result of call.

 {
     "photos": {
         "page": 1,
         "pages": 11,
         "perpage": 1,
         "total": 11,
         "photo": [
             {
                 "id": "16250914286",
                 "owner": "25304693@N00",
                 "secret": "35e6795da4",
                 "server": "8608",
                 "farm": 9,
                 "title": "The results of the Belgian Weather :-)",
                 "ispublic": 1,
                 "isfriend": 0,
                 "isfamily": 0
             }
         ]
     },
     "stat": "ok"
 }
 */

struct FlickrPhotoResponse: Decodable {
    let photos: Photos
    let stat: String
}

struct Photos: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}

struct Photo: Decodable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

final class FlickrPhotoResponseTests: XCTestCase {

    let jsonData = """
    {
        "photos": {
            "page": 1,
            "pages": 11,
            "perpage": 1,
            "total": "11",
            "photo": [
                {
                    "id": "16250914286",
                    "owner": "25304693@N00",
                    "secret": "35e6795da4",
                    "server": "8608",
                    "farm": 9,
                    "title": "The results of the Belgian Weather :-)",
                    "ispublic": 1,
                    "isfriend": 0,
                    "isfamily": 0
                }
            ]
        },
        "stat": "ok"
    }
    """.data(using: .utf8)!

    func testParsingWorks() throws {
        let flickrResponse = try JSONDecoder().decode(FlickrPhotoResponse.self, from: jsonData)

        let photos = flickrResponse.photos.photo
        XCTAssertEqual(photos.count, 1)


        XCTAssertEqual(photos.first!.id, "16250914286")
        XCTAssertEqual(photos.first!.secret, "35e6795da4")
        XCTAssertEqual(photos.first!.server, "8608")
        XCTAssertEqual(photos.first!.farm, 9)

    }

}
