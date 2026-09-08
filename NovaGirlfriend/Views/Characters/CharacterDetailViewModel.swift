import Combine
import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var isFavorite: Bool
    @Published var showsMore = false

    private let characterID: UUID
    private let defaults: UserDefaults
    private static let favoritesKey = "preferences.favoriteCharacterIDs"

    init(characterID: UUID, defaults: UserDefaults = .standard) {
        self.characterID = characterID
        self.defaults = defaults
        isFavorite = Set(defaults.stringArray(forKey: Self.favoritesKey) ?? []).contains(characterID.uuidString)
    }

    func toggleFavorite() {
        var favorites = Set(defaults.stringArray(forKey: Self.favoritesKey) ?? [])
        if favorites.contains(characterID.uuidString) {
            favorites.remove(characterID.uuidString)
            isFavorite = false
        } else {
            favorites.insert(characterID.uuidString)
            isFavorite = true
        }
        defaults.set(favorites.sorted(), forKey: Self.favoritesKey)
    }
}
