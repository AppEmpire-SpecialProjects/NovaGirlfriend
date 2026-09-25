import Foundation
import SwiftData

@Model
final class ConversationRecord {
    @Attribute(.unique) var id: UUID
    var characterID: UUID
    var scenarioID: String?
    var title: String
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \MessageRecord.conversation)
    var messages: [MessageRecord]

    init(
        id: UUID = UUID(),
        characterID: UUID,
        scenarioID: String? = nil,
        title: String,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.characterID = characterID
        self.scenarioID = scenarioID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        messages = []
    }
}

@Model
final class MessageRecord {
    @Attribute(.unique) var id: UUID
    var roleRawValue: String
    var text: String
    var createdAt: Date
    var deliveryStateRawValue: String
    var audioFileName: String?
    var photoFileName: String?
    var conversation: ConversationRecord?

    init(
        id: UUID = UUID(),
        role: MessageRole,
        text: String,
        createdAt: Date = .now,
        deliveryState: MessageDeliveryState = .pending,
        audioFileName: String? = nil,
        photoFileName: String? = nil
    ) {
        self.id = id
        roleRawValue = role.rawValue
        self.text = text
        self.createdAt = createdAt
        deliveryStateRawValue = deliveryState.rawValue
        self.audioFileName = audioFileName
        self.photoFileName = photoFileName
    }
}
