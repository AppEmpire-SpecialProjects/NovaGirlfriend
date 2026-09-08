import SwiftUI

struct CharacterArtwork: View {
  let character: CharacterProfile
  var height: CGFloat = 220
  var showsName = false

  private let accent = NovaTheme.primary

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ZStack {
        LinearGradient(
          colors: [NovaTheme.elevatedSurface, NovaTheme.surface, NovaTheme.surface],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        if let image = CharacterPortraits.image(for: character) {
          GeometryReader { geometry in
            Image(uiImage: image)
              .resizable()
              .scaledToFill()
              .frame(width: geometry.size.width, height: geometry.size.height)
              .clipped()
          }
        } else {
          Circle()
            .strokeBorder(accent.opacity(0.22), lineWidth: 1)
            .frame(width: height * 0.95, height: height * 0.95)
            .offset(x: height * 0.28, y: -height * 0.18)

          Circle()
            .fill(accent.opacity(0.08))
            .frame(width: height * 0.72, height: height * 0.72)
            .offset(x: -height * 0.3, y: height * 0.26)

          Image(systemName: character.symbolName)
            .font(.system(size: min(height * 0.3, 92), weight: .light))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(NovaTheme.text)
            .shadow(color: NovaTheme.background.opacity(0.2), radius: 28, y: 8)
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: height)
      .clipped()

      if showsName {
        VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
          Text(character.name)
            .font(NovaTheme.Typography.title)
            .foregroundStyle(NovaTheme.text)
          Text(character.tagline)
            .font(.subheadline)
            .foregroundStyle(NovaTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(NovaTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NovaTheme.surface)
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Artwork for \(character.name), \(character.tagline)")
  }
}

@MainActor
enum CharacterPortraits {
  private static let selectableAssetNames = Set(
    ProductContentRepository().characters.compactMap(\.avatarAssetName))

  static func image(for character: CharacterProfile) -> UIImage? {
    if let uploaded = AvatarStorage.image(for: character.avatarAssetName) {
      return uploaded
    }
    if let assetName = character.avatarAssetName,
      character.origin == .builtIn || selectableAssetNames.contains(assetName),
      let image = UIImage(named: assetName)
    {
      return image
    }
    guard character.origin == .builtIn else { return nil }

    let assetName: String
    switch character.id.uuidString {
    case "A1000000-0000-0000-0000-000000000001":
      assetName = "NovaPortrait"
    case "A1000000-0000-0000-0000-000000000002":
      assetName = "MayaPortrait"
    case "A1000000-0000-0000-0000-000000000003":
      assetName = "ElenaPortrait"
    case "A1000000-0000-0000-0000-000000000004":
      assetName = "SofiaPortrait"
    default:
      return nil
    }
    return UIImage(named: assetName)
  }
}
