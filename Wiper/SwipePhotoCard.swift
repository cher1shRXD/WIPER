import SwiftUI
import Photos

enum SwipeDirection {
    case left, right
}

struct SwipePhotoCard: View {
    let item: PhotoItem
    let getImage: (PHAsset, CGSize, @escaping (UIImage?) -> Void) -> Void
    let onSwiped: (SwipeDirection) -> Void
    let isInteractive: Bool

    @State private var offset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var image: UIImage?

    var combinedOffset: CGSize {
        CGSize(width: offset.width + dragOffset.width, height: offset.height + dragOffset.height)
    }

    var rotationAngle: Angle {
        .degrees(isInteractive ? Double(combinedOffset.width / 20.0) : 0)
    }

    var opacity: Double {
        isInteractive ? max(0.3, 1.0 - abs(combinedOffset.width) / 300.0) : 1.0
    }

    var overlayLabel: some View {
        Group {
            if isInteractive && combinedOffset.width < -50 {
                Text("KEEP")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .opacity(min(abs(combinedOffset.width) / 100.0, 1.0))
            } else if isInteractive && combinedOffset.width > 50 {
                Text("DELETE")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .opacity(min(abs(combinedOffset.width) / 100.0, 1.0))
            }
        }
    }

    var body: some View {
        VStack {
            if let img = image {
                let imageView = Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 32, height: 400)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .offset(combinedOffset)
                    .rotationEffect(rotationAngle)
                    .opacity(opacity)
                    .overlay(overlayLabel)

                if isInteractive {
                    imageView
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    dragOffset = gesture.translation
                                }
                                .onEnded { _ in
                                    let totalOffset = combinedOffset
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                        if totalOffset.width < -100 {
                                            offset = CGSize(width: -UIScreen.main.bounds.width, height: 0)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                onSwiped(.left)
                                                offset = .zero
                                            }
                                        } else if totalOffset.width > 100 {
                                            offset = CGSize(width: UIScreen.main.bounds.width, height: 0)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                onSwiped(.right)
                                                offset = .zero
                                            }
                                        }
                                        dragOffset = .zero
                                    }
                                }
                        )
                } else {
                    imageView
                }
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 400)
                    .overlay(
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("사진 로딩 중...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: offset)
    }

    private func loadImage() {
        getImage(item.asset, CGSize(width: 600, height: 600)) { uiImage in
            self.image = uiImage
        }
    }
}
