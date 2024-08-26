// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import SwiftData

struct ImageStorage {
    static func downloadAndSaveImage(from urlString: String, context: ModelContext) async throws {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let newItem = Item(timestamp: Date(), url: urlString, image: data)

        var fetchDescriptor = FetchDescriptor<Item>()
        fetchDescriptor.propertiesToFetch = [\.timestamp, \.url]

        let allItems = try context.fetch(fetchDescriptor)

        if allItems.contains(where: { $0.url == newItem.url && $0.timestamp == newItem.timestamp}) {
            print("An image with the same URL & timestamp already exists. Skipping save.")
            return
        }

        context.insert(newItem)
        
        try context.save()
    }
}
