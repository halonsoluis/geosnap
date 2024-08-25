// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var url: String
    var image: Data

    init(timestamp: Date, url: String, image: Data) {
        self.timestamp = timestamp
        self.url = url
        self.image = image
    }
}
