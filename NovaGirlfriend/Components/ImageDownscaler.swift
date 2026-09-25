import SwiftUI

/// Downscales picked photos before they are stored in the chat photo store.
enum ImageDownscaler {
  static func jpegData(from data: Data, maxDimension: CGFloat = 1280, quality: CGFloat = 0.8) -> Data? {
    guard let image = UIImage(data: data) else { return nil }
    let largest = max(image.size.width, image.size.height)
    var scaled = image
    if largest > maxDimension, largest > 0 {
      let factor = maxDimension / largest
      let size = CGSize(width: floor(image.size.width * factor), height: floor(image.size.height * factor))
      let renderer = UIGraphicsImageRenderer(size: size)
      scaled = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: size))
      }
    }
    return scaled.jpegData(compressionQuality: quality)
  }
}
