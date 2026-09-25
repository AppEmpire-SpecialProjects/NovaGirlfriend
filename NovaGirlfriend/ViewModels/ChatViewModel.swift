import Combine
import Foundation
import SwiftData

@MainActor
final class ChatViewModel: ObservableObject {
  @Published var conversation: ConversationRecord?
  @Published var isThinking = false
  @Published var error: String?
  @Published var showPremiumPaywall = false
  private let injectedAccess: AccessPolicy?
  private var access: AccessPolicy { injectedAccess ?? .shared }
  @Published private(set) var affinityPoints = 0
  @Published private(set) var stageUp: AffinityStage?
  @Published private(set) var unlockedAchievement: AchievementDefinition?
  @Published private(set) var scenario: Scenario?
  private var requestTask: Task<Void, Never>?
  private var memoryTask: Task<Void, Never>?
  private var context: ModelContext?
  private var character: CharacterProfile?
  private let ai: any AIServiceProtocol
  private let localeCode: () -> String
  static let maximumInjectedFacts = 30

  /// Optional hook the view layer sets to buffer the companion voice for an
  /// incoming reply before it is revealed, so text and audio surface
  /// together. `complete` keeps the reply hidden ("Thinking…") until the hook
  /// returns; failures inside the hook must not throw, they simply release
  /// the reply and let `speak` fall back.
  var prepareReplyVoice: ((String) async -> Void)?

  nonisolated init(
    ai: (any AIServiceProtocol)? = nil,
    access: AccessPolicy? = nil,
    localeCode: @autoclosure @escaping () -> String = UserDefaults.standard
      .string(forKey: "preferences.preferredLocale") ?? ""
  ) {
    self.injectedAccess = access
    self.ai = ai ?? URLSessionAIService(configuration: AppConfiguration())
    self.localeCode = localeCode
  }

  func open(
    context: ModelContext, character: CharacterProfile, scenario: Scenario?,
    existing: ConversationRecord?, startNew: Bool = false
  ) {
    guard self.context == nil else { return }
    self.context = context
    self.character = character
    self.scenario = scenario
    do {
      let repository = SwiftDataConversationRepository(context: context)
      let resumed =
        startNew
        ? nil
        : try repository.conversations().first {
          $0.characterID == character.id && $0.scenarioID == scenario?.id
        }
      let requestedScenario = scenario != nil && !access.isPremium ? nil : scenario
      if existing == nil, resumed == nil, scenario != nil, !access.isPremium {
        _ = allow(.scenarios)
      }
      conversation =
        try existing ?? resumed
        ?? repository.create(
          characterID: character.id, scenarioID: requestedScenario?.id, title: character.name)
      self.scenario =
        conversation?.scenarioID == scenario?.id
        ? scenario
        : ProductContentRepository().scenarios.first { $0.id == conversation?.scenarioID }
      for message in conversation?.messages ?? [] where message.deliveryStateRawValue == "pending" {
        message.deliveryStateRawValue = "failed"
      }
      affinityPoints = try AffinityStore(context: context).points(for: character.id)
      try context.save()
    } catch { self.error = error.localizedDescription }
  }

  /// Seeds the companion's opening line into an empty conversation so the
  /// chat never opens on a blank screen. No AI round trip is involved.
  @discardableResult
  func seedGreeting() -> Bool {
    guard let conversation, let context, let character,
      conversation.messages.isEmpty, !isThinking
    else { return false }
    let greeting = ChatMessage(
      id: UUID(), conversationID: conversation.id, role: .assistant,
      text: GreetingComposer.greeting(for: character, scenario: scenario),
      createdAt: .now, deliveryState: .sent)
    do {
      try SwiftDataConversationRepository(context: context).append(greeting, to: conversation)
      return true
    } catch {
      self.error = error.localizedDescription
      return false
    }
  }

  @discardableResult
  func selectScenario(_ scenario: Scenario?) -> Bool {
    guard !isThinking, let context, let conversation else { return false }
    if scenario != nil, !allow(.scenarios) { return false }
    let previousID = conversation.scenarioID
    conversation.scenarioID = scenario?.id
    do {
      try context.save()
      self.scenario = scenario
      return true
    } catch {
      conversation.scenarioID = previousID
      self.error = error.localizedDescription
      return false
    }
  }

