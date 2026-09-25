import Foundation

/// Splits text into speakable chunks that respect the remote synthesis
/// length limit. Words are kept intact; only oversized tokens are split by
/// characters.
enum TextChunker {
  /// Maximum text length accepted per synthesis request.
  static let speechLimit = 500

  static func chunks(from text: String, limit: Int = speechLimit) -> [String] {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, limit > 0 else { return [] }
    var chunks: [String] = []
    var current = ""
    func flush() {
      if !current.isEmpty { chunks.append(current) }
      current = ""
    }
    for token in trimmed.split(whereSeparator: { $0.isWhitespace }) {
      for piece in Self.split(oversized: String(token), limit: limit) {
        if current.isEmpty {
          current = piece
        } else if current.count + piece.count + 1 <= limit {
          current += " " + piece
        } else {
          flush()
          current = piece
        }
      }
    }
    flush()
    return chunks
  }

  /// Splits a single token whose length exceeds `limit` into equal-sized
  /// pieces that each fit.
  private static func split(oversized token: String, limit: Int) -> [String] {
    guard token.count > limit else { return [token] }
    var pieces: [String] = []
    var remaining = Substring(token)
    while remaining.count > limit {
      pieces.append(String(remaining.prefix(limit)))
      remaining = remaining.dropFirst(limit)
    }
    if !remaining.isEmpty { pieces.append(String(remaining)) }
    return pieces
  }
}
