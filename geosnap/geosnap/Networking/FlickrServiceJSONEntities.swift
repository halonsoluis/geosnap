// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

struct FlickrResponse: Decodable {
    let stat: String

    var isOK: Bool {
        stat == "ok"
    }
}

struct FlickrPhotoResponse: Decodable {
    let photos: JsonPhotos
}

struct FlickrFailResponse: Decodable {
    let code: Int
    let message: String

    var invalidAPIKey: Bool {
        code == 100
    }
}


// Will use only what is needed for a very simple MVP, loading only 1 foto if available
struct JsonPhotos: Decodable {
    //   let page: Int
    //   let pages: Int
    //   let perpage: Int
    //   let total: String
    let photo: [JsonPhoto]
}

// Only parse what is relevant as for this MVP
struct JsonPhoto: Decodable {
    let id: String
    //  let owner: String
    let secret: String
    let server: String
    let farm: Int
    //   let title: String
    //   let ispublic: Int
    //   let isfriend: Int
    //   let isfamily: Int
}


