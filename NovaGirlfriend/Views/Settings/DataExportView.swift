import SwiftData
import SwiftUI

struct DataExportView: View {
  @Query(sort: \CharacterRecord.createdAt) private var characters: [CharacterRecord]
  @Query(sort: \ConversationRecord.updatedAt) private var conversations: [ConversationRecord]

  var body: some View {
    Form {
      Section {
        LabeledContent("Custom companions") {
          Text(customCharacters.count, format: .number)
            .foregroundStyle(NovaTheme.textSecondary)
        }
        LabeledContent("Conversations") {
          Text(conversations.count, format: .number)
            .foregroundStyle(NovaTheme.textSecondary)
        }
        LabeledContent("Messages") {
          Text(conversations.reduce(0) { $0 + $1.messages.count }, format: .number)
            .foregroundStyle(NovaTheme.textSecondary)
        }
      } footer: {
        Text(
          "The export contains your local custom companion profiles and conversation text. Audio and avatar image files are not included."
        )
        .foregroundStyle(NovaTheme.textSecondary)
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
      Section {
        ShareLink(item: exportText, subject: Text("Nova Data Export")) {
          Label("Share JSON Export", systemImage: "square.and.arrow.up")
        }
        .novaActionColor()
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
    }
    .novaGroupedListSpacing()
    .novaScreen()
    .novaNavigationTitle("Export Data")
    .toolbar(.hidden, for: .tabBar)
  }

  private var customCharacters: [CharacterRecord] {
    characters.filter { $0.originRawValue == CharacterOrigin.custom.rawValue }
  }

  private var exportText: String {
    let companions: [[String: Any]] = customCharacters.map {
      [
        "id": $0.id.uuidString,
        "name": $0.name,
        "gender": $0.genderRawValue,
        "communicationStyle": $0.communicationStyle,
        "warmth": $0.warmth,
        "humor": $0.humor,
        "curiosity": $0.curiosity,
        "confidence": $0.confidence,
      ]
    }
    let chats: [[String: Any]] = conversations.map { conversation in
      [
        "id": conversation.id.uuidString,
        "title": conversation.title,
        "updatedAt": ISO8601DateFormatter().string(from: conversation.updatedAt),
        "messages": conversation.messages.sorted { $0.createdAt < $1.createdAt }.map {
          [
            "role": $0.roleRawValue,
            "text": $0.text,
            "createdAt": ISO8601DateFormatter().string(from: $0.createdAt),
          ]
        },
      ]
    }
    let root: [String: Any] = [
      "formatVersion": 1,
      "exportedAt": ISO8601DateFormatter().string(from: .now),
      "companions": companions,
      "conversations": chats,
    ]
    guard
      let data = try? JSONSerialization.data(
        withJSONObject: root, options: [.prettyPrinted, .sortedKeys]),
      let text = String(data: data, encoding: .utf8)
    else { return "{}" }
    return text
  }
}
