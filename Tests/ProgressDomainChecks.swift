import Foundation
import SwiftData

// Files are not recorded in this macOS-only domain harness.
@MainActor enum RecordingController {
  static func remove(_ file: String) throws {}
}

/// Scripted AI: returns chat replies or extraction results depending on the
/// prompt it receives, recording every request for assertions.
@MainActor final class ScriptedAI: AIServiceProtocol {
  var requests: [AICompletionRequest] = []
  var chatResponse = "Companion reply"
  var extractionResponse = "- User enjoys night walks"

  func complete(_ request: AICompletionRequest) async throws -> AICompletionResponse {
    requests.append(request)
    let text = request.messages.first?.text ?? ""
    let isExtraction = text.contains("list new facts about the user")
    return AICompletionResponse(text: isExtraction ? extractionResponse : chatResponse)
  }
}

@main struct ProgressChecks {
  @MainActor static func main() async throws {
    let container = try makeContainer()
    let context = container.mainContext
    try checkAffinity(context: context)
    try checkAchievements(context: context)
    try checkStreak(context: context)
    checkMemoryParse()
    try await checkMemoryExtraction()
    checkGreetings()
    try checkPhotoStore()
    try await checkChatViewModelIntegration()
    print("PASS: affinity thresholds/crossing/cap, achievements, streaks, memory parse/extract, greetings, photo store, chat integration")
  }

