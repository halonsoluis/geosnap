// Created for geosnap in 2024
// Using Swift 5.0

import SwiftUI

struct ApiKeyInputOverlay: View {
    @Binding var showingTextFieldOverlay: Bool
    @State private var newApiKey: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @AppStorage("apiKey") private var apiKey: String = ""

    var handleNewAPIKey: ()->(Void)

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("Enter a valid API Key")
                    .font(.headline)
                    .padding()

                TextField("New API Key", text: $newApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .focused($isTextFieldFocused)
                    .onAppear {
                        isTextFieldFocused = true
                    }.onDisappear {
                        isTextFieldFocused = false
                    }

                HStack(alignment: .center) {
                    Button("Cancel") {
                        showingTextFieldOverlay = false
                    }
                    .padding()
                    .foregroundColor(.red)

                    Spacer()

                    Button("Save") {
                        showingTextFieldOverlay = false
                        apiKey = newApiKey
                        print("New API Key entered: \(newApiKey)")
                        handleNewAPIKey()
                    }
                    .padding()
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding()

            Spacer()
        }
        .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    @State var showingTextFieldOverlay = true
    func handleNewAPIKey() {}
    return ApiKeyInputOverlay(showingTextFieldOverlay: $showingTextFieldOverlay, handleNewAPIKey: handleNewAPIKey)
}
