import Foundation
import SwiftData

@Model
final class GalleryItemRecord {
  @Attribute(.unique) var id: UUID
  var characterID: UUID?
  var kindRawValue: String
  var localIdentifier: String
  var caption: String?
  var createdAt: Date
  var definitionID: String?
  // Existing records were explicit saves, already available to their owner.
  var isUnlocked: Bool = true
  var isSaved: Bool = true
  var unlockedAt: Date?

  init(item: GalleryItem) {
    id = item.id
    characterID = item.characterID
    kindRawValue = item.kind.rawValue
    localIdentifier = item.localIdentifier
    caption = item.caption
    createdAt = item.createdAt
    definitionID = item.definitionID
    isUnlocked = item.isUnlocked ?? true
    isSaved = item.isSaved ?? true
    unlockedAt = item.unlockedAt
  }
}

@Model
final class VoiceProfileRecord {
  @Attribute(.unique) var id: String
  var displayName: String
  var localeIdentifier: String
  var providerIdentifier: String?
  var speakingRate: Double
  var pitch: Double

  init(profile: VoiceProfile) {
    id = profile.id
    displayName = profile.displayName
    localeIdentifier = profile.localeIdentifier
    providerIdentifier = profile.providerIdentifier
    speakingRate = profile.speakingRate
    pitch = profile.pitch
  }
}