  @MainActor static func makeContainer() throws -> ModelContainer {
    try ModelContainer(
      for: ConversationRecord.self, MessageRecord.self, AffinityRecord.self,
      AchievementRecord.self, UserStreakRecord.self, MemoryFactRecord.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true))
  }

  // MARK: Affinity

  @MainActor private static func checkAffinity(context: ModelContext) throws {
    let store = AffinityStore(context: context)
    let first = UUID()
    var crossed: [AffinityStage] = []
    for _ in 0..<30 {
      if let stage = try store.awardExchange(to: first) { crossed.append(stage) }
    }
    let firstPoints = try store.points(for: first)
    let firstStage = try store.stage(for: first)
    precondition(firstPoints == 60)
    precondition(crossed == [.warm])
    precondition(firstStage == .warm)

    for _ in 30..<90 { _ = try store.awardExchange(to: first) }
    let closePoints = try store.points(for: first)
    let closeStage = try store.stage(for: first)
    precondition(closePoints == 180)
    precondition(closeStage == .close)

    let capped = UUID()
    for _ in 0..<500 { _ = try store.awardExchange(to: capped) }
    let cappedPoints = try store.points(for: capped)
    let boundCount = try store.companions(atLeast: .bound)
    let allCount = try store.companions(atLeast: .stranger)
    let cappedStage = try store.stage(for: capped)
    precondition(cappedPoints == 800)
    precondition(cappedStage == .bound)
    precondition(boundCount == 1)
    precondition(allCount == 2)

    precondition(
      AffinityStage.progress(from: .warm, points: 100)
        == Double(100 - 60) / Double(180 - 60))
    precondition(AffinityStage.progress(from: .warm, points: 20) == 0)
    precondition(AffinityStage.progress(from: .warm, points: 180) == 1)
    precondition(AffinityStage.progress(from: .bound, points: 800) == 1)
    precondition(AffinityStage.stage(forPoints: 59) == .stranger)
    precondition(AffinityStage.stage(forPoints: 400) == .devoted)
    print("PASS: affinity points, stage thresholds, single crossing report, 800 cap, companions count, progress fractions")
  }

  // MARK: Achievements

  @MainActor private static func checkAchievements(context: ModelContext) throws {
    let store = AchievementStore(context: context)
    precondition(AchievementCatalog.all.count == 12)
    let firstUnlock = try store.record(kind: .exchanges, value: 1)
    precondition(firstUnlock.map(\.id) == ["exchanges-1"])
    let belowTier = try store.record(kind: .exchanges, value: 24)
    precondition(belowTier.isEmpty)
    let secondUnlock = try store.record(kind: .exchanges, value: 25)
    precondition(secondUnlock.map(\.id) == ["exchanges-25"])
    let exactTop = try store.record(kind: .exchanges, value: 500)
    precondition(exactTop.map(\.id) == ["exchanges-100", "exchanges-500"])
    let jumpUnlocks = try store.record(kind: .exchanges, value: 800)
    precondition(jumpUnlocks.isEmpty)
    let repeatUnlocks = try store.record(kind: .exchanges, value: 800)
    precondition(repeatUnlocks.isEmpty)
    let unlockedIDs = try store.unlockedIDs()
    precondition(unlockedIDs.count == 4)
    let storedRecords = try store.records()
    precondition(storedRecords.count == 4)
    precondition(
      AchievementCatalog.all.filter { $0.kind == .streakDays }.count == 3)
    print("PASS: achievement tiers unlock once, in order, and persist")
  }

  // MARK: Streaks

  @MainActor private static func checkStreak(context: ModelContext) throws {
    let store = AchievementStore(context: context)
    let day = Date(timeIntervalSince1970: 1_700_000_000)
    let dayString = AchievementStore.dayString(for: day)
    precondition(dayString.count == 10 && dayString.hasPrefix("20"))

    let dayOneUnlocks = try store.registerVisit(now: day)
    precondition(dayOneUnlocks.isEmpty)
    var streak = try store.streak()
    precondition(streak.currentStreak == 1 && streak.longestStreak == 1)
    let repeatVisitUnlocks = try store.registerVisit(now: day)
    precondition(repeatVisitUnlocks.isEmpty)
    streak = try store.streak()
    precondition(streak.currentStreak == 1)

    _ = try store.registerVisit(now: day.addingTimeInterval(86_400))
    let unlockedThird = try store.registerVisit(now: day.addingTimeInterval(2 * 86_400))
    precondition(unlockedThird.map(\.id) == ["streakDays-3"])
    streak = try store.streak()
    precondition(streak.currentStreak == 3 && streak.longestStreak == 3)

    _ = try store.registerVisit(now: day.addingTimeInterval(4 * 86_400))
    streak = try store.streak()
    precondition(streak.currentStreak == 1 && streak.longestStreak == 3)
    let gapVisitUnlocks = try store.registerVisit(now: day.addingTimeInterval(4 * 86_400))
    precondition(gapVisitUnlocks.isEmpty)
    print("PASS: streak extends across consecutive days, resets after a gap, is idempotent per day")
  }

  // MARK: Memory parsing

  @MainActor private static func checkMemoryParse() {
    let long = String(repeating: "x", count: 161)
    let raw = """
      Preamble to ignore
      -Loves jazz
      • Hates rain
      *   Prefers night
      - LOVES JAZZ
      NONE
      - \(long)
      - Plays piano
      - Hikes on weekends
      - Owns a cat
      - Bakes bread
      - Extra fact dropped at the limit
      """
    let parsed = MemoryExtractor.parse(raw, existing: [])
    precondition(
      parsed == ["Loves jazz", "Hates rain", "Prefers night", "Plays piano", "Hikes on weekends"])
    precondition(MemoryExtractor.parse("NONE", existing: []).isEmpty)
    precondition(
      MemoryExtractor.parse("- Loves jazz", existing: ["loves jazz"]).isEmpty)
    print("PASS: memory parser strips prefixes, dedupes case-insensitively, enforces length and fact limits")
  }

  @MainActor private static func checkMemoryExtraction() async throws {
    let character = ProductContentRepository().characters[0]
    let ai = ScriptedAI()
    ai.extractionResponse = "- User enjoys night walks\n- User enjoys night walks\nNONE"
    let messages = [
      ChatMessage(
        id: UUID(), conversationID: UUID(), role: .user,
        text: "I walk every evening near the river.", createdAt: .now, deliveryState: .sent),
      ChatMessage(
        id: UUID(), conversationID: UUID(), role: .assistant,
        text: "That sounds peaceful.", createdAt: .now, deliveryState: .sent),
    ]
    let extractor = MemoryExtractor(ai: ai)
    let facts = try await extractor.extract(
      from: messages, existing: ["User enjoys night walks"], character: character)
    precondition(facts.isEmpty)
    precondition(ai.requests.count == 1)
    precondition(ai.requests[0].messages.count == 1)
    precondition(
      (ai.requests[0].messages[0].text).contains("list new facts about the user"))

    let fresh = try await extractor.extract(from: messages, existing: [], character: character)
    precondition(fresh == ["User enjoys night walks"])
    print("PASS: memory extractor prompts the AI once and dedupes against known facts")
  }

  // MARK: Greetings

  private static func checkGreetings() {
    let characters = ProductContentRepository().characters
    var distinct = Set<String>()
    for character in characters {
      let plain = GreetingComposer.greeting(for: character, scenario: nil)
      precondition(!plain.isEmpty)
      precondition(plain == GreetingComposer.greeting(for: character, scenario: nil))
      distinct.insert(plain)
      let scenario = ProductContentRepository().scenarios.first {
        $0.id == character.preferredScenarioID
      }
      if let scenario {
        let themed = GreetingComposer.greeting(for: character, scenario: scenario)
        precondition(!themed.isEmpty)
        precondition(themed == GreetingComposer.greeting(for: character, scenario: scenario))
      }
    }
    precondition(distinct.count >= 3)
    print("PASS: greetings are non-empty, deterministic, and varied across companions")
  }

  // MARK: Photo store

  @MainActor private static func checkPhotoStore() throws {
    let jpeg = Data([0xFF, 0xD8, 0xFF, 0xE0]) + Data("harness".utf8)
    let name = try ChatPhotoStore.save(data: jpeg)
    precondition(name.hasSuffix(".jpg"))
    let url = try ChatPhotoStore.url(for: name)
    precondition(url.lastPathComponent == name)
    precondition(url.deletingLastPathComponent().lastPathComponent == "ChatPhotos")
    let stored = try Data(contentsOf: url)
    precondition(stored == jpeg)

    precondition(
      (try? ChatPhotoStore.url(for: "../escaped.jpg")) == nil
        || {
          do { _ = try ChatPhotoStore.url(for: "../escaped.jpg"); return false } catch { return true }
        }())
    precondition((try? ChatPhotoStore.save(data: Data("not jpeg".utf8))) == nil)

    ChatPhotoStore.remove(name)
    precondition(!FileManager.default.fileExists(atPath: url.path))
    ChatPhotoStore.remove(name)
    print("PASS: photo store round-trips JPEG data, rejects escapes and non-JPEG payloads, removes idempotently")
  }

  // MARK: ChatViewModel integration

  @MainActor private static func checkChatViewModelIntegration() async throws {
    let container = try makeContainer()
    let context = container.mainContext
    let content = ProductContentRepository()
    let character = content.characters[0]
    let scenario = content.scenarios[0]
    let ai = ScriptedAI()
    let model = ChatViewModel(ai: ai, localeCode: "")
    model.open(context: context, character: character, scenario: scenario, existing: nil)
    let conversation = model.conversation!
    precondition(model.seedGreeting())
    precondition(conversation.messages.count == 1)

    for index in 0..<10 {
      precondition(model.send(text: "Turn \(index)"))
      for _ in 0..<100 where model.isThinking {
        try await Task.sleep(for: .milliseconds(10))
      }
      precondition(!model.isThinking && model.error == nil)
    }
    // Extraction runs out-of-band after every turn; wait for the first fact.
    for _ in 0..<200
    where (try context.fetch(FetchDescriptor<MemoryFactRecord>()).isEmpty) {
      try await Task.sleep(for: .milliseconds(10))
    }
    // Ten chat requests plus per-turn memory extractions. Extraction tasks
    // race with the next send's cancellation, so count chat requests only.
    precondition(
      ai.requests.filter { !$0.messages[0].text.contains("list new facts about the user") }
        .count == 10)
    precondition(
      ai.requests.contains { $0.messages[0].text.contains("list new facts about the user") })
    let awardedPoints = try AffinityStore(context: context).points(for: character.id)
    precondition(awardedPoints == 20)
    let facts = try context.fetch(FetchDescriptor<MemoryFactRecord>())
    precondition(facts.map(\.text) == ["User enjoys night walks"])
    let unlockedIDs = try AchievementStore(context: context).unlockedIDs()
    precondition(unlockedIDs == ["exchanges-1"])
    precondition(model.stageUp == nil && model.affinityPoints == 20)
    precondition(conversation.messages.count == 21)

    // Language pinning and photo markers are request-only system messages.
    let localized = ChatViewModel(ai: ai, localeCode: "ru")
    localized.open(
      context: context, character: character, scenario: scenario, existing: nil,
      startNew: true)
    precondition(localized.send(text: "Hello"))
    for _ in 0..<100 where localized.isThinking {
      try await Task.sleep(for: .milliseconds(10))
    }
    var localizedRequest = ai.requests.last {
      !$0.messages[0].text.contains("list new facts about the user")
    }!
    precondition(
      localizedRequest.messages.last!.role == .system
        && localizedRequest.messages.last!.text.contains("Write every sentence of your reply in Русский"))

    precondition(localized.send(text: "See my photo", photoFileName: "photo.jpg"))
    for _ in 0..<100 where localized.isThinking {
      try await Task.sleep(for: .milliseconds(10))
    }
    localizedRequest = ai.requests.last {
      !$0.messages[0].text.contains("list new facts about the user")
    }!
    precondition(
      localizedRequest.messages.last!.text.contains("attached a photo"))
    let photoMessage = localized.conversation!.messages.first { $0.photoFileName == "photo.jpg" }
    precondition(photoMessage?.deliveryStateRawValue == "sent")

    // Photo-only messages skip the AI entirely. A straggler extraction from
    // the previous turn may still land, so let requests settle and compare
    // chat requests only.
    let chatBefore = ai.requests.filter {
      !$0.messages[0].text.contains("list new facts about the user")
    }.count
    precondition(localized.send(text: "", audioFileName: nil, photoFileName: "photo2.jpg"))
    var settled = -1
    for _ in 0..<100 {
      try await Task.sleep(for: .milliseconds(10))
      let count = ai.requests.count
      if count == settled { break }
      settled = count
    }
    precondition(
      ai.requests.filter { !$0.messages[0].text.contains("list new facts about the user") }
        .count == chatBefore)
    precondition(
      localized.conversation!.orderedMessages.last!.photoFileName == "photo2.jpg")

    // Greeting seeds only empty conversations and matches the composer output.
    let greeted = ChatViewModel(ai: ai, localeCode: "")
    greeted.open(
      context: context, character: character, scenario: scenario, existing: nil,
      startNew: true)
    precondition(greeted.seedGreeting())
    precondition(greeted.conversation!.messages.count == 1)
    precondition(greeted.conversation!.orderedMessages[0].roleRawValue == "assistant")
    precondition(
      greeted.conversation!.orderedMessages[0].text
        == GreetingComposer.greeting(for: character, scenario: scenario))
    precondition(!greeted.seedGreeting())

    print("PASS: chat integration awards affinity, unlocks achievements, extracts memory each turn, pins language, marks photos, seeds greetings")
  }
}
