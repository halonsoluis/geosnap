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

#Preview("Start Button") {
    ToggleActivityButtonView(isWalkActive: .constant(false))
}

#Preview("Stop Button") {
    ToggleActivityButtonView(isWalkActive: .constant(true))
}
