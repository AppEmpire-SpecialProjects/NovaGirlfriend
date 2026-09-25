import SwiftUI

struct ScenarioDetailView: View {
  let scenario: Scenario
  let characters: [CharacterProfile]

  @AppStorage("preferences.hapticsEnabled") private var hapticsEnabled = true
  @AppStorage("preferences.selectedScenarioID") private var selectedScenarioID = ""
  @Environment(\.launchChat) private var launchChat
  @State private var selectedCharacter: CharacterProfile?
  @State private var showsCharacterSelection = false

  var body: some View {
    ScrollView {
      VStack(spacing: NovaTheme.Spacing.sectionGap) {
        VStack(spacing: NovaTheme.Spacing.cardGap) {
          hero
          detailCard
          characterChoice
        }
        startButton
      }
      .padding(NovaTheme.Spacing.screenMargin)
    }
    .novaScreen()
    .novaNavigationTitle(scenario.title)
    .sheet(isPresented: $showsCharacterSelection) {
      CharacterSelectionView(characters: characters, selectedCharacter: $selectedCharacter)
        .presentationDetents([.medium, .large])
    }
  }

  private var hero: some View {
    ZStack {
      NovaTheme.surface
      Image(systemName: scenario.symbolName)
        .font(.system(size: 76, weight: .ultraLight))
        .foregroundStyle(NovaTheme.primary)
        .accessibilityHidden(true)
    }
    .frame(minHeight: 240)
    .clipShape(RoundedRectangle(cornerRadius: NovaTheme.Radius.large))
    .overlay {
      RoundedRectangle(cornerRadius: NovaTheme.Radius.large)
        .stroke(NovaTheme.border, lineWidth: 1)
    }
    .accessibilityLabel("Illustration for \(scenario.title)")
  }

  private var detailCard: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.small) {
      VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
        Text("Set the scene")
          .font(NovaTheme.Typography.section)
        Text(scenario.summary)
          .font(NovaTheme.Typography.body)
          .foregroundStyle(NovaTheme.textSecondary)
      }
      Divider()
      Label(
        "The conversation will use this setting as context while following your lead.",
        systemImage: "text.bubble"
      )
      .font(.subheadline)
      .foregroundStyle(NovaTheme.textSecondary)
      .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(NovaTheme.Spacing.medium)
    .novaSurface()
  }

  private var characterChoice: some View {
    Button {
      showsCharacterSelection = true
    } label: {
      HStack(spacing: NovaTheme.Spacing.medium) {
        if let selectedCharacter {
          CharacterAvatarView(profile: selectedCharacter, size: 52)
            .accessibilityHidden(true)
          VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
            Text(selectedCharacter.name).font(NovaTheme.Typography.headline)
            Text("Selected character").font(.subheadline).foregroundStyle(NovaTheme.textSecondary)
          }
        } else {
          Image(systemName: "person.crop.circle.badge.plus")
            .font(.title2)
            .foregroundStyle(NovaTheme.primary)
            .frame(width: 52, height: 52)
            .background(NovaTheme.elevatedSurface, in: Circle())
            .accessibilityHidden(true)
          VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
            Text("Choose a character").font(NovaTheme.Typography.headline)
            Text("Required to begin").font(.subheadline).foregroundStyle(NovaTheme.textSecondary)
          }
        }
        Spacer()
        Image(systemName: "chevron.up.chevron.down")
          .font(.caption.weight(.semibold))
          .foregroundStyle(NovaTheme.primary)
      }
      .foregroundStyle(NovaTheme.text)
      .padding(NovaTheme.Spacing.medium)
      .novaSurface()
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("scenario.chooseCharacter")
    .accessibilityHint("Opens character selection")
  }

  @ViewBuilder
  private var startButton: some View {
    if let selectedCharacter {
      NovaPrimaryButton(
        "Start with \(selectedCharacter.name)", systemImage: "arrow.up.message.fill"
      ) {
        selectedScenarioID = scenario.id
        ExperienceFeedback.success(enabled: hapticsEnabled)
        launchChat(ChatLaunchContext(character: selectedCharacter, scenario: scenario))
      }
      .accessibilityHint("Starts a conversation using \(scenario.title) as context")
    } else {
      NovaPrimaryButton("Choose a character to start", systemImage: "person.crop.circle.badge.plus")
      {
        showsCharacterSelection = true
      }
      .accessibilityHint("Opens character selection")
    }
  }

}
