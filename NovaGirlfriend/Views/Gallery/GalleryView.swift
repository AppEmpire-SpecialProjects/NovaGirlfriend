import SwiftData
import SwiftUI

struct GalleryView: View {
  var body: some View {
    GalleryCollectionView()
  }
}

struct CharacterGalleryView: View {
  let character: CharacterProfile

  var body: some View {
    GalleryCollectionView(initialCharacterID: character.id)
  }
}

private struct GalleryCollectionView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.launchChat) private var launchChat
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
  @AppStorage("preferences.reduceMotion") private var prefersReducedMotion = false
  @Query(sort: \CharacterRecord.createdAt) private var customCharacters: [CharacterRecord]
  @Query(sort: \GalleryItemRecord.createdAt) private var records: [GalleryItemRecord]
  @Query(sort: \MessageRecord.createdAt) private var messages: [MessageRecord]
  @ObservedObject private var favorites = FavoriteCharacterStore.shared
  @State private var selectedID: UUID?
  @State private var filter: GalleryFilter = .all
  @State private var viewerItem: GalleryDisplayItem?
  @State private var lockedItem: GalleryDisplayItem?
  @State private var chatAfterDismiss: CharacterProfile?
  @State private var exchanges: [UUID: Int] = [:]
  @State private var error: String?
  private let isCharacterScoped: Bool
  private var motion: GalleryMotion {
    GalleryMotion(systemReduceMotion: systemReduceMotion, appReduceMotion: prefersReducedMotion)
  }

  init(initialCharacterID: UUID? = nil) {
    _selectedID = State(initialValue: initialCharacterID)
    isCharacterScoped = initialCharacterID != nil
  }

  /// Companions favorited in Discover come first, so the gallery opens on them.
  private var characters: [CharacterProfile] {
    let all =
      ProductContentRepository().characters
      + customCharacters.filter { $0.originRawValue == "custom" }.map(\.profile)
    return all.filter { favorites.contains($0.id) } + all.filter { !favorites.contains($0.id) }
  }

  private var character: CharacterProfile? {
    characters.first { $0.id == selectedID } ?? characters.first
  }

  private var activityRevision: [String] {
    messages.map {
      "\($0.id)|\($0.roleRawValue)|\($0.deliveryStateRawValue)|\($0.text)|\($0.conversation?.id.uuidString ?? "")"
    }
  }

  var body: some View {
    ScrollView {
      if let character {
        let entries = GalleryViewModel().entries(for: character, records: records)
        VStack(alignment: .leading, spacing: 24) {
          GalleryCompanionSelector(
            characters: characters, favoriteIDs: favorites.ids, selectedID: character.id
          ) { id in
            selectedID = id
          }
          GalleryCollectionSummary(
            character: character, unlocked: entries.filter(\.isUnlocked).count,
            total: entries.count
          )
          .padding(.horizontal, 16)
          GalleryFilterChips(selection: $filter)
          collection(entries)
            .id("\(character.id)-\(filter.rawValue)")
            .transition(.opacity)
            .padding(.horizontal, 16)
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
        .animation(motion.animation(.easeInOut(duration: 0.18)), value: character.id)
        .animation(motion.animation(.easeInOut(duration: 0.18)), value: filter)
        .animation(
          motion.animation(.easeInOut(duration: 0.22)), value: entries.map(\.isUnlocked))
      }
    }
    .accessibilityHidden(viewerItem != nil)
    .novaScreen()
    .novaNavigationTitle(
      isCharacterScoped ? "\(character?.name ?? "Companion")'s Gallery" : "Gallery"
    )
    .task(id: activityRevision) { reconcile() }
    .onAppear { reconcile() }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active { reconcile() }
    }
    .fullScreenCover(item: $viewerItem) { item in
      GalleryViewer(item: item)
    }
    .sheet(item: $lockedItem, onDismiss: openPendingChat) { item in
      GalleryLockedMomentSheet(item: item, exchanges: exchanges[item.character.id, default: 0]) {
        chatAfterDismiss = item.character
        lockedItem = nil
      }
    }
    .alert("Gallery couldn’t be updated", isPresented: errorPresented) {
      Button("Retry") { reconcile() }
      Button("Not Now", role: .cancel) {}
    } message: {
      Text(error ?? "Your moments have not been changed.")
    }
    .transaction { transaction in
      motion.apply(to: &transaction)
    }
  }

  @ViewBuilder
  private func collection(_ entries: [GalleryDisplayItem]) -> some View {
    let visible = entries.filter { filter.includes(isUnlocked: $0.isUnlocked, isSaved: $0.isSaved) }
    if visible.isEmpty {
      GalleryEmptyState(filter: filter, hasContent: !entries.isEmpty)
    } else {
      LazyVGrid(
        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
        spacing: 12
      ) {
        ForEach(visible) { item in
          GalleryTile(item: item) {
            if item.isLocked {
              lockedItem = item
            } else {
              viewerItem = item
            }
          } save: {
            do {
              let repository = SwiftDataGalleryRepository(context: context)
              try repository.reconcile()
              try repository.setSaved(!item.isSaved, id: item.id)
            } catch {
              self.error = error.localizedDescription
            }
          }
        }
      }
      .accessibilityIdentifier("gallery.grid")
    }
  }

  private var errorPresented: Binding<Bool> {
    Binding(get: { error != nil }, set: { if !$0 { error = nil } })
  }

  private func reconcile() {
    do {
      exchanges = try SwiftDataGalleryRepository(context: context).reconcile()
      let unlockedMoments = records.filter(\.isUnlocked).count
      _ = try AchievementStore(context: context)
        .record(kind: .galleryMoments, value: unlockedMoments)
    } catch {
      self.error = error.localizedDescription
    }
  }

  private func openPendingChat() {
    guard let character = chatAfterDismiss else { return }
    chatAfterDismiss = nil
    launchChat(ChatLaunchContext(character: character, scenario: nil))
  }
}

private struct GalleryEmptyState: View {
  let filter: GalleryFilter
  let hasContent: Bool

  private var copy: (title: String, message: String, symbol: String) {
    if !hasContent && filter == .all {
      return (
        "No Moments Yet",
        "There aren’t any gallery moments available for this companion yet.",
        "photo.on.rectangle.angled"
      )
    }
    switch filter {
    case .all:
      return ("No Moments Yet", "New moments will appear here when they become available.", "photo")
    case .unlocked:
      return (
        "No Moments Unlocked", "Spend more time with this companion to discover new moments.",
        "lock.open"
      )
    case .locked:
      return (
        "Everything Unlocked", "You’ve discovered every available moment with this companion.",
        "checkmark.circle"
      )
    case .saved:
      return (
        "No Saved Moments", "Save your favorite companion moments and they’ll appear here.", "heart"
      )
    }
  }

  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: copy.symbol)
        .font(.title)
        .foregroundStyle(NovaTheme.inactiveIcon)
        .accessibilityHidden(true)
      Text(copy.title)
        .font(.headline)
      Text(copy.message)
        .font(.subheadline)
        .foregroundStyle(NovaTheme.textSecondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 36)
    .padding(.horizontal, 12)
  }
}
