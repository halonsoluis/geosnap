// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

extension JsonPhoto {
    var url: URL? {
        let url = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        return URL(string: url)
    }
}
