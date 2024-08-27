// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

class ErrorHandling: ObservableObject {
    @Published var errorMessage: String = ""
    @Published var shouldHandleInvalidKey = false
}
