import Foundation
import SwiftData

private struct CheckFailure: Error, CustomStringConvertible {
  let description: String
}

@main
@MainActor
struct GalleryDomainChecks {
  private static let initialDate = Date(timeIntervalSince1970: 1_700_000_000)
  private static let unlockDate = Date(timeIntervalSince1970: 1_700_001_000)
  private static let laterDate = Date(timeIntervalSince1970: 1_700_002_000)
  private static let characters = ProductContentRepository().characters
  private static let customID = UUID(uuidString: "B2000000-0000-0000-0000-000000000001")!

  static func main() {
    guard CommandLine.arguments.count == 3 else {
      print(
        "Usage: gallery-domain-checks <domain|restart-saved|restart-unsaved|migration> <store-prefix>"
      )
      exit(2)
    }
    let mode = CommandLine.arguments[1]
    let prefix = CommandLine.arguments[2]
    var failures = 0
    func run(_ label: String, _ body: () throws -> Void) {
      do {
        try body()
        print("PASS: \(label)")
      } catch {
        failures += 1
        print("FAIL: \(label): \(error)")
      }
    }
    switch mode {
    case "domain":
      run(
        "8 real character IDs; 16 unique, character-owned definitions; initial/5-exchange metadata"
      ) {
        try checkCatalog()
      }
      run("GalleryFilter truth table: All, Unlocked, Locked, Saved") {
        try checkFilters()
      }
      run("old GalleryItem JSON image/audio decode and round-trip without lost fields") {
        try checkLegacyJSON()
      }
      run(
        "persisted pairing, rejected activity, same-character aggregation, no character borrowing"
      ) {
        try checkActivity(url: storeURL(prefix, "activity"))
      }
      run("unsaved fifth exchange and unsaved delivery changes do not advance existing collections")
      {
        try checkUnsavedExisting(url: storeURL(prefix, "unsaved-existing"))
      }
      run("initial reconcile does not commit unsaved chat inserts or unlock on a second reconcile")
      {
        try checkUnsavedBootstrap(url: storeURL(prefix, "unsaved-bootstrap"), updateExisting: false)
      }
      run(
        "initial reconcile does not commit unsaved sent-state edits or unlock on a second reconcile"
      ) {
        try checkUnsavedBootstrap(url: storeURL(prefix, "unsaved-update"), updateExisting: true)
      }
      run(
        "4/5 boundary; initial not Saved; locked save rejected; timestamp/idempotency; legacy records"
      ) {
        try seedProgress(url: storeURL(prefix, "progress"))
      }
    case "restart-saved":
      run(
        "fresh process/container retains save and unlock date; deleting chat does not relock; unsave"
      ) {
        try restartSaved(url: storeURL(prefix, "progress"))
      }
    case "restart-unsaved":
      run("second fresh process retains unsave, monotonic unlocks, zero activity and legacy media")
      {
        try restartUnsaved(url: storeURL(prefix, "progress"))
      }
    case "migration":
      run("actual old same-name entity migrates defaults, media, voice and chat without data loss")
      {
        try checkMigration(url: URL(fileURLWithPath: prefix))
      }
    default:
      print("Unknown check mode: \(mode)")
      exit(2)
    }
    print("RESULT: \(mode): \(failures == 0 ? "PASS" : "FAIL") (\(failures) failing groups)")
    if failures > 0 { exit(1) }
  }

  private static func expect(
    _ condition: @autoclosure () throws -> Bool,
    _ message: String,
    file: StaticString = #fileID,
    line: UInt = #line
  ) throws {
    if try condition() == false {
      throw CheckFailure(description: "\(message) [\(file):\(line)]")
    }
  }

  private static func storeURL(_ prefix: String, _ name: String) -> URL {
    URL(fileURLWithPath: "\(prefix)-\(name).store")
  }

  private static func container(at url: URL) throws -> ModelContainer {
    let result = try ModelContainer(
      for: GalleryItemRecord.self, VoiceProfileRecord.self,
      ConversationRecord.self, MessageRecord.self,
      configurations: ModelConfiguration(url: url))
    result.mainContext.autosaveEnabled = false
    return result
  }

