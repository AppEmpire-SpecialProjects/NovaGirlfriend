import Foundation
import SwiftData

@Model
final class AchievementRecord {
  @Attribute(.unique) var definitionID: String
  var kindRawValue: String
  var tier: Int
  var unlockedAt: Date

  init(definition: AchievementDefinition, unlockedAt: Date = .now) {
    definitionID = definition.id
    kindRawValue = definition.kind.rawValue
    tier = definition.tier
    self.unlockedAt = unlockedAt
  }
}

@Model
final class UserStreakRecord {
  @Attribute(.unique) var id: String
  var currentStreak: Int
  var longestStreak: Int
  var lastVisitDay: String
  var updatedAt: Date

  init(
    id: String = "primary",
    currentStreak: Int = 0,
    longestStreak: Int = 0,
    lastVisitDay: String = "",
    updatedAt: Date = .now
  ) {
    self.id = id
    self.currentStreak = currentStreak
    self.longestStreak = longestStreak
    self.lastVisitDay = lastVisitDay
    self.updatedAt = updatedAt
  }
}
