import Foundation

enum ServiceError: LocalizedError, Equatable {
    case notConfigured(String)
    case invalidConfiguration(String)
    case permissionDenied(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notConfigured(let value): "\(value) is not configured."
        case .invalidConfiguration(let value): "Invalid configuration: \(value)."
        case .permissionDenied(let value): "Permission denied: \(value)."
        case .invalidResponse: "The service returned an invalid response."
        }
    }
}

struct AICompletionRequest: Codable, Sendable {
    let messages: [ChatMessage]
    let character: CharacterProfile
    let scenario: Scenario?
}

struct AICompletionResponse: Codable, Sendable {
    let text: String
}

@MainActor
protocol AIServiceProtocol {
    func complete(_ request: AICompletionRequest) async throws -> AICompletionResponse
}

protocol AudioServiceProtocol: Sendable {
    func requestRecordingPermission() async -> Bool
}

protocol SpeechRecognitionServiceProtocol: Sendable {
    func requestAuthorization() async -> Bool
}

@MainActor
protocol TextToSpeechServiceProtocol {
    func speak(_ text: String, voice: VoiceProfile?)
    func stop()
}

protocol ExportServiceProtocol: Sendable {
    func export(_ conversation: ConversationSummary, messages: [ChatMessage]) throws -> Data
}

protocol GalleryAccessServiceProtocol: Sendable {
    func requestAddOnlyAuthorization() async -> Bool
}
