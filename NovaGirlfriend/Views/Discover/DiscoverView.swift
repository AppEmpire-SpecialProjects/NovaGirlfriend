import SwiftData
import SwiftUI

struct DiscoverView: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @StateObject private var viewModel = DiscoverViewModel()
  @ObservedObject private var favorites = FavoriteCharacterStore.shared
  @State private var filter: DiscoverFilter = .all
  @State private var pendingDelete: CharacterProfile?
  @State private var deleteError: String?
  @Environment(\.modelContext) private var modelContext
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
      filter.includes($0, isFavorite: favorites.contains($0.id))
        && (query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
          || $0.tagline.localizedCaseInsensitiveContains(query)
          || $0.biography.localizedCaseInsensitiveContains(query))
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
        DiscoverFilterChips(selection: $filter)
        if filteredCharacters.isEmpty && !viewModel.searchText.isEmpty {
          NovaEmptyState(
            title: "No Results for “\(viewModel.searchText)”",
            message: "Check the spelling or try a new search.",
            systemImage: "magnifyingglass", isEmbedded: true)
        } else if filteredCharacters.isEmpty {
          filterEmptyState
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
    .confirmationDialog(
      "Delete \(pendingDelete?.name ?? "companion")?",
      isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
      titleVisibility: .visible
    ) {
      Button("Delete Companion", role: .destructive, action: deletePendingCompanion)
    } message: {
      Text("This removes the companion, its conversations and saved moments. This cannot be undone.")
    }
    .alert(
      "Couldn’t Complete Action",
      isPresented: Binding(get: { deleteError != nil }, set: { if !$0 { deleteError = nil } })
    ) {
      Button("OK") { deleteError = nil }
    } message: {
      Text(deleteError ?? "")
    }
  }

  private func deletePendingCompanion() {
    guard let profile = pendingDelete else { return }
    pendingDelete = nil
    do {
      try SwiftDataCharacterRepository(context: modelContext).deleteCustom(id: profile.id)
    } catch {
      deleteError = error.localizedDescription
    }
  }

  private var characterSection: some View {
    LazyVGrid(columns: columns, spacing: NovaTheme.Spacing.cardGap) {
      ForEach(filteredCharacters) { character in
        NavigationLink {
          CharacterDetailView(character: character, scenarios: viewModel.scenarios)
        } label: {
          CharacterCard(character: character, isFavorite: favorites.contains(character.id))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("discover.characterCard")
        .contextMenu {
          if character.origin == .custom {
            Button("Delete Companion", systemImage: "trash", role: .destructive) {
              pendingDelete = character
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  private var filterEmptyState: some View {
    switch filter {
    case .all:
      EmptyView()
    case .favorites:
      NovaEmptyState(
        title: "No Favorites Yet",
        message: "Tap the heart on a companion’s profile to keep them here.",
        systemImage: "heart", isEmbedded: true)
    case .custom:
      NovaEmptyState(
        title: "No Custom Companions",
        message: "Create a companion with your own identity, personality, appearance, and voice.",
        systemImage: "person.crop.circle.badge.plus", isEmbedded: true)
    }
  }
}

enum DiscoverFilter: String, CaseIterable, Identifiable {
  case all
  case favorites
  case custom

  var id: String { rawValue }

  var title: LocalizedStringKey {
    switch self {
    case .all: "All"
    case .favorites: "Favorites"
    case .custom: "My Companions"
    }
  }

  func includes(_ character: CharacterProfile, isFavorite: Bool) -> Bool {
    switch self {
    case .all: true
    case .favorites: isFavorite
    case .custom: character.origin == .custom
    }
  }
}

private struct DiscoverFilterChips: View {
  @Binding var selection: DiscoverFilter

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(DiscoverFilter.allCases) { filter in
          let selected = selection == filter
          Button {
            selection = filter
          } label: {
            Text(filter.title)
              .font(.subheadline.weight(.semibold))
              .padding(.horizontal, 18)
              .frame(minHeight: 44)
              .foregroundStyle(selected ? NovaTheme.background : NovaTheme.textSecondary)
              .background(selected ? NovaTheme.primary : NovaTheme.surface, in: Capsule())
              .overlay {
                Capsule().strokeBorder(selected ? .clear : NovaTheme.border, lineWidth: 1)
              }
          }
          .buttonStyle(.plain)
          .accessibilityAddTraits(selected ? .isSelected : [])
          .accessibilityIdentifier("discover.filter.\(filter.rawValue)")
        }
      }
    }
    .scrollClipDisabled()
    .accessibilityIdentifier("discover.filters")
  }
}