  private static func definition(
    characterID: UUID,
    rule: GalleryUnlockRule
  ) throws -> GalleryMomentDefinition {
    guard
      let result = GalleryCatalog.moments.first(where: {
        $0.characterID == characterID && $0.unlockRule == rule
      })
    else {
      throw CheckFailure(description: "Missing definition for \(characterID), \(rule)")
    }
    return result
  }

  private static func record(
    _ id: UUID,
    in repository: SwiftDataGalleryRepository
  ) throws -> GalleryItemRecord {
    guard let result = try repository.items().first(where: { $0.id == id }) else {
      throw CheckFailure(description: "Missing gallery record \(id)")
    }
    return result
  }

  private static func checkCatalog() throws {
    let realIDs = Set(characters.map(\.id))
    let definitions = GalleryCatalog.moments
    try expect(
      characters.count == 8 && realIDs.count == 8, "Expected eight distinct real companions")
    try expect(definitions.count == 16, "Expected sixteen definitions, got \(definitions.count)")
    try expect(Set(definitions.map(\.id)).count == 16, "Duplicate definition IDs")
    try expect(Set(definitions.map(\.characterID)) == realIDs, "Catalog IDs must match product IDs")
    try expect(
      Set(definitions.map(\.imageAsset)).count == 16,
      "Artwork must not be borrowed across characters")
    let artworkNames = ["Nova", "Maya", "Elena", "Sofia", "Aiko", "Luna", "Iris", "Yuki"]
    for (index, character) in characters.enumerated() {
      let owned = definitions.filter { $0.characterID == character.id }
      try expect(owned.count == 2, "\(character.name) must own two definitions")
      let portrait = try definition(characterID: character.id, rule: .initial)
      let original = try definition(characterID: character.id, rule: .exchanges(5))
      try expect(
        portrait.imageAsset == character.avatarAssetName, "Portrait belongs to wrong character")
      try expect(portrait.title == "\(character.name)'s portrait", "Portrait title mismatch")
      try expect(original.title == "Original Illustration", "Unexpected illustration title")
      try expect(
        original.imageAsset == "\(artworkNames[index])GalleryOriginal",
        "Illustration ownership mismatch"
      )
      try expect(portrait.unlockRule.requiredExchanges == 0, "Initial must require zero exchanges")
      try expect(original.unlockRule.requiredExchanges == 5, "Threshold must be five exchanges")
    }
    try expect(
      !definitions.contains { $0.characterID == customID }, "Custom character received borrowed art"
    )
  }

  private static func checkFilters() throws {
    try expect(GalleryFilter.allCases.count == 4, "Expected four filters")
    for unlocked in [false, true] {
      for saved in [false, true] {
        let expectations: [(GalleryFilter, Bool)] = [
          (.all, true), (.unlocked, unlocked), (.locked, !unlocked), (.saved, unlocked && saved),
        ]
        for (filter, expected) in expectations {
          try expect(
            filter.includes(isUnlocked: unlocked, isSaved: saved) == expected,
            "\(filter.rawValue) incorrect for unlocked=\(unlocked), saved=\(saved)")
        }
      }
    }
  }

  private static func checkLegacyJSON() throws {
    let oldJSON = """
      [
        {"id":"C3000000-0000-0000-0000-000000000001",
         "characterID":"A1000000-0000-0000-0000-000000000001", "kind":"image",
         "localIdentifier":"legacy-photo.jpg", "caption":"Existing photo", "createdAt":12345},
        {"id":"C3000000-0000-0000-0000-000000000002", "kind":"audio",
         "localIdentifier":"legacy-note.m4a", "createdAt":54321}
      ]
      """
    let decoded = try JSONDecoder().decode([GalleryItem].self, from: Data(oldJSON.utf8))
    try expect(decoded.count == 2, "Legacy decode lost records")
    try expect(decoded[0].kind == .image && decoded[1].kind == .audio, "Legacy media kind changed")
    try expect(decoded[0].characterID == characters[0].id, "Legacy character ID changed")
    try expect(
      decoded[1].characterID == nil && decoded[1].caption == nil, "Legacy nil fields changed")
    try expect(decoded[0].caption == "Existing photo", "Legacy caption changed")
    try expect(
      decoded[0].createdAt == Date(timeIntervalSinceReferenceDate: 12345), "Legacy date changed")
    for item in decoded {
      try expect(
        item.definitionID == nil && item.unlockedAt == nil,
        "Missing optional metadata must remain nil")
      try expect(
        item.isUnlocked == nil && item.isSaved == nil, "Old JSON must not invent explicit state")
      let record = GalleryItemRecord(item: item)
      try expect(
        record.isUnlocked && record.isSaved, "Legacy explicit saves must default to available/saved"
      )
      try expect(record.localIdentifier == item.localIdentifier, "Legacy media identifier changed")
    }
    let encoded = try JSONEncoder().encode(decoded)
    let roundTrip = try JSONDecoder().decode([GalleryItem].self, from: encoded)
    try expect(roundTrip == decoded, "Legacy round-trip lost fields")
  }

