import SwiftData
import SwiftUI

struct DiscoverView: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @StateObject private var viewModel = DiscoverViewModel()
  @Query private var customRecords: [CharacterRecord]
  @State private var showsCreator = false
  @State private var pendingCreatedProfile: CharacterProfile?
  @State private var createdProfile: CharacterProfile?

  private var allCharacters: [CharacterProfile] {
    viewModel.characters + customRecords.filter { $0.originRawValue == "custom" }.map(\.profile)
  }

  private var filteredCharacters: [CharacterProfile] {
    let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    return allCharacters.filter {
      query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
        || $0.tagline.localizedCaseInsensitiveContains(query)
        || $0.biography.localizedCaseInsensitiveContains(query)
    }
  }

  private var columns: [GridItem] {
    if dynamicTypeSize.isAccessibilitySize {
      return [GridItem(.flexible())]
    }
    return [
      GridItem(.adaptive(minimum: 260, maximum: 520), spacing: NovaTheme.Spacing.cardGap)
    ]
  }

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: NovaTheme.Spacing.sectionGap) {
        NovaPrimaryButton("Create Companion", systemImage: "person.crop.circle.badge.plus") {
          showsCreator = true
        }
        .accessibilityIdentifier("discover.createCharacter")
        .accessibilityHint("Opens the companion creator")
        if filteredCharacters.isEmpty && !viewModel.searchText.isEmpty {
          NovaEmptyState(
            title: "No Results for “\(viewModel.searchText)”",
            message: "Check the spelling or try a new search.",
            systemImage: "magnifyingglass", isEmbedded: true)
        } else {
          characterSection
        }
      }
      .padding(NovaTheme.Spacing.screenMargin)
    }
    .novaScreen()
    .novaNavigationTitle("Discover")
    .searchable(text: $viewModel.searchText, prompt: "Search characters")
    .fullScreenCover(
      isPresented: $showsCreator,
      onDismiss: {
        createdProfile = pendingCreatedProfile
        pendingCreatedProfile = nil
      }
    ) {
      CharacterCreatorView { profile in
        pendingCreatedProfile = profile
        showsCreator = false
      }
    }
    .navigationDestination(item: $createdProfile) { profile in
      CustomCompanionDetailView(characterID: profile.id)
    }
  }

  private var characterSection: some View {
    LazyVGrid(columns: columns, spacing: NovaTheme.Spacing.cardGap) {
      ForEach(filteredCharacters) { character in
        NavigationLink {
          CharacterDetailView(character: character, scenarios: viewModel.scenarios)
        } label: {
          CharacterCard(character: character)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("discover.characterCard")
      }
    }
  }
}
