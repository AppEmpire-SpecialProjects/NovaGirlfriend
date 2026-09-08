import SwiftUI

struct CharacterCard: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  let character: CharacterProfile

  private var cardShape: RoundedRectangle {
    RoundedRectangle(cornerRadius: NovaTheme.Radius.large, style: .continuous)
  }

  private var cardLayout: AnyLayout {
    if dynamicTypeSize.isAccessibilitySize {
      return AnyLayout(VStackLayout(alignment: .leading, spacing: NovaTheme.Spacing.medium))
    }
    return AnyLayout(HStackLayout(alignment: .top, spacing: NovaTheme.Spacing.medium))
  }

  var body: some View {
    cardLayout {
      CharacterArtwork(character: character, height: 112)
        .frame(width: 88)
        .clipShape(
          RoundedRectangle(cornerRadius: NovaTheme.Radius.medium, style: .continuous)
        )
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: NovaTheme.Spacing.small) {
        VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
          HStack(alignment: .firstTextBaseline, spacing: NovaTheme.Spacing.small) {
            Text(character.name)
              .font(NovaTheme.Typography.headline)
              .foregroundStyle(NovaTheme.text)
              .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
              .font(.caption.weight(.semibold))
              .foregroundStyle(NovaTheme.textTertiary)
              .accessibilityHidden(true)
          }

          Text(character.tagline)
            .font(.subheadline)
            .foregroundStyle(NovaTheme.textSecondary)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
            .fixedSize(horizontal: false, vertical: true)
        }

        Label(character.personality.communicationStyle, systemImage: "quote.bubble")
          .font(.caption)
          .foregroundStyle(NovaTheme.textSecondary)
          .fixedSize(horizontal: false, vertical: true)

      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(NovaTheme.Spacing.medium)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(NovaTheme.surface, in: cardShape)
    .overlay {
      cardShape
        .strokeBorder(NovaTheme.border)
        .allowsHitTesting(false)
    }
    .contentShape(cardShape)
    .accessibilityElement(children: .combine)
    .accessibilityHint("Opens \(character.name)'s profile")
  }
}