  private struct Entry {
    let role: MessageRole
    let text: String
    var delivery: MessageDeliveryState = .sent
    var audio: String? = nil
  }

  @discardableResult
  private static func conversation(
    in context: ModelContext,
    characterID: UUID,
    entries: [Entry],
    title: String = "Gallery check"
  ) -> ConversationRecord {
    let result = ConversationRecord(characterID: characterID, title: title, createdAt: initialDate)
    context.insert(result)
    for entry in entries {
      append(entry, to: result, in: context)
    }
    return result
  }

  private static func append(
    _ entry: Entry,
    to conversation: ConversationRecord,
    in context: ModelContext
  ) {
    let message = MessageRecord(
      role: entry.role, text: entry.text,
      createdAt: initialDate.addingTimeInterval(Double(conversation.messages.count)),
      deliveryState: entry.delivery, audioFileName: entry.audio)
    context.insert(message)
    conversation.messages.append(message)
  }

  private static func exchanges(_ count: Int) -> [Entry] {
    (0..<count).flatMap { index in
      [
        Entry(role: .user, text: "Question \(index)"),
        Entry(role: .assistant, text: "Reply \(index)"),
      ]
    }
  }

  private static func checkActivity(url: URL) throws {
    let container = try container(at: url)
    let context = container.mainContext
    let novaID = characters[0].id
    let user = Entry(role: .user, text: "Sent question")
    let assistant = Entry(role: .assistant, text: "Sent answer")
    let cases: [(String, [Entry], Int)] = [
      ("ordinary sent pair", [user, assistant], 1),
      ("assistant only", [assistant, assistant], 0),
      ("user only", [user], 0),
      ("assistant precedes user", [assistant, user], 0),
      ("reply consumed once", [user, assistant, assistant], 1),
      ("two users need actual replies", [user, user, assistant], 1),
      ("failed user", [.init(role: .user, text: "Question", delivery: .failed), assistant], 0),
      ("pending user", [.init(role: .user, text: "Question", delivery: .pending), assistant], 0),
      ("failed assistant", [user, .init(role: .assistant, text: "Answer", delivery: .failed)], 0),
      (
        "pending assistant", [user, .init(role: .assistant, text: "Answer", delivery: .pending)], 0
      ),
      ("blank user", [.init(role: .user, text: " \n\t "), assistant], 0),
      ("blank assistant", [user, .init(role: .assistant, text: " \n\t ")], 0),
      ("voice-only user", [.init(role: .user, text: "", audio: "voice.m4a"), assistant], 0),
      ("voice-only assistant", [user, .init(role: .assistant, text: "", audio: "reply.m4a")], 0),
      ("system is not a user", [.init(role: .system, text: "Context"), assistant], 0),
      ("system is not an assistant", [user, .init(role: .system, text: "Context")], 0),
      (
        "system context does not add exchanges",
        [user, .init(role: .system, text: "Context"), assistant], 1
      ),
      (
        "text with audio still counts",
        [.init(role: .user, text: "Typed text", audio: "voice.m4a"), assistant], 1
      ),
    ]
    for (title, entries, _) in cases {
      conversation(in: context, characterID: novaID, entries: entries, title: title)
    }
    // An unmatched user and reply in different conversations must never form a pair.
    conversation(
      in: context, characterID: characters[1].id, entries: [user], title: "Separate user")
    conversation(
      in: context, characterID: characters[1].id, entries: [assistant], title: "Separate reply")
    conversation(in: context, characterID: characters[2].id, entries: exchanges(2))
    conversation(in: context, characterID: characters[2].id, entries: exchanges(3))
    conversation(in: context, characterID: customID, entries: exchanges(8))
    try context.save()
    let reader = ModelContext(container)
    let persisted = try reader.fetch(FetchDescriptor<ConversationRecord>())
    for (title, _, expected) in cases {
      let matching = persisted.filter { $0.title == title }
      let count = GalleryActivity.completedExchanges(in: matching)[novaID, default: 0]
      try expect(count == expected, "\(title): expected \(expected) exchanges, got \(count)")
    }
    let repository = SwiftDataGalleryRepository(context: context)
    let counts = try repository.reconcile(now: initialDate)
    try expect(
      counts[novaID, default: 0] == 5, "Rejected/duplicate activity affected Nova total: \(counts)")
    try expect(
      counts[characters[1].id, default: 0] == 0, "Paired messages across separate conversations")
    try expect(
      counts[characters[2].id, default: 0] == 5, "Did not aggregate same-character conversations")
    try expect(counts[customID, default: 0] == 8, "Lost genuine custom-character activity")
    let records = try repository.items()
    try expect(records.count == 16, "Custom progress must not create borrowed built-in definitions")
    try expect(
      !records.contains { $0.characterID == customID }, "Borrowed artwork for custom character")
    for character in characters {
      let original = try definition(characterID: character.id, rule: .exchanges(5))
      let item = try record(original.id, in: repository)
      let shouldUnlock = character.id == novaID || character.id == characters[2].id
      try expect(
        item.isUnlocked == shouldUnlock, "Cross-character progress borrowing: \(character.name)")
    }
  }

