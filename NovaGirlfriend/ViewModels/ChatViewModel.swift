import Combine
import Foundation
import SwiftData

@MainActor
final class ChatViewModel: ObservableObject {
  @Published var conversation: ConversationRecord?
  @Published var isThinking = false
  @Published var error: String?
  @Published private(set) var scenario: Scenario?
  private var requestTask: Task<Void, Never>?
  private var context: ModelContext?
  private var character: CharacterProfile?
  private let ai: any AIServiceProtocol

  init(ai: (any AIServiceProtocol)? = nil) {
    self.ai = ai ?? URLSessionAIService(configuration: AppConfiguration())
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
      conversation =
        try existing ?? resumed
        ?? repository.create(
          characterID: character.id, scenarioID: scenario?.id, title: character.name)
      self.scenario =
        conversation?.scenarioID == scenario?.id
        ? scenario
        : ProductContentRepository().scenarios.first { $0.id == conversation?.scenarioID }
      for message in conversation?.messages ?? [] where message.deliveryStateRawValue == "pending" {
        message.deliveryStateRawValue = "failed"
      }
      try context.save()
    } catch { self.error = error.localizedDescription }
  }

  @discardableResult
  func selectScenario(_ scenario: Scenario?) -> Bool {
    guard !isThinking, let context, let conversation else { return false }
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
  func send(text: String, audioFileName: String? = nil) -> Bool {
    let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !isThinking, !text.isEmpty || audioFileName != nil,
      let conversation, let context
    else { return false }
    let message = ChatMessage(
      id: UUID(), conversationID: conversation.id, role: .user,
      text: text, createdAt: .now, deliveryState: .pending,
      audioFileName: audioFileName)
    do {
      try SwiftDataConversationRepository(context: context).append(message, to: conversation)
      guard let record = conversation.messages.first(where: { $0.id == message.id }) else {
        return false
      }
      if text.isEmpty {
        record.deliveryStateRawValue = "sent"
        try context.save()
      } else {
        complete(record)
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
    complete(record)
  }

  private func complete(_ record: MessageRecord) {
    guard let context, let conversation, let character else { return }
    error = nil
    isThinking = true
    record.deliveryStateRawValue = "pending"
    do { try context.save() } catch {
      self.error = error.localizedDescription
      isThinking = false
      return
    }
    let messages = conversation.orderedMessages.filter {
      $0.createdAt <= record.createdAt && !$0.text.isEmpty
        && ($0.deliveryStateRawValue == "sent" || $0.id == record.id)
    }.suffix(40).map { $0.message(conversationID: conversation.id) }
    let request = AICompletionRequest(messages: messages, character: character, scenario: scenario)
    requestTask = Task {
      defer { isThinking = false }
      do {
        let response = try await ai.complete(request)
        try Task.checkCancellation()
        guard !response.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
          throw ServiceError.invalidResponse
        }
        record.deliveryStateRawValue = "sent"
        try SwiftDataConversationRepository(context: context).append(
          ChatMessage(
            id: UUID(), conversationID: conversation.id, role: .assistant,
            text: response.text, createdAt: .now, deliveryState: .sent), to: conversation)
      } catch {
        record.deliveryStateRawValue = "failed"
        do { try context.save() } catch { self.error = error.localizedDescription }
        if !(error is CancellationError) { self.error = error.localizedDescription }
      }
    }
  }

  func stop() { requestTask?.cancel() }
}
