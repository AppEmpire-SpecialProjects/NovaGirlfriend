import Foundation

enum MessageRole: String, Codable, Sendable {
  case user
  case assistant
  case system
}

enum MessageDeliveryState: String, Codable, Sendable {
  case pending
  case sent
  case failed
}

struct ConversationSummary: Identifiable, Codable, Hashable, Sendable {
  let id: UUID
  let characterID: UUID
  var title: String
  var createdAt: Date
  var updatedAt: Date
}

struct ChatMessage: Identifiable, Codable, Hashable, Sendable {
  let id: UUID
  let conversationID: UUID
  let role: MessageRole
  let text: String
  let createdAt: Date
  let deliveryState: MessageDeliveryState
  var audioFileName: String? = nil
}
