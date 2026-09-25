import Foundation
import SwiftData

@MainActor
protocol CharacterRepositoryProtocol {
  func allCharacters() throws -> [CharacterProfile]
  func customCharacters() throws -> [CharacterProfile]
  func saveCustom(_ profile: CharacterProfile) throws
  func deleteCustom(id: UUID) throws
}

@MainActor
final class SwiftDataCharacterRepository: CharacterRepositoryProtocol {
  private let context: ModelContext
  private let productContent: any ProductContentProviding

  init(context: ModelContext, productContent: (any ProductContentProviding)? = nil) {
    self.context = context
    self.productContent = productContent ?? ProductContentRepository()
  }

  func allCharacters() throws -> [CharacterProfile] {
    productContent.characters + (try customCharacters())
  }

  func customCharacters() throws -> [CharacterProfile] {
    let descriptor = FetchDescriptor<CharacterRecord>(
      predicate: #Predicate { $0.originRawValue == "custom" },
      sortBy: [SortDescriptor(\CharacterRecord.createdAt)]
    )
    return try context.fetch(descriptor).map(\.profile)
  }

  func saveCustom(_ profile: CharacterProfile) throws {
    let id = profile.id
    let descriptor = FetchDescriptor<CharacterRecord>(predicate: #Predicate { $0.id == id })
    if let existing = try context.fetch(descriptor).first {
      existing.update(with: profile)
    } else {
      try AccessPolicy.shared.requireCompanionCreation(existingCount: customCharacters().count)
      var customProfile = profile
      customProfile.origin = .custom
      context.insert(CharacterRecord(profile: customProfile))
    }
    try context.save()
  }

  func deleteCustom(id: UUID) throws {
    let descriptor = FetchDescriptor<CharacterRecord>(predicate: #Predicate { $0.id == id })
    guard let record = try context.fetch(descriptor).first,
      record.originRawValue == CharacterOrigin.custom.rawValue
    else { return }
    let avatarReference = record.avatarAssetName

    // Conversations can't be opened without their companion, so they go too.
    let conversations = try context.fetch(
      FetchDescriptor<ConversationRecord>(predicate: #Predicate { $0.characterID == id }))
    let messages = conversations.flatMap(\.messages)
    let recordings = messages.compactMap(\.audioFileName)
    let photos = messages.compactMap(\.photoFileName)
    for conversation in conversations { context.delete(conversation) }
    for affinity in try context.fetch(
      FetchDescriptor<AffinityRecord>(predicate: #Predicate { $0.characterID == id }))
    {
      context.delete(affinity)
    }
    for item in try context.fetch(
      FetchDescriptor<GalleryItemRecord>(predicate: #Predicate { $0.characterID == id }))
    {
      context.delete(item)
    }
    context.delete(record)
    try context.save()

    for file in recordings { try? RecordingController.remove(file) }
    for file in photos { ChatPhotoStore.remove(file) }
    AvatarStorage.delete(reference: avatarReference)
    FavoriteCharacterStore.shared.remove(id)
  }
}
