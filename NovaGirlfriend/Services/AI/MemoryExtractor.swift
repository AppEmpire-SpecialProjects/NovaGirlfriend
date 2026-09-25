import Foundation

/// Extracts short factual notes about the user from recent conversation turns.
/// Notes stay on-device in `MemoryFactRecord` and are replayed into future
/// completion requests as remembered context.
@MainActor
struct MemoryExtractor {
  /// Facts are re-extracted after every completed turn so a mention in the
  /// first message already lands in Settings → Memory.
  static let extractionInterval = 1
  static let maximumFacts = 5
  static let maximumFactLength = 160
  static let reviewWindow = 40

  let ai: any AIServiceProtocol

  func extract(
    from messages: [ChatMessage], existing: [String], character: CharacterProfile
  ) async throws -> [String] {
    let transcript = messages
      .filter { ($0.role == .user || $0.role == .assistant) && !$0.text.isEmpty }
      .suffix(Self.reviewWindow)
      .map { message in
        (message.role == .user ? "User: " : "Companion: ") + message.text
      }
      .joined(separator: "\n")
    let knownList = existing.isEmpty
      ? "- (none)" : existing.map { "- \($0)" }.joined(separator: "\n")
    let instruction = """
      Review the conversation below and list new facts about the user that their companion should remember.
      Rules:
      - One fact per line, each line starting with "- ".
      - Only facts the user explicitly stated or directly implied. Never invent details.
      - Only facts about the user, never about the companion.
      - Each fact is a single line of at most \(Self.maximumFactLength) characters, in the conversation's language.
      - Do not repeat the known facts listed below.
      - If there is nothing new worth remembering, reply with exactly: NONE

      Known facts:
      \(knownList)

      Conversation:
      \(transcript)
      """
    let request = AICompletionRequest(
      messages: [
        ChatMessage(
          id: UUID(), conversationID: UUID(), role: .user,
          text: instruction, createdAt: .now, deliveryState: .sent)
      ],
      character: character, scenario: nil, includesPersona: false)
    let response = try await ai.complete(request)
    return Self.parse(response.text, existing: existing)
  }

  /// Normalizes extraction output into at most `maximumFacts` unique facts.
  static func parse(_ raw: String, existing: [String]) -> [String] {
    let known = Set(existing.map(normalize))
    var seen = Set<String>()
    var results: [String] = []
    for line in raw.split(separator: "\n") {
      var candidate = line.trimmingCharacters(in: .whitespacesAndNewlines)
      // The extraction prompt asks for bulleted facts; prose lines are ignored.
      guard let first = candidate.first, ["-", "•", "*", "·"].contains(first) else {
        continue
      }
      candidate = String(candidate.dropFirst())
      candidate = candidate.trimmingCharacters(in: .whitespaces)
      guard !candidate.isEmpty, candidate.uppercased() != "NONE",
        candidate.count <= maximumFactLength
      else { continue }
      let key = normalize(candidate)
      guard !known.contains(key), !seen.contains(key) else { continue }
      seen.insert(key)
      results.append(candidate)
      if results.count == maximumFacts { break }
    }
    return Array(results.prefix(maximumFacts))
  }

  static func normalize(_ text: String) -> String {
    text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
