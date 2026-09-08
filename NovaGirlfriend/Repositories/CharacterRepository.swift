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
    context.delete(record)
    try context.save()
    AvatarStorage.delete(reference: avatarReference)
  }
}
