import Foundation

enum GalleryMediaKind: String, Codable, Sendable {
  case image
  case audio
}

struct GalleryItem: Identifiable, Codable, Hashable, Sendable {
  let id: UUID
  let characterID: UUID?
  let kind: GalleryMediaKind
  let localIdentifier: String
  let caption: String?
  let createdAt: Date
  // Optional additions keep older gallery exports decodable.
  var definitionID: String? = nil
  var isUnlocked: Bool? = nil
  var isSaved: Bool? = nil
  var unlockedAt: Date? = nil
}

enum GalleryUnlockRule: Hashable, Sendable {
  case initial
  case exchanges(Int)

  var requiredExchanges: Int {
    switch self {
    case .initial: 0
    case .exchanges(let count): count
    }
  }

  var requirement: String {
    switch self {
    case .initial: "Included in your collection"
    case .exchanges(let count): "\(count) chat exchanges"
    }
  }
}

struct GalleryMomentDefinition: Identifiable, Hashable, Sendable {
  let id: UUID
  let characterID: UUID
  let title: String
  let imageAsset: String
  let unlockRule: GalleryUnlockRule
}

enum GalleryFilter: String, CaseIterable, Identifiable {
  case all = "All"
  case unlocked = "Unlocked"
  case locked = "Locked"
  case saved = "Saved"

  var id: String { rawValue }

  func includes(isUnlocked: Bool, isSaved: Bool) -> Bool {
    switch self {
    case .all: true
    case .unlocked: isUnlocked
    case .locked: !isUnlocked
    case .saved: isUnlocked && isSaved
    }
  }
}
