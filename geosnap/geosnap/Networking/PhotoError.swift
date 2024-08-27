// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

enum PhotoError: Error {
    case invalidURL
    case noData
    case withFlickrError(FlickrFailResponse)
}
