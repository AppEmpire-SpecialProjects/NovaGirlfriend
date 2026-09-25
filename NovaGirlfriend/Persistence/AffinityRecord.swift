import Foundation
import SwiftData

@Model
final class AffinityRecord {
  @Attribute(.unique) var characterID: UUID
  var points: Int
  var updatedAt: Date

  init(characterID: UUID, points: Int = 0, updatedAt: Date = .now) {
    self.characterID = characterID
    self.points = points
    self.updatedAt = updatedAt
  }
}
