// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

@Observable
class ErrorHandling: NSObject, ObservableObject {
    var errorMessage: String = ""
    var shouldHandleInvalidKey: Bool = false
}
