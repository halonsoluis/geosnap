// Created for geosnap in 2024
// Using Swift 5.0

import Foundation
import SwiftData

struct ImageStorage {
    static func downloadAndCreateImageItem(from urlString: String) async throws -> Item {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let newItem = Item(timestamp: Date(), url: urlString, image: data)

        return newItem
    }

    static func saveImage(newItem: Item, context: ModelContext) throws {

        let allItems = try allItems(context: context)

        if allItems.contains(where: { $0.url == newItem.url || $0.timestamp == newItem.timestamp}) {
            print("An image with the same URL || timestamp already exists. Skipping save.")
            return
        }

        context.insert(newItem)

        try context.save()
    }

    static private func allItems(context: ModelContext) throws -> [Item] {

        var fetchDescriptor = FetchDescriptor<Item>()
        fetchDescriptor.propertiesToFetch = [\.timestamp, \.url]

        return try context.fetch(fetchDescriptor)
    }
}
