// Created for geosnap in 2024
// Using Swift 5.0

import SwiftUI
import SwiftData

struct ClearButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        Button(action: clean, label: {
            Text("Clear")
                .font(.title3)
                .padding()
                .foregroundColor(.red)
                .cornerRadius(10)
        })
    }

    private func clean() {
        // Remove all items from the database
        for item in items {
            modelContext.delete(item)
        }

        do {
            try modelContext.save()
            print("All items removed from the database.")
        } catch {
            print("Failed to remove items: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ClearButton()
}

