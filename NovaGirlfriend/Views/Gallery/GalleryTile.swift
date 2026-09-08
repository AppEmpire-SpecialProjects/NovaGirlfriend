import SwiftUI

struct GalleryTile: View {
  let item: GalleryDisplayItem
  let open: () -> Void
  let save: () -> Void
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
  @AppStorage("preferences.reduceMotion") private var prefersReducedMotion = false
  private var motion: GalleryMotion {
    GalleryMotion(systemReduceMotion: systemReduceMotion, appReduceMotion: prefersReducedMotion)
  }

  var body: some View {
    Button(action: open) {
      Color.clear
        .aspectRatio(3.0 / 4.0, contentMode: .fit)
        .overlay {
          GeometryReader { geometry in
            Image(uiImage: item.image)
              .resizable()
              .scaledToFill()
              .frame(width: geometry.size.width, height: geometry.size.height)
              .blur(radius: item.isLocked ? 24 : 0, opaque: true)
              .clipped()
          }
        }
        .overlay {
          if item.isLocked {
            Color.black.opacity(0.55)
            VStack(spacing: 12) {
              Image(systemName: "lock.fill")
                .font(.title2.weight(.medium))
              Text(item.unlockRule.requirement)
                .font(.caption.weight(.medium))
                .multilineTextAlignment(.center)
            }
            .padding(12)
            .foregroundStyle(.white)
          } else {
            LinearGradient(
              colors: [.clear, .black.opacity(0.06), .black.opacity(0.78)],
              startPoint: .center, endPoint: .bottom
            )
          }
        }
        .overlay(alignment: .bottomLeading) {
          if item.isUnlocked {
            Text(item.title)
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(.white)
              .lineLimit(2)
              .padding(12)
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .contentShape(RoundedRectangle(cornerRadius: 18))
    }
    .buttonStyle(.plain)
    .accessibilityLabel("\(item.character.name), \(item.title)")
    .accessibilityValue(item.isLocked ? "Locked. \(item.unlockRule.requirement)" : "Unlocked")
    .accessibilityHint(
      item.isLocked ? "Shows how to unlock this moment" : "Opens full-screen photo"
    )
    .accessibilityIdentifier("gallery.moment.\(item.id.uuidString)")
    .overlay(alignment: .topTrailing) {
      if item.isUnlocked {
        Button(action: save) {
          Image(systemName: item.isSaved ? "heart.fill" : "heart")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(item.isSaved ? NovaTheme.primary : .white)
            .frame(width: 36, height: 36)
            .background(.black.opacity(0.45), in: Circle())
            .scaleEffect(item.isSaved ? 1.06 : 1)
            .animation(motion.animation(.easeOut(duration: 0.18)), value: item.isSaved)
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .padding(4)
        .accessibilityLabel(item.isSaved ? "Unsave \(item.title)" : "Save \(item.title)")
        .accessibilityIdentifier("gallery.save.\(item.id.uuidString)")
      }
    }
  }
}
