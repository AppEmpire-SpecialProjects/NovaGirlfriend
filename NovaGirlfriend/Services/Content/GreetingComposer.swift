import Foundation

/// Composes the companion's opening message for a fresh conversation.
/// Deterministic, on-device, and derived only from the character profile and
/// scenario so previews and first opens feel alive without an AI round trip.
enum GreetingComposer {
  static func greeting(for character: CharacterProfile, scenario: Scenario?) -> String {
    let opener = opener(for: character)
    guard let scenario, !scenario.title.isEmpty else {
      return "\(opener) It's good to see you here. What's on your mind?"
    }
    return "\(opener) I was just thinking about \(scenario.title.lowercased()) — \(character.name) at your service. Where should we start?"
  }

  private static func opener(for character: CharacterProfile) -> String {
    let personality = character.personality
    let options: [String]
    switch (personality.warmth, personality.humor, personality.curiosity, personality.confidence) {
    case (90..., _, _, _):
      options = ["Hey you.", "There you are.", "I hoped you'd come by."]
    case (_, 90..., _, _):
      options = ["Well, look who showed up.", "Perfect timing, as always.", "Finally! I was getting bored."]
    case (_, _, 90..., _):
      options = ["Oh, hi!", "You're just in time.", "I have so many questions."]
    case (_, _, _, 90...):
      options = ["There you are.", "Right on schedule.", "I had a feeling you'd stop by."]
    default:
      options = ["Hey.", "Hi, it's you.", "Hello again."]
    }
    return options[stableIndex(for: character.id, count: options.count)]
  }

  /// Stable across launches: UUID hash values are seeded per process.
  private static func stableIndex(for id: UUID, count: Int) -> Int {
    let scalars = id.uuidString.unicodeScalars
    let sum = scalars.reduce(0) { $0 + Int($1.value) }
    return sum % count
  }
}
