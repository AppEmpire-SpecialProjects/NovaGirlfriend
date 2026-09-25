import Combine
import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var isFavorite: Bool
    @Published var showsMore = false

    private let characterID: UUID
    private let favorites: FavoriteCharacterStore
    private var cancellable: AnyCancellable?

    init(characterID: UUID, favorites: FavoriteCharacterStore? = nil) {
        let favorites = favorites ?? .shared
        self.characterID = characterID
        self.favorites = favorites
        isFavorite = favorites.contains(characterID)
        cancellable = favorites.$ids
            .map { $0.contains(characterID) }
            .removeDuplicates()
            .sink { [weak self] in self?.isFavorite = $0 }
    }

    func toggleFavorite() {
        favorites.toggle(characterID)
    }
}
