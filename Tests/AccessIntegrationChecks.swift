import Foundation
import SwiftData

// The domain harness creates companions without avatar files.
@MainActor
enum AvatarStorage {
  static func delete(reference: String?) {}
}

@MainActor
func checkAccessIntegration() async throws {
  let suite = "AccessIntegrationChecks.\(UUID())"
  let defaults = UserDefaults(suiteName: suite)!
  defer { defaults.removePersistentDomain(forName: suite) }
  var premium = false
  let policy = AccessPolicy(defaults: defaults, isPremium: { premium })
  let container = try ModelContainer(
    for: ConversationRecord.self, MessageRecord.self, AffinityRecord.self,
    AchievementRecord.self, UserStreakRecord.self, MemoryFactRecord.self, CharacterRecord.self,
    GalleryItemRecord.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: true))
  let context = container.mainContext
  let character = ProductContentRepository().characters[0]
  let ai = CapturingAI()
  let first = ChatViewModel(ai: ai, access: policy)
  let second = ChatViewModel(ai: ai, access: policy)
  first.open(context: context, character: character, scenario: nil, existing: nil, startNew: true)
  second.open(context: context, character: character, scenario: nil, existing: nil, startNew: true)

  func settle(_ model: ChatViewModel) async throws {
    for _ in 0..<200 where model.isThinking {
      try await Task.sleep(for: .milliseconds(5))
    }
    precondition(!model.isThinking)
  }

  precondition(first.send(text: "Failure is not charged"))
  try await settle(first)
  precondition(policy.successfulRepliesToday == 0 && policy.remainingTextReplies == 10)
  let failed = first.conversation!.messages[0]
  ai.shouldFail = false
  first.retry(failed)
  try await settle(first)
  precondition(policy.successfulRepliesToday == 1)
  ai.delay = true
  precondition(first.send(text: "Cancel me"))
  first.stop()
  try await settle(first)
  precondition(policy.successfulRepliesToday == 1 && policy.remainingTextReplies == 9)
  ai.delay = false
  ai.responseText = "  \n"
  precondition(first.send(text: "Empty response"))
  try await settle(first)
  precondition(policy.successfulRepliesToday == 1)
  ai.responseText = "Valid response"
  for index in 0..<8 {
    let model = index.isMultiple(of: 2) ? first : second
    precondition(model.send(text: "Shared free reply \(index)"))
    try await settle(model)
  }
  precondition(policy.successfulRepliesToday == 9)
  ai.delay = true
  precondition(first.send(text: "Reserve final slot"))
  let secondCount = second.conversation!.messages.count
  precondition(!second.send(text: "Concurrent overflow"))
  precondition(second.conversation!.messages.count == secondCount)
  precondition(second.showPremiumPaywall)
  first.stop()
  try await settle(first)
  ai.delay = false
  let retryable = first.conversation!.orderedMessages.last!
  first.retry(retryable)
  try await settle(first)
  precondition(policy.successfulRepliesToday == 10)
  let olderFailure = first.conversation!.messages.first {
    $0.deliveryStateRawValue == "failed"
  }!
  first.retry(olderFailure)
  precondition(!first.isThinking && first.showPremiumPaywall)
  precondition(olderFailure.deliveryStateRawValue == "failed")
  premium = true
  precondition(second.send(text: "Premium bypasses the cap"))
  try await settle(second)
  let scenario = ProductContentRepository().scenarios[0]
  precondition(second.selectScenario(scenario))
  let savedIDs = second.conversation!.orderedMessages.map(\.id)
  premium = false
  precondition(!second.send(text: "Expired scenario"))
  precondition(second.conversation!.orderedMessages.map(\.id) == savedIDs)
  precondition(second.selectScenario(nil))
  precondition(!second.send(text: "Expired cap remains enforced"))
  precondition(!second.send(text: "Photo", photoFileName: "test.jpg"))
  print(
    "PASS: app-wide send/retry cap, concurrent final slot, failures/empty/cancel release, Premium and expiry, history/scenario reset"
  )

  PremiumStore.shared.isPremium = false
  defer { PremiumStore.shared.isPremium = true }
  let repository = SwiftDataCharacterRepository(context: context)
  var custom = character
  custom.origin = .custom
  try repository.saveCustom(custom)
  var additional = ProductContentRepository().characters[1]
  additional.origin = .custom
  do {
    try repository.saveCustom(additional)
    preconditionFailure("Second free companion must be blocked")
  } catch is AccessPolicy.Denial {}
  PremiumStore.shared.isPremium = true
  try repository.saveCustom(additional)
  PremiumStore.shared.isPremium = false
  additional.name = "Edited after expiry"
  try repository.saveCustom(additional)
  let saved = try repository.customCharacters()
  precondition(saved.count == 2)
  precondition(saved.first { $0.id == additional.id }?.name == "Edited after expiry")
  print(
    "PASS: repository allows one free custom companion, Premium additions and post-expiry editing without deleting saved companions"
  )

  let doomedID = additional.id
  context.insert(ConversationRecord(characterID: doomedID, title: "Doomed"))
  context.insert(AffinityRecord(characterID: doomedID, points: 5))
  context.insert(
    GalleryItemRecord(
      item: GalleryItem(
        id: UUID(), characterID: doomedID, kind: .image, localIdentifier: "doomed.jpg",
        caption: nil, createdAt: .now)))
  try context.save()
  FavoriteCharacterStore.shared.toggle(doomedID)
  try repository.deleteCustom(id: doomedID)
  let remainingCustom = try repository.customCharacters().map(\.id)
  let conversations = try context.fetch(FetchDescriptor<ConversationRecord>())
  let affinities = try context.fetch(FetchDescriptor<AffinityRecord>())
  let galleryItems = try context.fetch(FetchDescriptor<GalleryItemRecord>())
  precondition(remainingCustom == [custom.id])
  precondition(conversations.allSatisfy { $0.characterID != doomedID })
  precondition(affinities.allSatisfy { $0.characterID != doomedID })
  precondition(galleryItems.allSatisfy { $0.characterID != doomedID })
  precondition(!FavoriteCharacterStore.shared.contains(doomedID))
  print("PASS: deleting a custom companion removes its chats, affinity, gallery and favorite")
}
