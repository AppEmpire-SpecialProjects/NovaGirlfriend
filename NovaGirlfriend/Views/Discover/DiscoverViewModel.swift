import Combine
import Foundation

@MainActor
final class DiscoverViewModel: ObservableObject {
  @Published var searchText = ""

  let characters: [CharacterProfile]
  let scenarios: [Scenario]

  init(content: (any ProductContentProviding)? = nil) {
    let content = content ?? ProductContentRepository()
    characters = content.characters
    scenarios = content.scenarios
  }

  var filteredCharacters: [CharacterProfile] {
    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { return characters }
    return characters.filter {
      $0.name.localizedCaseInsensitiveContains(query)
        || $0.tagline.localizedCaseInsensitiveContains(query)
        || $0.biography.localizedCaseInsensitiveContains(query)
    }
  }
}