  private static func checkUnsavedExisting(url: URL) throws {
    let container = try container(at: url)
    let context = container.mainContext
    let repository = SwiftDataGalleryRepository(context: context)
    let novaID = characters[0].id
    let chat = conversation(in: context, characterID: novaID, entries: exchanges(4))
    try context.save()
    _ = try repository.reconcile(now: initialDate)
    for entry in exchanges(1) { append(entry, to: chat, in: context) }
    for _ in 0..<2 {
      let counts = try repository.reconcile(now: laterDate)
      try expect(counts[novaID, default: 0] == 4, "Unsaved fifth exchange counted: \(counts)")
    }
    let original = try definition(characterID: novaID, rule: .exchanges(5))
    try expect(
      try record(original.id, in: repository).isUnlocked == false, "Unsaved fifth exchange unlocked"
    )
    context.rollback()
    let pending = conversation(
      in: context, characterID: novaID,
      entries: [
        .init(role: .user, text: "Question", delivery: .pending),
        .init(role: .assistant, text: "Answer", delivery: .pending),
      ])
    try context.save()
    for message in pending.messages { message.deliveryStateRawValue = "sent" }
    let counts = try repository.reconcile(now: laterDate)
    try expect(counts[novaID, default: 0] == 4, "Unsaved delivery changes counted")
    context.rollback()
  }

  private static func checkUnsavedBootstrap(url: URL, updateExisting: Bool) throws {
    let container = try container(at: url)
    let context = container.mainContext
    let novaID = characters[0].id
    let entries = exchanges(5).map { entry in
      Entry(role: entry.role, text: entry.text, delivery: updateExisting ? .pending : .sent)
    }
    let chat = conversation(in: context, characterID: novaID, entries: entries)
    if updateExisting {
      try context.save()
      for message in chat.messages { message.deliveryStateRawValue = "sent" }
    }
    let repository = SwiftDataGalleryRepository(context: context)
    let first = try repository.reconcile(now: initialDate)
    let second = try repository.reconcile(now: laterDate)
    let fresh = ModelContext(container)
    let savedChats = try fresh.fetch(FetchDescriptor<ConversationRecord>())
    let persistedCount = GalleryActivity.completedExchanges(in: savedChats)[novaID, default: 0]
    let original = try definition(characterID: novaID, rule: .exchanges(5))
    let item = try record(original.id, in: repository)
    try expect(
      first[novaID, default: 0] == 0 && second[novaID, default: 0] == 0
        && persistedCount == 0 && !item.isUnlocked,
      "Unsaved activity leaked: first=\(first[novaID, default: 0]), "
        + "second=\(second[novaID, default: 0]), persisted=\(persistedCount), "
        + "unlocked=\(item.isUnlocked); reconciliation must not save unrelated chat changes")
  }

