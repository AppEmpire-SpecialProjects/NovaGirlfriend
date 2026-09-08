import SwiftUI

@main
struct GalleryMotionChecks {
  static func main() {
    for system in [false, true] {
      for app in [false, true] {
        let motion = GalleryMotion(systemReduceMotion: system, appReduceMotion: app)
        let reduced = system || app
        for animation in [
          Animation.easeInOut(duration: 0.18), .easeInOut(duration: 0.22),
          .easeOut(duration: 0.18),
        ] {
          precondition((motion.animation(animation) == nil) == reduced)
        }
        var transaction = Transaction(animation: .default)
        motion.apply(to: &transaction)
        precondition(transaction.disablesAnimations == reduced)
        precondition((transaction.animation == nil) == reduced)
        var alreadyDisabled = Transaction()
        alreadyDisabled.disablesAnimations = true
        motion.apply(to: &alreadyDisabled)
        precondition(alreadyDisabled.disablesAnimations)
        print(
          "PASS: system=\(system), app=\(app): implicit animations and presentation transactions")
      }
    }
  }
}
