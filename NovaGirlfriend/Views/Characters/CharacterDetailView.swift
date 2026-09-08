import SwiftUI

struct CharacterDetailView: View {
  let character: CharacterProfile
  let scenarios: [Scenario]

  @AppStorage("preferences.hapticsEnabled") private var hapticsEnabled = true
  @Environment(\.launchChat) private var launchChat
  @StateObject private var viewModel: CharacterDetailViewModel
  private let speech = SystemTextToSpeechService()

  init(character: CharacterProfile, scenarios: [Scenario]) {
    self.character = character
    self.scenarios = scenarios
    _viewModel = StateObject(wrappedValue: CharacterDetailViewModel(characterID: character.id))
  }

  var body: some View {
    ScrollView {
      VStack(spacing: NovaTheme.Spacing.sectionGap) {
        CharacterArtwork(character: character, height: 360, showsName: true)
          .clipShape(RoundedRectangle(cornerRadius: NovaTheme.Radius.large))

        primaryActions

        aboutSection
        personalitySection
        destinationSection
      }
      .padding(NovaTheme.Spacing.screenMargin)
    }
    .novaScreen()
    .toolbar(.hidden, for: .tabBar)
    .novaNavigationTitle(character.name)
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        Button {
          viewModel.toggleFavorite()
          ExperienceFeedback.selection(enabled: hapticsEnabled)
        } label: {
          Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
            .foregroundStyle(viewModel.isFavorite ? NovaTheme.primary : NovaTheme.inactiveIcon)
        }
        .accessibilityLabel(viewModel.isFavorite ? "Remove from favorites" : "Add to favorites")

        Button {
          viewModel.showsMore = true
        } label: {
          Image(systemName: "ellipsis")
        }
        .novaActionColor()
        .accessibilityLabel("More about \(character.name)")
      }
    }
    .onDisappear { speech.stop() }
    .sheet(isPresented: $viewModel.showsMore) {
      CharacterMoreView(character: character)
        .presentationDetents([.medium, .large])
    }
  }

  private var primaryActions: some View {
    VStack(spacing: NovaTheme.Spacing.small) {
      NovaPrimaryButton("Chat with \(character.name)", systemImage: "bubble.left.fill") {
        ExperienceFeedback.success(enabled: hapticsEnabled)
        launchChat(ChatLaunchContext(character: character, scenario: nil))
      }

      voiceButton
    }
  }

  private var voiceButton: some View {
    Button {
      speech.speak("Hi, I'm \(character.name). \(character.tagline).", voice: character.voice)
      ExperienceFeedback.selection(enabled: hapticsEnabled)
    } label: {
      Label("Hear voice", systemImage: "speaker.wave.2.fill")
        .frame(maxWidth: .infinity)
    }
    .font(NovaTheme.Typography.label)
    .buttonStyle(NovaSecondaryButtonStyle())
    .controlSize(.large)
    .accessibilityHint("Plays a short local voice introduction")

  }

  private var aboutSection: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.small) {
      Text("About \(character.name)")
        .font(NovaTheme.Typography.section)
      Text(character.biography)
        .font(.body)
        .foregroundStyle(NovaTheme.textSecondary)
        .lineSpacing(4)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var personalitySection: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.medium) {
      Text("Personality")
        .font(NovaTheme.Typography.section)
      PersonalityMeter(
        title: "Warmth", value: character.personality.warmth, tint: NovaTheme.primary)
      PersonalityMeter(
        title: "Humor", value: character.personality.humor, tint: NovaTheme.secondary)
      PersonalityMeter(
        title: "Curiosity", value: character.personality.curiosity,
        tint: NovaTheme.primary)
    }
    .padding(NovaTheme.Spacing.medium)
    .novaSurface()
  }

  private var destinationSection: some View {
    VStack(spacing: NovaTheme.Spacing.cardGap) {
      NavigationLink {
        CharacterGalleryView(character: character)
      } label: {
        destinationLabel(
          "Gallery", subtitle: "View included and saved moments", symbol: "photo.stack.fill")
      }

      NavigationLink {
        ScenariosView(scenarios: scenarios, characters: [character])
      } label: {
        destinationLabel(
          "Scenarios", subtitle: "Choose a setting with \(character.name)",
          symbol: "sparkles.rectangle.stack")
      }
    }
    .buttonStyle(.plain)
  }

  private func destinationLabel(_ title: String, subtitle: String, symbol: String) -> some View {
    HStack(spacing: NovaTheme.Spacing.medium) {
      Image(systemName: symbol)
        .font(.title3)
        .foregroundStyle(NovaTheme.primary)
        .frame(width: 42, height: 42)
        .background(NovaTheme.surface, in: Circle())
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
        Text(title).font(NovaTheme.Typography.headline)
        Text(subtitle).font(.subheadline).foregroundStyle(NovaTheme.textSecondary)
      }
      Spacer()
      Image(systemName: "chevron.right").foregroundStyle(NovaTheme.primary)
    }
    .foregroundStyle(NovaTheme.text)
    .padding(NovaTheme.Spacing.medium)
    .novaSurface()
  }

}

private struct PersonalityMeter: View {
  let title: String
  let value: Int
  let tint: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      HStack {
        Text(title).font(.subheadline.weight(.medium))
        Spacer()
        Text("\(value)%").font(.caption.monospacedDigit()).foregroundStyle(NovaTheme.textSecondary)
      }
      ProgressView(value: Double(value), total: 100)
        .tint(tint)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(title)
    .accessibilityValue("\(value) percent")
  }
}
