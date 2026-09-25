import SwiftUI

struct GalleryLockedMomentSheet: View {
  let item: GalleryDisplayItem
  let exchanges: Int
  let chat: () -> Void
  @Environment(\.dismiss) private var dismiss
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    ScrollView {
      VStack(spacing: 18) {
        Image(systemName: "lock.fill")
          .font(.title2)
          .foregroundStyle(NovaTheme.primary)
          .frame(width: 52, height: 52)
          .background(NovaTheme.elevatedSurface, in: Circle())
          .accessibilityHidden(true)
        VStack(spacing: 8) {
          Text("Locked Moment")
            .font(.title2.weight(.semibold))
          Text(item.title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(NovaTheme.textSecondary)
          Text(
            "Exchange \(item.unlockRule.requiredExchanges) messages and replies with \(item.character.name) to discover this illustration."
          )
          .font(.subheadline)
          .foregroundStyle(NovaTheme.textSecondary)
          .fixedSize(horizontal: false, vertical: true)
          Text(
            "\(min(exchanges, item.unlockRule.requiredExchanges)) of \(item.unlockRule.requiredExchanges) exchanges completed"
          )
          .font(.caption)
          .foregroundStyle(NovaTheme.textSecondary)
          .accessibilityIdentifier("gallery.lockedProgress")
        }
        .multilineTextAlignment(.center)
        NovaPrimaryButton(
          "Chat with \(item.character.name)", systemImage: "bubble.left.and.bubble.right",
          action: chat
        )
        .accessibilityIdentifier("gallery.chat")
        Button("Not Now") { dismiss() }
          .font(.subheadline.weight(.medium))
          .foregroundStyle(NovaTheme.textSecondary)
          .frame(minHeight: 44)
      }
      .padding(24)
      .padding(.top, 8)
    }
    .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.height(400), .large])
    .presentationDragIndicator(.visible)
    .presentationBackground(NovaTheme.surface)
    .foregroundStyle(NovaTheme.text)
  }
}
