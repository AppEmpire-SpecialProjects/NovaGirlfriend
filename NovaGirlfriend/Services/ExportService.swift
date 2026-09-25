import Foundation

struct JSONExportService: ExportServiceProtocol {
    private struct ConversationExport: Codable {
        let formatVersion: Int
        let conversation: ConversationSummary
        let messages: [ChatMessage]
    }

    func export(_ conversation: ConversationSummary, messages: [ChatMessage]) throws -> Data {
        let payload = ConversationExport(
            formatVersion: 1,
            conversation: conversation,
            messages: messages.sorted { $0.createdAt < $1.createdAt }
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(payload)
    }
}
