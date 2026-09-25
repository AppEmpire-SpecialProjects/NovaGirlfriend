import Foundation

/// A completed remote media generation with its download URLs and usage
/// metadata.
struct MediaGeneration: Equatable, Sendable {
  let id: String
  let mediaType: String
  let urls: [URL]
  let generationTimeMilliseconds: Int?
  let estimatedCostCents: Double?
}

/// Client for remote media generation: companion speech synthesis and cloud
/// speech recognition. Endpoint coordinates and signing credentials come from
/// `EndpointVault`/`TOTPTokenProvider`; generated media URLs are pre-signed and
/// require no authorization.
@MainActor
final class MediaGenerationClient {
  private let session: URLSession
  private let now: () -> Date
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  nonisolated init(session: URLSession = .shared, now: @escaping () -> Date = Date.init) {
    self.session = session
    self.now = now
  }

  /// Synthesizes one speakable chunk (at most `TextChunker.speechLimit`
  /// characters) with a companion voice.
  func synthesizeSpeech(
    text: String, voiceID: String, speed: Double = 1.0
  ) async throws -> MediaGeneration {
    let body = SpeechSynthesisWireRequest(text: text, voiceID: voiceID, voiceSpeed: speed)
    let data = try await post(.speechSynthesis, body: body)
    return try decoder.decode(MediaGeneration.self, from: data)
  }

  /// Transcribes a short voice recording and returns its text.
  func transcribeSpeech(
    audio: Data, contentType: String, language: String? = nil
  ) async throws -> String {
    let body = SpeechRecognitionWireRequest(
      audioBase64: audio.base64EncodedString(),
      contentType: contentType,
      language: language)
    let data = try await post(.speechRecognition, body: body)
    let wire = try decoder.decode(SpeechRecognitionWireResponse.self, from: data)
    guard let text = wire.text?.trimmingCharacters(in: .whitespacesAndNewlines),
      !text.isEmpty
    else { throw ServiceError.invalidResponse }
    return text
  }

  /// Downloads generated media. The returned URLs are pre-signed and must be
  /// requested without an authorization header.
  func download(_ url: URL) async throws -> Data {
    let (data, response) = try await session.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse,
      200..<300 ~= httpResponse.statusCode
    else { throw ServiceError.invalidResponse }
    return data
  }

  private func post<Body: Encodable>(
    _ kind: EndpointVault.MediaKind, body: Body
  ) async throws -> Data {
    try AccessPolicy.shared.require(.remoteSpeech)
    let endpoint = EndpointVault.mediaURL(for: kind)
    var urlRequest = URLRequest(url: endpoint)
    urlRequest.timeoutInterval = 60
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue(
      "Bearer \(TOTPTokenProvider.token(at: now()))",
      forHTTPHeaderField: "Authorization")
    urlRequest.httpBody = try encoder.encode(body)
    let (data, response) = try await session.data(for: urlRequest)
    guard let httpResponse = response as? HTTPURLResponse,
      200..<300 ~= httpResponse.statusCode
    else { throw ServiceError.invalidResponse }
    return data
  }
}

// MARK: - Wire contract

private struct SpeechSynthesisWireRequest: Encodable {
  let text: String
  let voiceID: String
  let voiceSpeed: Double
  let model = "default"

  private enum CodingKeys: String, CodingKey {
    case text
    case voiceID = "voice_id"
    case voiceSpeed = "voice_speed"
    case model
  }
}

private struct SpeechRecognitionWireRequest: Encodable {
  let audioBase64: String
  let contentType: String
  let task = "transcribe"
  let model = "default"
  let language: String?

  private enum CodingKeys: String, CodingKey {
    case audioBase64 = "audio_data"
    case contentType = "content_type"
    case task
    case model
    case language
  }
}

private struct SpeechRecognitionWireResponse: Decodable {
  let text: String?
}

extension MediaGeneration: Decodable {
  private enum CodingKeys: String, CodingKey {
    case id
    case mediaType = "media_type"
    case urls
    case generationTimeMilliseconds = "generation_time_ms"
    case estimatedCostCents = "estimated_cost_cents"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    mediaType = try container.decode(String.self, forKey: .mediaType)
    urls = try container.decode([URL].self, forKey: .urls)
    generationTimeMilliseconds = try container.decodeIfPresent(
      Int.self, forKey: .generationTimeMilliseconds)
    estimatedCostCents = try container.decodeIfPresent(
      Double.self, forKey: .estimatedCostCents)
  }
}
