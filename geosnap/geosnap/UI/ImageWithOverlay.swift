// Created for geosnap in 2024
// Using Swift 5.0
import SwiftUI

struct ImageWithOverlay: View {
    let item: StoredPhoto
    let withOverlay: Bool
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
                if withOverlay {
                    overlayTimeStamp
                }
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

    private var overlayTimeStamp: some View {
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

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M/yy h:mm a"

        return formatter.string(from: date)
    }
}

#Preview("Image with overlay") {
    ImageWithOverlay(
        item: StoredPhoto(
            timestamp: Date(),
            url: "fakeURL",
            image: UIImage(named: "demo")!.pngData()!
        ),
        withOverlay: true
    )
    .previewDisplayName("with Overlay")
}

#Preview("Image without overlay") {
    ImageWithOverlay(
        item: StoredPhoto(
            timestamp: Date(),
            url: "fakeURL",
            image: UIImage(named: "demo")!.pngData()!
        ),
        withOverlay: false
    )
    .previewDisplayName("without Overlay")
}
