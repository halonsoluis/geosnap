// Created for geosnap in 2024
// Using Swift 5.0

import SwiftUI

struct EmptyView: View {
    @Binding var isWalkActive: Bool

    var body: some View {
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
    }
}

#Preview {
    @State var walking = false
    return EmptyView(isWalkActive: $walking)
}

#Preview {
    @State var walking = true
    return EmptyView(isWalkActive: $walking)
}
