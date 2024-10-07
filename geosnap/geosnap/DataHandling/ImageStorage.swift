// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import SwiftData

struct Photo {
    let timestamp: Date
    let url: String
    let image: Data
}

struct ImageStorage {
    static func downloadAndCreateImageItem(from urlString: String) async throws -> Photo {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let newItem = StoredPhoto(timestamp: Date(), url: urlString, image: data)

        return Photo(timestamp: newItem.timestamp, url: newItem.url, image: newItem.image)
    }

    static func saveImage(newItem: Photo, context: ModelContext) throws {

        let allItems = try allItems(context: context)

        if allItems.contains(where: { $0.url == newItem.url || $0.timestamp == newItem.timestamp}) {
            print("An image with the same URL || timestamp already exists. Skipping save.")
            return
        }

        context.insert(
            StoredPhoto(timestamp: newItem.timestamp, url: newItem.url, image: newItem.image)
        )

        try context.save()
    }

    static private func allItems(context: ModelContext) throws -> [StoredPhoto] {

        var fetchDescriptor = FetchDescriptor<StoredPhoto>()
        fetchDescriptor.propertiesToFetch = [\.timestamp, \.url]

        return try context.fetch(fetchDescriptor)
    }
}
