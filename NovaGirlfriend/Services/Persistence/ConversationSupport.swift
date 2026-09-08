import Foundation
import SwiftData

extension MessageRecord {
  func message(conversationID: UUID) -> ChatMessage {
    ChatMessage(
      id: id, conversationID: conversationID,
      role: MessageRole(rawValue: roleRawValue) ?? .user,
      text: text, createdAt: createdAt,
      deliveryState: MessageDeliveryState(rawValue: deliveryStateRawValue) ?? .failed,
      audioFileName: audioFileName)
  }
}

extension ConversationRecord {
  var orderedMessages: [MessageRecord] {
    messages.sorted { $0.createdAt < $1.createdAt }
  }

  var summary: ConversationSummary {
    ConversationSummary(
      id: id, characterID: characterID, title: title,
      createdAt: createdAt, updatedAt: updatedAt)
  }
}

@MainActor
struct ConversationMaintenance {
  let context: ModelContext

  func clear(_ conversation: ConversationRecord) throws {
    let files = conversation.messages.compactMap(\.audioFileName)
    for message in conversation.messages { context.delete(message) }
    conversation.messages = []
    conversation.updatedAt = .now
    try context.save()
    for file in files { try? RecordingController.remove(file) }
  }

  func delete(_ conversation: ConversationRecord) throws {
    let files = conversation.messages.compactMap(\.audioFileName)
    context.delete(conversation)
    try context.save()
    for file in files { try? RecordingController.remove(file) }
  }
}
