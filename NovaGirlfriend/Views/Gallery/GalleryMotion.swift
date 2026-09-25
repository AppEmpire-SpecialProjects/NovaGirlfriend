import SwiftUI

struct GalleryMotion {
  let systemReduceMotion: Bool
  let appReduceMotion: Bool

  private var reduced: Bool { systemReduceMotion || appReduceMotion }

  func animation(_ proposed: Animation) -> Animation? {
    reduced ? nil : proposed
  }

  func apply(to transaction: inout Transaction) {
    if reduced {
      transaction.animation = nil
      transaction.disablesAnimations = true
    }
  }
}