  @discardableResult
  func send(text: String, audioFileName: String? = nil, photoFileName: String? = nil) -> Bool {
    let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !isThinking, !text.isEmpty || audioFileName != nil || photoFileName != nil,
      let conversation, let context
    else { return false }
    if photoFileName != nil, !allow(.photoAI) { return false }
    if scenario != nil, !allow(.scenarios) { return false }
    var reservation: UUID?
    if !text.isEmpty {
      do { reservation = try access.reserveTextReply() } catch {
        presentAccessDenial(error)
        return false
      }
    }
    var handedOff = false
    defer {
      if !handedOff, let reservation {
        access.finishTextReply(reservation, succeeded: false)
      }
    }
    let message = ChatMessage(
      id: UUID(), conversationID: conversation.id, role: .user,
      text: text, createdAt: .now, deliveryState: .pending,
      audioFileName: audioFileName, photoFileName: photoFileName)
    do {
      try SwiftDataConversationRepository(context: context).append(message, to: conversation)
      guard let record = conversation.messages.first(where: { $0.id == message.id }) else {
        return false
      }
      if text.isEmpty {
        record.deliveryStateRawValue = "sent"
        try context.save()
      } else {
        if let reservation {
          handedOff = true
          complete(record, reservation: reservation)
        }
      }
      return true
    } catch {
      self.error = error.localizedDescription
      return false
    }
  }

  func retry(_ record: MessageRecord) {
    guard !isThinking, record.roleRawValue == MessageRole.user.rawValue,
      record.deliveryStateRawValue == MessageDeliveryState.failed.rawValue
    else { return }
    if record.photoFileName != nil, !allow(.photoAI) { return }
    if scenario != nil, !allow(.scenarios) { return }
    do {
      complete(record, reservation: try access.reserveTextReply())
    } catch { presentAccessDenial(error) }
  }

  func allow(_ feature: AccessPolicy.Feature) -> Bool {
    do {
      try access.require(feature)
      return true
    } catch {
      presentAccessDenial(error)
      return false
    }
  }

  private func presentAccessDenial(_ error: Error) {
    self.error = error.localizedDescription
    showPremiumPaywall = true
  }

