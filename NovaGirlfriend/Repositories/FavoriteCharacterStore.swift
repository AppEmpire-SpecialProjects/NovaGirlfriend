import Combine
import Foundation

/// Shared, observable set of favorite character IDs so every screen
/// (profile heart, Discover filter, card badge) stays in sync.
@MainActor
final class FavoriteCharacterStore: ObservableObject {
  static let shared = FavoriteCharacterStore()
  static let key = "preferences.favoriteCharacterIDs"

  @Published private(set) var ids: Set<UUID>
  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    ids = Set((defaults.stringArray(forKey: Self.key) ?? []).compactMap(UUID.init(uuidString:)))
  }

  func contains(_ id: UUID) -> Bool { ids.contains(id) }

  func toggle(_ id: UUID) {
    if ids.contains(id) {
      ids.remove(id)
    } else {
      ids.insert(id)
    }
    persist()
  }

  func remove(_ id: UUID) {
    guard ids.remove(id) != nil else { return }
    persist()
  }

  private func persist() {
    defaults.set(ids.map(\.uuidString).sorted(), forKey: Self.key)
  }
}
