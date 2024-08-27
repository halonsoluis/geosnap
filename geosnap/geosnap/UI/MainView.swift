import SwiftUI
import ActivityKit
import SwiftData

struct MainView: View {
    @State private var isWalkActive = false
    @State private var isShowingApiKeyPopover = false
    @State private var showingTextFieldOverlay = false

    @Environment(\.modelContext) private var modelContext

    @Query(FetchDescriptor<StoredPhoto>(
        sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
    )) private var items: [StoredPhoto]

    var locationManager: LocationTracking
    @ObservedObject var errorHandling: ErrorHandling

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if items.isEmpty {
                        EmptyView(isWalkActive: $isWalkActive)
                    } else {
                        ListView(items: items)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ToggleActivityButtonView(isWalkActive: $isWalkActive)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        if !items.isEmpty {
                            ClearButton()
                        }
                    }
                }

            }.onChange(of: isWalkActive) { _,_ in
                isWalkActive ? startWalk() : stopWalk()
            }.onChange(of: errorHandling.shouldHandleInvalidKey) { oldValue, newValue in
                if newValue {
                    isWalkActive = false
                }
                isShowingApiKeyPopover = newValue
            }.alert(isPresented: $isShowingApiKeyPopover) {
                invalidApiKeyAlert()
            }

            if !errorHandling.errorMessage.isEmpty {
                ErrorBannerView(message: errorHandling.errorMessage)

            }

            if showingTextFieldOverlay {
                ApiKeyInputOverlay(
                    showingTextFieldOverlay: $showingTextFieldOverlay,
                    handleNewAPIKey: newApiKeyHandled
                )
            }
        }
    }

    private func invalidApiKeyAlert() -> Alert {
        Alert(
            title: Text("Invalid API Key"),
            message: Text("Your current API key is not valid. Please enter a new one."),
            primaryButton: .default(Text("Enter")) {
                showingTextFieldOverlay = true
            },
            secondaryButton: .cancel {
                errorHandling.shouldHandleInvalidKey = false
            }
        )
    }


    private func newApiKeyHandled() {
        isShowingApiKeyPopover = false
    }

    private func startWalk() {
        locationManager.startTracking()
    }

    private func stopWalk() {
        locationManager.stopTracking()
    }

}

#Preview {

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

    return MainView(locationManager: MockLocationManager(), errorHandling: MockErrorHandling())
        .modelContainer(for: StoredPhoto.self, inMemory: true)
}
