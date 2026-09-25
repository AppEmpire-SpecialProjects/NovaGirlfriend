import Foundation

enum AchievementKind: String, Codable, CaseIterable, Sendable {
  case exchanges
  case customCompanions
  case galleryMoments
  case streakDays
  case boundCompanions

  var title: String {
    switch self {
    case .exchanges: "Conversations"
    case .customCompanions: "Creator"
    case .galleryMoments: "Collector"
    case .streakDays: "Devotion"
    case .boundCompanions: "Bonds"
    }
  }
}

struct AchievementDefinition: Identifiable, Hashable, Sendable {
  let kind: AchievementKind
  let tier: Int
  let title: String
  let detail: String

  var id: String { "\(kind.rawValue)-\(tier)" }

  var subtitle: String { detail }

  var symbolName: String {
    switch kind {
    case .exchanges: "bubble.left.and.bubble.right.fill"
    case .customCompanions: "person.crop.circle.badge.plus"
    case .galleryMoments: "photo.on.rectangle.angled"
    case .streakDays: "flame.fill"
    case .boundCompanions: "heart.fill"
    }
  }
}

enum AchievementCatalog {
  static let all: [AchievementDefinition] =
    definitions(.exchanges)
      + definitions(.customCompanions)
      + definitions(.galleryMoments)
      + definitions(.streakDays)
      + definitions(.boundCompanions)

  static func definitions(_ kind: AchievementKind) -> [AchievementDefinition] {
    switch kind {
    case .exchanges:
      return [
        AchievementDefinition(
          kind: .exchanges, tier: 1, title: "First Words",
          detail: "Complete your first exchange with a companion"),
        AchievementDefinition(
          kind: .exchanges, tier: 25, title: "Easy Talk",
          detail: "Complete 25 exchanges"),
        AchievementDefinition(
          kind: .exchanges, tier: 100, title: "Deep Conversations",
          detail: "Complete 100 exchanges"),
        AchievementDefinition(
          kind: .exchanges, tier: 500, title: "Soulmates",
          detail: "Complete 500 exchanges"),
      ]
    case .customCompanions:
      return [
        AchievementDefinition(
          kind: .customCompanions, tier: 1, title: "Made with Love",
          detail: "Create your first custom companion"),
        AchievementDefinition(
          kind: .customCompanions, tier: 5, title: "Matchmaker",
          detail: "Create 5 custom companions"),
      ]
    case .galleryMoments:
      return [
        AchievementDefinition(
          kind: .galleryMoments, tier: 4, title: "First Memories",
          detail: "Unlock 4 gallery moments"),
        AchievementDefinition(
          kind: .galleryMoments, tier: 16, title: "Memory Keeper",
          detail: "Unlock 16 gallery moments"),
      ]
    case .streakDays:
      return [
        AchievementDefinition(
          kind: .streakDays, tier: 3, title: "Three in a Row",
          detail: "Visit the app 3 days in a row"),
        AchievementDefinition(
          kind: .streakDays, tier: 7, title: "A Week of Us",
          detail: "Visit the app 7 days in a row"),
        AchievementDefinition(
          kind: .streakDays, tier: 30, title: "Every Single Day",
          detail: "Visit the app 30 days in a row"),
      ]
    case .boundCompanions:
      return [
        AchievementDefinition(
          kind: .boundCompanions, tier: 1, title: "Unbreakable",
          detail: "Reach the Bound stage with a companion"),
      ]
    }
  }
}
