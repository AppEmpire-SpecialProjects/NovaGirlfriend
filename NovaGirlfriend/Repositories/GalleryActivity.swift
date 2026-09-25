import Foundation

enum GalleryActivity {
  // One exchange is a sent, nonempty user message followed by a sent,
  // nonempty AI reply in the same conversation. Failed attempts, voice-only
  // notes, system messages and unpaired replies cannot earn unlocks.
  static func completedExchanges(in conversations: [ConversationRecord]) -> [UUID: Int] {
    var counts: [UUID: Int] = [:]
    for conversation in conversations {
      var awaitingReply = false
      let messages = conversation.messages.sorted {
        if $0.createdAt != $1.createdAt { return $0.createdAt < $1.createdAt }
        if $0.roleRawValue != $1.roleRawValue { return $0.roleRawValue == "user" }
        return $0.id.uuidString < $1.id.uuidString
      }
      for message in messages {
        let delivered =
          message.deliveryStateRawValue == "sent"
          && !message.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        switch message.roleRawValue {
        case "user":
          awaitingReply = delivered
        case "assistant":
          if delivered && awaitingReply {
            counts[conversation.characterID, default: 0] += 1
          }
          awaitingReply = false
        default:
          break
        }
      }
    }
    return counts
  }
}
