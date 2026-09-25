import SwiftUI

struct CharacterSelectionView: View {
  let characters: [CharacterProfile]
  @Binding var selectedCharacter: CharacterProfile?
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      List(characters) { character in
        Button {
          selectedCharacter = character
          dismiss()
        } label: {
          HStack(spacing: NovaTheme.Spacing.medium) {
            CharacterAvatarView(profile: character, size: 46)
              .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
              Text(character.name)
                .font(NovaTheme.Typography.headline)
                .foregroundStyle(NovaTheme.text)
              Text(character.tagline)
                .font(.subheadline)
                .foregroundStyle(NovaTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if selectedCharacter?.id == character.id {
              Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(NovaTheme.primary)
            }
          }
          .padding(.vertical, NovaTheme.Spacing.extraSmall)
        }
        .listRowBackground(NovaTheme.surface)
        .listRowSeparatorTint(NovaTheme.border)
        .accessibilityHint("Selects \(character.name) for this scenario")
      }
      .novaGroupedListSpacing()
      .novaScreen()
      .novaNavigationTitle("Choose a character")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
            .novaActionColor()
        }
      }
    }
  }
}
