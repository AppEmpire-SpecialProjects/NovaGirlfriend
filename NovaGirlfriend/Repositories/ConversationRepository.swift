import Foundation
import SwiftData

@MainActor
protocol ConversationRepositoryProtocol {
  func conversations() throws -> [ConversationRecord]
  func create(characterID: UUID, scenarioID: String?, title: String) throws -> ConversationRecord
  func append(_ message: ChatMessage, to conversation: ConversationRecord) throws
  func delete(_ conversation: ConversationRecord) throws
}

@MainActor
final class SwiftDataConversationRepository: ConversationRepositoryProtocol {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func conversations() throws -> [ConversationRecord] {
    try context.fetch(
      FetchDescriptor(sortBy: [SortDescriptor(\ConversationRecord.updatedAt, order: .reverse)]))
  }

  func create(characterID: UUID, scenarioID: String?, title: String) throws -> ConversationRecord {
    let conversation = ConversationRecord(
      characterID: characterID, scenarioID: scenarioID, title: title)
    context.insert(conversation)
    try context.save()
    return conversation
  }

  func append(_ message: ChatMessage, to conversation: ConversationRecord) throws {
    let record = MessageRecord(
      id: message.id,
      role: message.role,
      text: message.text,
      createdAt: message.createdAt,
      deliveryState: message.deliveryState,
      audioFileName: message.audioFileName,
      photoFileName: message.photoFileName
    )
    record.conversation = conversation
    conversation.messages.append(record)
    conversation.updatedAt = message.createdAt
    try context.save()
  }

  func delete(_ conversation: ConversationRecord) throws {
    context.delete(conversation)
    try context.save()
  }
}
