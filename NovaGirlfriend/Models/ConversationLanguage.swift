import Foundation

struct ConversationLanguage: Identifiable, Hashable, Sendable {
  let code: String
  let title: String
  var id: String { code }
}

enum ConversationLanguages {
  /// "" means: follow the user's own language.
  static let supported: [ConversationLanguage] = [
    ConversationLanguage(code: "en", title: "English"),
    ConversationLanguage(code: "es", title: "Español"),
    ConversationLanguage(code: "fr", title: "Français"),
    ConversationLanguage(code: "de", title: "Deutsch"),
    ConversationLanguage(code: "pt", title: "Português"),
    ConversationLanguage(code: "it", title: "Italiano"),
    ConversationLanguage(code: "ru", title: "Русский"),
    ConversationLanguage(code: "uk", title: "Українська"),
    ConversationLanguage(code: "tr", title: "Türkçe"),
    ConversationLanguage(code: "ja", title: "日本語"),
    ConversationLanguage(code: "ko", title: "한국어"),
    ConversationLanguage(code: "zh-Hans", title: "简体中文"),
  ]

  static func title(forCode code: String) -> String? {
    supported.first { $0.code == code }?.title
  }

  /// Instruction appended to completion requests. A fixed code pins the
  /// reply language. The auto mode ("" or unset) first tries to pin the
  /// language detected from the user's latest message script (Cyrillic →
  /// Russian/Ukrainian, kana → Japanese, …) and otherwise instructs the model
  /// to detect and mirror the user's language itself. The rule is written as
  /// a top-priority override because the persona, the greeting and earlier
  /// replies are English and otherwise drag weak models back to English.
  static func instruction(forCode code: String, mirroring userText: String? = nil) -> String? {
    if let target = title(forCode: code) ?? autoTitle(mirroring: userText) {
      return
        "LANGUAGE RULE — TOP PRIORITY: Write every sentence of your reply in "
        + "\(target) only. This overrides the language of these instructions, of the "
        + "persona, and of earlier messages. Never mix in another language."
    }
    return
      "LANGUAGE RULE — TOP PRIORITY: Detect the language of the user's latest "
      + "message and write your whole reply in that language, even if these "
      + "instructions, the persona, or your own earlier replies are in English. "
      + "Never answer in a different language."
  }

  /// Best-effort language for the auto mode from the script of the user's
  /// message. Latin-script languages stay unpinned: guessing between
  /// English, Spanish, Portuguese and the rest would misfire more than help.
  private static func autoTitle(mirroring userText: String?) -> String? {
    guard let text = userText, !text.isEmpty else { return nil }
    func containsScalars(_ range: ClosedRange<UInt32>) -> Bool {
      text.unicodeScalars.contains { range.contains($0.value) }
    }
    if containsScalars(0x0400...0x04FF) {
      let ukrainianOnly = ["і", "ї", "є", "ґ"].flatMap { $0.unicodeScalars }
      return text.unicodeScalars.contains { ukrainianOnly.contains($0) } ? "Ukrainian" : "Russian"
    }
    if containsScalars(0x3040...0x30FF) { return "Japanese" }
    if containsScalars(0xAC00...0xD7AF) || containsScalars(0x1100...0x11FF) {
      return "Korean"
    }
    if containsScalars(0x4E00...0x9FFF) { return "Simplified Chinese" }
    if containsScalars(0x0600...0x06FF) { return "Arabic" }
    if containsScalars(0x0590...0x05FF) { return "Hebrew" }
    if containsScalars(0x0900...0x097F) { return "Hindi" }
    if containsScalars(0x0E00...0x0E7F) { return "Thai" }
    return nil
  }
}
