// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

protocol PhotoService: AnyObject {
    func fetchPhoto(latitude: Double, longitude: Double) async throws
    var imageURL: ((String) -> Void)? { get set }
}