  private static func legacyItems() -> [GalleryItem] {
    [
      GalleryItem(
        id: UUID(uuidString: "C3000000-0000-0000-0000-000000000001")!,
        characterID: characters[0].id, kind: .image, localIdentifier: "legacy-photo.jpg",
        caption: "Existing photo", createdAt: initialDate),
      GalleryItem(
        id: UUID(uuidString: "C3000000-0000-0000-0000-000000000002")!,
        characterID: nil, kind: .audio, localIdentifier: "legacy-note.m4a",
        caption: nil, createdAt: initialDate),
    ]
  }

  private static func checkLegacyRecords(_ repository: SwiftDataGalleryRepository) throws {
    for item in legacyItems() {
      let record = try record(item.id, in: repository)
      try expect(record.characterID == item.characterID, "Legacy character ID changed")
      try expect(record.kindRawValue == item.kind.rawValue, "Legacy media kind changed")
      try expect(record.localIdentifier == item.localIdentifier, "Legacy local identifier changed")
      try expect(
        record.caption == item.caption && record.createdAt == item.createdAt,
        "Legacy metadata changed")
      try expect(
        record.isUnlocked && record.isSaved, "Legacy explicit saves lost available/saved state")
      try expect(
        record.definitionID == nil && record.unlockedAt == nil, "Legacy metadata fabricated")
    }
  }

  private static func seedProgress(url: URL) throws {
    let container = try container(at: url)
    let context = container.mainContext
    let repository = SwiftDataGalleryRepository(context: context)
    for item in legacyItems() { try repository.save(item) }
    let initialCounts = try repository.reconcile(now: initialDate)
    try expect(initialCounts.isEmpty, "Empty store contains invented activity")
    let records = try repository.items()
    try expect(records.count == 18, "Catalog reconciliation lost legacy records")
    for definition in GalleryCatalog.moments {
      let item = try record(definition.id, in: repository)
      let initial = definition.unlockRule == .initial
      try expect(item.isUnlocked == initial, "Initial unlock state wrong")
      try expect(!item.isSaved, "Bundled art must not start explicitly Saved")
      try expect(item.unlockedAt == (initial ? initialDate : nil), "Initial unlock timestamp wrong")
    }
    let novaID = characters[0].id
    let portrait = try definition(characterID: novaID, rule: .initial)
    let original = try definition(characterID: novaID, rule: .exchanges(5))
    try repository.setSaved(true, id: original.id)
    try expect(
      try record(original.id, in: repository).isSaved == false, "setSaved saved a locked item")
    let chat = conversation(in: context, characterID: novaID, entries: exchanges(4))
    try context.save()
    let four = try repository.reconcile(now: initialDate)
    try expect(four[novaID] == 4, "Expected four persisted exchanges")
    try expect(
      try record(original.id, in: repository).isUnlocked == false, "Unlocked before fifth exchange")
    for entry in exchanges(1) { append(entry, to: chat, in: context) }
    try context.save()
    let five = try repository.reconcile(now: unlockDate)
    try expect(five[novaID] == 5, "Expected five persisted exchanges")
    let unlocked = try record(original.id, in: repository)
    try expect(unlocked.isUnlocked && !unlocked.isSaved, "Unlock must not implicitly Save")
    try expect(unlocked.unlockedAt == unlockDate, "Fifth exchange must stamp actual unlock date")
    try repository.setSaved(true, id: original.id)
    try repository.setSaved(true, id: portrait.id)
    _ = try repository.reconcile(now: laterDate)
    _ = try repository.reconcile(now: initialDate.addingTimeInterval(-100))
    try expect(unlocked.unlockedAt == unlockDate, "Reconcile changed original unlock timestamp")
    try expect(try repository.items().count == 18, "Repeated reconciliation duplicated definitions")
    try checkLegacyRecords(repository)
  }

