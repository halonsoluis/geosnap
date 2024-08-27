import SwiftUI
import ActivityKit
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(FetchDescriptor<Item>(
        sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
    )) private var items: [Item]

    @State private var isWalkActive = false
    @State private var seenItemIDs: Set<Int> = []

    var locationManager: LocationTracking
    @ObservedObject var errorHandling: ErrorHandling


    var body: some View {
        ZStack {
            NavigationView {
                if items.isEmpty {
                    emptyView
                } else {
                    listView
                }

            }.onChange(of: isWalkActive) { _,_ in
                isWalkActive ? startWalk() : stopWalk()
            }

            if !errorHandling.errorMessage.isEmpty {
                errorBannerView(message: errorHandling.errorMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
    }

    private var listView: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .center, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    ImageWithOverlay(item: item)
                        .onAppear(perform: { animatePopOfNewItems(item) })
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ToggleActivityButtonView(isWalkActive: $isWalkActive)
            }

            ToolbarItem(placement: .navigationBarLeading) {
                ClearButton()
            }
        }

    }

    private var emptyView: some View {
        VStack(alignment: .center) {
            Image(systemName: isWalkActive ? "figure.walk.departure" : "figure.stand")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(.primary)

            Text("Every 100 meters I'll attempt to gather a new photo for you.")
                .bold()
                .font(.caption2)
                .foregroundColor(.primary)
                .padding(8)
                .cornerRadius(8)
                .padding([.leading, .trailing, .bottom], 4)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ToggleActivityButtonView(isWalkActive: $isWalkActive)
            }
        }
    }

    private func animatePopOfNewItems(_ item: Item) {
        guard isNewItem(item) else {
            return
        }
        _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.2)) {
            seenItemIDs.insert(item.id.hashValue)
        }
    }

    private struct ClearButton: View {
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
                // Save the context after deletions
                try modelContext.save()
                print("All items removed from the database.")
            } catch {
                print("Failed to remove items: \(error.localizedDescription)")
            }
        }
    }

    private func errorBannerView(message: String) -> some View {
        VStack(alignment: .trailing) {
            Spacer()

            HStack {
                Text(message)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(Color.red.opacity(0.60))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
        }
        .transition(.move(edge: .top))
        .animation(.spring(), value: message)
    }

    private struct ImageWithOverlay: View {
        let item: Item
        @State private var popScale: CGFloat = 0.99

        var body: some View {
            Image(uiImage: UIImage(data: item.image) ?? UIImage())
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.7))
                .cornerRadius(15)
                .overlay(alignment: .bottomTrailing) {
                    // Add gradient overlay for better contrast
                    LinearGradient(
                        gradient: Gradient(
                            colors: [.clear, .black.opacity(0.6)]
                        ),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .cornerRadius(15)
                    .overlay(
                        Text(formatDate(item.timestamp))
                            .bold()
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                            .shadow(radius: 3)
                            .padding([.trailing, .bottom], 4),
                        alignment: .bottomTrailing
                    )
                }
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 6)
                .scaleEffect(popScale)
                .onAppear {
                    // Smooth scaling animation
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.2)) {
                        popScale = 1.0
                    }
                }
        }

        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d/M/yy h:mm a"
            return formatter.string(from: date)
        }

    }


    private struct ToggleActivityButtonView: View {
        @Binding var isWalkActive: Bool

        var labelText: String {
            isWalkActive ? "Stop" : "Start"
        }

        var body: some View {
            Button(action: toggle, label: {
                Text(labelText)
                    .font(.title3)
                    .padding()
                //.background(isWalkActive ? Color.red : Color.green)
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            })
        }

        private func toggle() {
            print("\(labelText) Walk")
            isWalkActive.toggle()
        }
    }

    private func startWalk() {
        locationManager.startTracking()
    }

    private func stopWalk() {
        locationManager.stopTracking()
    }


    private func isNewItem(_ item: Item) -> Bool {
        return !seenItemIDs.contains(item.id.hashValue)
    }
}

struct MockLocationManager: LocationTracking {
    func startTracking() {
        print("Start tracking")
    }

    func stopTracking() {
        print("Stop tracking")
    }
}

class MockErrorHandling: ErrorHandling {

}

#Preview {
    MainView(locationManager: MockLocationManager(), errorHandling: MockErrorHandling())
        .modelContainer(for: Item.self, inMemory: true)
}
