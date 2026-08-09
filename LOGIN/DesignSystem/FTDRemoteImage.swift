import SwiftUI

/// A design-system wrapper around AsyncImage that provides a shimmer placeholder
/// and an optional fallback view when the image fails to load or the URL is nil.
struct FTDRemoteImage<Fallback: View>: View {

    private let url: URL?
    private let contentMode: ContentMode
    private let fallback: Fallback

    init(
        url: URL?,
        contentMode: ContentMode = .fit,
        @ViewBuilder fallback: () -> Fallback
    ) {
        self.url = url
        self.contentMode = contentMode
        self.fallback = fallback()
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                fallback
            case .empty:
                ShimmerView()
            @unknown default:
                ShimmerView()
            }
        }
    }
}

// Convenience init without a fallback — shows an empty gray rectangle
extension FTDRemoteImage where Fallback == Color {
    init(url: URL?, contentMode: ContentMode = .fit) {
        self.init(url: url, contentMode: contentMode) {
            Color.ftdCardBackground
        }
    }
}

// MARK: - Shimmer

private struct ShimmerView: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(shimmerGradient(width: geo.size.width))
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        }
        .background(Color.ftdCardBackground)
    }

    private func shimmerGradient(width: CGFloat) -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color.ftdCardBackground, location: 0),
                .init(color: Color.ftdCardBackground.opacity(0.4), location: 0.4 + phase * 0.3),
                .init(color: Color.ftdCardBackground, location: 0.8 + phase * 0.3),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
