import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var isWalkActive = false
    @State private var timer: Timer?
    @State private var seenItemIDs: Set<Int> = []

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVStack(alignment: .center, spacing: 10) {
                    ForEach(items.sorted { $0.timestamp > $1.timestamp }, id: \.self) { item in
                        ImageWithOverlay(item: item)
                            .onAppear {
                                if isNewItem(item) {
                                    _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.2)) {
                                        seenItemIDs.insert(item.id.hashValue)
                                    }
                                }
                            }
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ToggleActivityButtonView(isWalkActive: $isWalkActive)
                }
                ToolbarItem {
                    Button(action: {
                        withAnimation {
                            addItem()
                        }
                    }) {
                        Text("Add")
                    }
                }
            }
            .onChange(of: isWalkActive) { _,_ in
                if timer != nil {
                    stopAddingItemsEverySecond()
                } else {
                    startAddingItemsEverySecond()
                }
            }
        }
    }

    struct ImageWithOverlay: View {
        let item: Item
        @State private var popScale: CGFloat = 0.99

        var body: some View {
            Image(uiImage: UIImage(imageLiteralResourceName: "demo"))
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
                .shadow(radius: 5)
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
                    .font(.headline)
                    .padding()
                    .background(isWalkActive ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
        }

        private func toggle() {
            isWalkActive.toggle()
            print("\(labelText) Walk")
        }
    }

    private func startAddingItemsEverySecond() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation(.easeInOut) {
                addItem()
            }
        }
    }

    private func stopAddingItemsEverySecond() {
        timer?.invalidate()
        timer = nil
    }

    private func addItem() {
        let newItem = Item(timestamp: Date())
        modelContext.insert(newItem)
    }

    private func isNewItem(_ item: Item) -> Bool {
        return !seenItemIDs.contains(item.id.hashValue)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
