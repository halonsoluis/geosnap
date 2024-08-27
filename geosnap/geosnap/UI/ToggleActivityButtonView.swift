// Created for geosnap in 2024
// Using Swift 5.0

import Foundation

import SwiftUI

struct ToggleActivityButtonView: View {
    @Binding var isWalkActive: Bool

    var labelText: String {
        isWalkActive ? "Stop" : "Start"
    }

    var body: some View {
        Button(action: toggle) {
            Text(labelText)
                .font(.title3)
                .padding()
                .foregroundColor(.primary)
                .cornerRadius(10)
        }
    }

    private func toggle() {
        print("\(labelText) Walk")
        isWalkActive.toggle()
    }
}

#Preview {
    @State var walking = false
    return ToggleActivityButtonView(isWalkActive: $walking)
}

#Preview {
    @State var walking = true
    return ToggleActivityButtonView(isWalkActive: $walking)
}
