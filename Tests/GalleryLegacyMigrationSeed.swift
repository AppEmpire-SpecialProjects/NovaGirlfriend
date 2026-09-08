import Foundation
import SwiftData

// Test-only snapshot of the actual pre-extension entities, not renamed substitute models.
// Source: staged NovaGirlfriend/Persistence/MediaRecords.swift, blob
// cb1fee78f9c67e7430cb727e028e499b40314967. Both executables use the same module name.
@Model
final class GalleryItemRecord {
  @Attribute(.unique) var id: UUID
  var characterID: UUID?
  var kindRawValue: String
  var localIdentifier: String
  var caption: String?
  var createdAt: Date

  init(item: GalleryItem) {
    id = item.id
    characterID = item.characterID
    kindRawValue = item.kind.rawValue
    localIdentifier = item.localIdentifier
    caption = item.caption
    createdAt = item.createdAt
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

// Source: staged Models/GalleryModels.swift, blob 12a62f032b59c8cb9800b8ef32ee7686583116ab.
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
}

@main
@MainActor
struct GalleryLegacyMigrationSeed {
  static func main() throws {
    guard CommandLine.arguments.count == 2 else {
      print("Usage: gallery-legacy-seed <new-store-path>")
      exit(2)
    }
    let url = URL(fileURLWithPath: CommandLine.arguments[1])
    guard !FileManager.default.fileExists(atPath: url.path) else {
      print("Refusing to seed an existing store: \(url.path)")
      exit(2)
    }
    let container = try ModelContainer(
      for: GalleryItemRecord.self, VoiceProfileRecord.self,
      ConversationRecord.self, MessageRecord.self,
      configurations: ModelConfiguration(url: url))
    let context = container.mainContext
    context.autosaveEnabled = false
    let characterID = UUID(uuidString: "A1000000-0000-0000-0000-000000000001")!
    let date = Date(timeIntervalSince1970: 1_700_000_000)
    let image = GalleryItem(
      id: UUID(uuidString: "C3000000-0000-0000-0000-000000000001")!,
      characterID: characterID, kind: .image, localIdentifier: "legacy-photo.jpg",
      caption: "Existing photo", createdAt: date)
    let audio = GalleryItem(
      id: UUID(uuidString: "C3000000-0000-0000-0000-000000000002")!,
      characterID: nil, kind: .audio, localIdentifier: "legacy-note.m4a",
      caption: nil, createdAt: date)
    context.insert(GalleryItemRecord(item: image))
    context.insert(GalleryItemRecord(item: audio))
    context.insert(
      VoiceProfileRecord(
        profile: VoiceProfile(
          id: "legacy-voice", displayName: "Legacy voice", localeIdentifier: "en-US",
          providerIdentifier: "legacy-provider", speakingRate: 0.5, pitch: 1.25)))
    let chat = ConversationRecord(
      characterID: characterID, title: "Legacy conversation", createdAt: date, updatedAt: date)
    context.insert(chat)
    let user = MessageRecord(
      role: .user, text: "Legacy question", createdAt: date, deliveryState: .sent)
    let assistant = MessageRecord(
      role: .assistant, text: "Legacy answer", createdAt: date.addingTimeInterval(1),
      deliveryState: .sent)
    context.insert(user)
    context.insert(assistant)
    chat.messages.append(contentsOf: [user, assistant])
    try context.save()
    guard try context.fetchCount(FetchDescriptor<GalleryItemRecord>()) == 2,
      try context.fetchCount(FetchDescriptor<VoiceProfileRecord>()) == 1,
      try context.fetchCount(FetchDescriptor<MessageRecord>()) == 2
    else {
      print("FAIL: old-schema seed did not persist expected records")
      exit(1)
    }
    print(
      "PASS: actual old GalleryItemRecord schema seeded two media records, one voice and one chat")
  }
}
