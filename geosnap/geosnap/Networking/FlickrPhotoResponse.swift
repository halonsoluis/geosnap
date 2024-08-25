// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

struct FlickrPhotoResponse: Decodable {
    let photos: Photos
    //  let stat: String
}

struct Photos: Decodable {
    //   let page: Int
    //   let pages: Int
    //   let perpage: Int
    //   let total: String
    let photo: [Photo]
}

struct Photo: Decodable {
    let id: String
    //  let owner: String
    let secret: String
    let server: String
    let farm: Int
    //   let title: String
    //   let ispublic: Int
    //  let isfriend: Int
    //   let isfamily: Int
}
