import SwiftUI

struct CharacterAvatarView: View {
  let profile: CharacterProfile
  var size: CGFloat = 72

  var body: some View {
    Group {
      if let image = CharacterPortraits.image(for: profile) {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
      } else {
        Image(systemName: profile.symbolName)
          .resizable()
          .scaledToFit()
          .padding(size * 0.25)
          .foregroundStyle(NovaTheme.primary)
          .background {
            Circle().fill(NovaTheme.surface)
          }
      }
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
    .overlay(Circle().stroke(NovaTheme.border, lineWidth: 1))
    .accessibilityLabel("Avatar for \(profile.name)")
  }
}