  private static func checkProgressState(
    _ repository: SwiftDataGalleryRepository,
    saved: Bool
  ) throws {
    let portrait = try definition(characterID: characters[0].id, rule: .initial)
    let original = try definition(characterID: characters[0].id, rule: .exchanges(5))
    let portraitRecord = try record(portrait.id, in: repository)
    let originalRecord = try record(original.id, in: repository)
    try expect(portraitRecord.isUnlocked && originalRecord.isUnlocked, "Persisted unlock lost")
    try expect(
      portraitRecord.isSaved == saved && originalRecord.isSaved == saved,
      "Explicit save/unsave lost")
    try expect(portraitRecord.unlockedAt == initialDate, "Portrait unlock timestamp changed")
    try expect(originalRecord.unlockedAt == unlockDate, "Earned unlock timestamp changed")
    try expect(try repository.items().count == 18, "Record count changed after restart")
    try checkLegacyRecords(repository)
  }

  private static func restartSaved(url: URL) throws {
    let container = try container(at: url)
    let context = container.mainContext
    let repository = SwiftDataGalleryRepository(context: context)
    try checkProgressState(repository, saved: true)
    for chat in try context.fetch(FetchDescriptor<ConversationRecord>()) { context.delete(chat) }
    try context.save()
    let counts = try repository.reconcile(now: laterDate)
    try expect(counts.isEmpty, "Deleted chat still counted")
    try expect(
      try context.fetchCount(FetchDescriptor<MessageRecord>()) == 0, "Chat deletion did not cascade"
    )
    try checkProgressState(repository, saved: true)
    for rule in [GalleryUnlockRule.initial, .exchanges(5)] {
      let definition = try definition(characterID: characters[0].id, rule: rule)
      try repository.setSaved(false, id: definition.id)
    }
    try checkProgressState(repository, saved: false)
  }

  private static func restartUnsaved(url: URL) throws {
    let container = try container(at: url)
    let repository = SwiftDataGalleryRepository(context: container.mainContext)
    try checkProgressState(repository, saved: false)
    let counts = try repository.reconcile(now: laterDate.addingTimeInterval(10_000))
    try expect(counts.isEmpty, "Deleted activity resurrected after restart")
    try checkProgressState(repository, saved: false)
  }

  private static func checkMigration(url: URL) throws {
    do {
      let container = try container(at: url)
      let context = container.mainContext
      let repository = SwiftDataGalleryRepository(context: context)
      try expect(
        try repository.items().count == 2, "Migration lost/duplicated old gallery entities")
      try checkLegacyRecords(repository)
      let voices = try context.fetch(FetchDescriptor<VoiceProfileRecord>())
      try expect(voices.count == 1, "Migration lost legacy voice record")
      let voice = voices[0]
      try expect(
        voice.id == "legacy-voice" && voice.displayName == "Legacy voice", "Voice identity changed")
      try expect(
        voice.localeIdentifier == "en-US" && voice.providerIdentifier == "legacy-provider",
        "Voice provider changed")
      try expect(voice.speakingRate == 0.5 && voice.pitch == 1.25, "Voice settings changed")
      let chats = try context.fetch(FetchDescriptor<ConversationRecord>())
      try expect(
        chats.count == 1 && chats[0].title == "Legacy conversation", "Migration lost conversation")
      try expect(chats[0].messages.count == 2, "Migration lost message relationship")
      try expect(
        GalleryActivity.completedExchanges(in: chats)[characters[0].id] == 1,
        "Migration changed chat activity")
      _ = try repository.reconcile(now: laterDate)
      try expect(
        try repository.items().count == 18, "Migrated old and new gallery records did not coexist")
      try checkLegacyRecords(repository)
      try repository.setSaved(false, id: legacyItems()[0].id)
    }
    let reopened = try container(at: url)
    let repository = SwiftDataGalleryRepository(context: reopened.mainContext)
    let image = try record(legacyItems()[0].id, in: repository)
    try expect(
      !image.isSaved && image.isUnlocked, "New fields not writable/persistent after migration")
    try expect(
      image.localIdentifier == "legacy-photo.jpg", "Migrated media reference lost after reopen")
    try expect(try repository.items().count == 18, "Migration/restart changed record count")
  }
}
