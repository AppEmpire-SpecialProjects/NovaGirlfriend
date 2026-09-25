import SwiftUI

struct CharacterMoreView: View {
  let character: CharacterProfile
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      List {
        Section {
          LabeledContent("Conversation style") {
            Text(character.personality.communicationStyle)
              .foregroundStyle(NovaTheme.textSecondary)
          }
          LabeledContent("Origin") {
            Text(character.origin == .builtIn ? "Built-in character" : "Created by you")
              .foregroundStyle(NovaTheme.textSecondary)
          }
        } header: {
          Text("About")
            .font(NovaTheme.Typography.headline)
            .textCase(nil)
            .foregroundStyle(NovaTheme.textSecondary)
        }
        .listRowBackground(NovaTheme.surface)
        .listRowSeparatorTint(NovaTheme.border)

        Section {
          ShareLink(item: "Meet \(character.name) — \(character.tagline)") {
            Label("Share character", systemImage: "square.and.arrow.up")
          }
          .novaActionColor()
        } header: {
          Text("Share")
            .font(NovaTheme.Typography.headline)
            .textCase(nil)
            .foregroundStyle(NovaTheme.textSecondary)
        }
        .listRowBackground(NovaTheme.surface)
        .listRowSeparatorTint(NovaTheme.border)

        Section {
          Text(
            "Characters are fictional conversational experiences. Their profile never implies a real-world relationship or activity."
          )
          .foregroundStyle(NovaTheme.textSecondary)
        } header: {
          Text("Transparency")
            .font(NovaTheme.Typography.headline)
            .textCase(nil)
            .foregroundStyle(NovaTheme.textSecondary)
        }
        .listRowBackground(NovaTheme.surface)
        .listRowSeparatorTint(NovaTheme.border)
      }
      .novaGroupedListSpacing()
      .novaScreen()
      .novaNavigationTitle(character.name)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
            .novaActionColor()
        }
      }
    }
  }
}
