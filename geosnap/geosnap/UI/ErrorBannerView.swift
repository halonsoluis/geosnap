// Created for geosnap in 2024
// Using Swift 5.0

import SwiftUI

struct ErrorBannerView: View {
    let message: String

    var body: some View {
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
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(), value: message)
        .zIndex(1)
    }
}

#Preview {
   ErrorBannerView(message: "Oops, test error message")
}