  private func complete(_ record: MessageRecord, reservation: UUID) {
    guard let context, let conversation, let character else {
      access.finishTextReply(reservation, succeeded: false)
      return
    }
    error = nil
    isThinking = true
    record.deliveryStateRawValue = "pending"
    do { try context.save() } catch {
      self.error = error.localizedDescription
      isThinking = false
      access.finishTextReply(reservation, succeeded: false)
      return
    }
    let history = conversation.orderedMessages
      .filter {
        $0.createdAt <= record.createdAt && !$0.text.isEmpty
          && ($0.deliveryStateRawValue == "sent" || $0.id == record.id)
      }
      .suffix(40)
      .map { $0.message(conversationID: conversation.id) }
    var messages: [ChatMessage] = Array(history)
    let photoData = record.photoFileName.flatMap { name in
      (try? ChatPhotoStore.url(for: name)).flatMap { try? Data(contentsOf: $0) }
    }
    messages.append(
      contentsOf: contextualInstructions(
        hasPhoto: record.photoFileName != nil, photoVisible: photoData != nil,
        userText: record.text))
    let request = AICompletionRequest(
      messages: messages, character: character, scenario: scenario, photoJPEGData: photoData)
    requestTask = Task {
      var succeeded = false
      defer {
        access.finishTextReply(reservation, succeeded: succeeded)
        isThinking = false
      }
      do {
        let response = try await ai.complete(request)
        try Task.checkCancellation()
        guard !response.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
          throw ServiceError.invalidResponse
        }
        // Hold the reply hidden until its companion voice is fully buffered,
        // so text and audio surface together (see prepareReplyVoice).
        if let prepareReplyVoice {
          await prepareReplyVoice(response.text)
          try Task.checkCancellation()
        }
        record.deliveryStateRawValue = "sent"
        try SwiftDataConversationRepository(context: context).append(
          ChatMessage(
            id: UUID(), conversationID: conversation.id, role: .assistant,
            text: response.text, createdAt: .now, deliveryState: .sent), to: conversation)
        succeeded = true
        awardProgress()
        extractMemoryIfDue()
      } catch {
        record.deliveryStateRawValue = "failed"
        do { try context.save() } catch { self.error = error.localizedDescription }
        if error is AccessPolicy.Denial {
          presentAccessDenial(error)
        } else if !(error is CancellationError) {
          self.error = error.localizedDescription
        }
      }
    }
  }

  /// System instructions appended to the outgoing request only: remembered
  /// facts, a fixed conversation language, and an acknowledgment hint when
  /// the user attached a photo. They are never persisted to the transcript.
  private func contextualInstructions(
    hasPhoto: Bool, photoVisible: Bool, userText: String
  ) -> [ChatMessage] {
    var instructions: [String] = []
    let facts = memoryFacts().suffix(Self.maximumInjectedFacts)
    if !facts.isEmpty {
      instructions.append(
        "Facts you already know about the user, gathered from earlier conversations:\n"
          + facts.map { "- \($0)" }.joined(separator: "\n"))
    }
    if let languageInstruction = ConversationLanguages.instruction(
      forCode: localeCode(), mirroring: userText)
    {
      instructions.append(languageInstruction)
    }
    if hasPhoto {
      instructions.append(
        photoVisible
          ? "The user attached a photo to their latest message. The image is delivered with "
            + "their message; look at it and respond to what you see, warmly and in character."
          : "The user attached a photo to their latest message. You cannot see its contents. "
            + "Acknowledge that they shared it warmly and ask about it if it fits the moment.")
    }
    return instructions.map {
      ChatMessage(
        id: UUID(), conversationID: UUID(), role: .system,
        text: $0, createdAt: .now, deliveryState: .sent)
    }
  }

  private func memoryFacts() -> [String] {
    guard let context else { return [] }
    let facts = try? context.fetch(
      FetchDescriptor<MemoryFactRecord>(sortBy: [SortDescriptor(\.createdAt)]))
    return (facts ?? []).map(\.text)
  }

  private func awardProgress() {
    guard let context, let character else { return }
    let affinity = AffinityStore(context: context)
    let achievements = AchievementStore(context: context)
    do {
      if let crossed = try affinity.awardExchange(to: character.id) {
        stageUp = crossed
      }
      affinityPoints = try affinity.points(for: character.id)
      if let achievement = try achievements.record(
        kind: .exchanges, value: totalCompletedExchanges()
      ).first {
        unlockedAchievement = achievement
      }
      if let achievement = try achievements.record(
        kind: .boundCompanions, value: try affinity.companions(atLeast: .bound)
      ).first {
        unlockedAchievement = achievement
      }
    } catch {
      // Progress tracking is best-effort; the exchange itself already succeeded.
    }
  }

  /// Completed user exchanges across every conversation, app-wide.
  private func totalCompletedExchanges() -> Int {
    guard let context else { return 0 }
    let conversations = (try? context.fetch(FetchDescriptor<ConversationRecord>())) ?? []
    return conversations.reduce(0) { total, conversation in
      total
        + conversation.messages.filter {
          $0.roleRawValue == MessageRole.user.rawValue
            && $0.deliveryStateRawValue == MessageDeliveryState.sent.rawValue
        }.count
    }
  }

  /// Extracts new memory facts every `MemoryExtractor.extractionInterval`
  /// user turns within the current conversation. Runs out-of-band: failures
  /// never surface in the chat.
  private func extractMemoryIfDue() {
    guard let context, let conversation, let character else { return }
    let userTurns = conversation.messages
      .filter { $0.roleRawValue == MessageRole.user.rawValue }.count
    guard
      userTurns > 0, userTurns % MemoryExtractor.extractionInterval == 0
    else { return }
    let existing = memoryFacts()
    let extractor = MemoryExtractor(ai: ai)
    let transcript = conversation.orderedMessages.suffix(MemoryExtractor.reviewWindow)
      .map { $0.message(conversationID: conversation.id) }
    memoryTask = Task {
      do {
        let facts = try await extractor.extract(
          from: transcript, existing: existing, character: character)
        try Task.checkCancellation()
        // Re-check on the actor before inserting: consecutive turns can read
        // the same "existing" snapshot, so dedupe against live store state.
        let known = Set(memoryFacts().map(MemoryExtractor.normalize))
        let fresh = facts.filter { !known.contains(MemoryExtractor.normalize($0)) }
        guard !fresh.isEmpty else { return }
        for fact in fresh { context.insert(MemoryFactRecord(text: fact)) }
        try context.save()
      } catch is CancellationError {
      } catch {
        // Memory extraction is best-effort and silent by design.
      }
    }
  }

  func clearCelebrations() {
    if stageUp != nil { stageUp = nil }
    if unlockedAchievement != nil { unlockedAchievement = nil }
  }

  func stop() {
    requestTask?.cancel()
    memoryTask?.cancel()
  }
}
