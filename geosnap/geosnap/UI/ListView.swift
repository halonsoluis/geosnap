// Created for geosnap in 2024
// Using Swift 5.0

import SwiftUI

struct ListView: View {
    let items: [StoredPhoto]
    @State private var seenItemIDs: Set<Int> = []

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .center, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    ImageWithOverlay(item: item, withOverlay: false)
                        .onAppear {
                            animatePopOfNewItems(item)
                        }
                }
            }
            .padding()
        }
    }

    private func animatePopOfNewItems(_ item: StoredPhoto) {
        guard isNewItem(item) else {
            return
        }
        _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.2)) {
            seenItemIDs.insert(item.id.hashValue)
        }
    }

    private func isNewItem(_ item: StoredPhoto) -> Bool {
        return !seenItemIDs.contains(item.id.hashValue)
    }
}


#Preview("Not Empty") {
    ListView(
        items: (0..<5).map { _ in
            StoredPhoto(timestamp: Date(), url: "fakeURL", image: UIImage(named: "demo")!.pngData()!)
        }
    )
}

#Preview("Empty") {
    ListView(items: [])
}
