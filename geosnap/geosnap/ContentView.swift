import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(FetchDescriptor<Item>(
        sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
    )) private var items: [Item]

    @State private var isWalkActive = false
    @State private var seenItemIDs: Set<Int> = []

    var locationManager: LocationTracking


    var body: some View {
        NavigationView {
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
            }
            .onChange(of: isWalkActive) { _,_ in
                isWalkActive ? startWalk() : stopWalk()
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

    struct ImageWithOverlay: View {
        let item: Item
        @State private var popScale: CGFloat = 0.99

        var body: some View {
            Image(uiImage: UIImage(data: item.image) ?? UIImage())
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(6)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .overlay {
                    Text(item.timestamp, format: .dateTime.hour().minute().second())
                        .bold()
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(5)
                }
                //.shadow(radius: 5)
                .scaleEffect(popScale)
                .onAppear {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.2)) {
                        popScale = 1.0
                    }
                }
        }
    }

    struct ToggleActivityButtonView: View {
        @Binding var isWalkActive: Bool

        var labelText: String {
            isWalkActive ? "Stop" : "Start"
        }

        var body: some View {
            Button(action: toggle, label: {
                Text(labelText)
                    .font(.title)
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

#Preview {
    ContentView(locationManager: MockLocationManager())
        .modelContainer(for: Item.self, inMemory: true)
}
