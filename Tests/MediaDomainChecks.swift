import Foundation

// Media fixtures: never compiled into the application.
final class MediaFixtureURLProtocol: URLProtocol {
  static var status = 200
  static var body = Data("{}".utf8)
  static var failure: URLError?
  static var captured: URLRequest?
  private var pending: DispatchWorkItem?

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    Self.captured = request
    let work = DispatchWorkItem { [weak self] in
      guard let self else { return }
      if let error = Self.failure {
        client?.urlProtocol(self, didFailWithError: error)
      } else {
        let response = HTTPURLResponse(
          url: request.url!, statusCode: Self.status, httpVersion: "HTTP/1.1",
          headerFields: ["Content-Type": "application/json"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.body)
        client?.urlProtocolDidFinishLoading(self)
      }
    }
    pending = work
    DispatchQueue.main.asyncAfter(deadline: .now(), execute: work)
  }

  override func stopLoading() {
    pending?.cancel()
    pending = nil
  }

  static func body(of request: URLRequest) -> Data {
    if let body = request.httpBody { return body }
    guard let stream = request.httpBodyStream else { return Data() }
    stream.open()
    defer { stream.close() }
    var data = Data()
    let capacity = 4096
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
    defer { buffer.deallocate() }
    while stream.hasBytesAvailable {
      let read = stream.read(buffer, maxLength: capacity)
      if read <= 0 { break }
      data.append(buffer, count: read)
    }
    return data
  }
}

@main struct MediaChecks {
  static let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
  static let expectedToken =
    "llm_totp_wXcBIGySKgE_kgmUmHgwaJ85-zSHKTKm1paJwGARGK91oc5N1M545NY"

  @MainActor static func main() async throws {
    checkTokens()
    checkEndpoints()
    checkChunker()
    await checkSpeechPreparation()
    try await checkMediaClient()
    print(
      "PASS: deterministic signing token (minute window), vault coordinates, "
        + "speech chunking, reply-voice buffering, "
        + "synthesis/recognition wire contract, pre-signed download")
    print("LIMIT: URLProtocol fixtures do not prove live media availability")
  }

  static func checkTokens() {
    let token = TOTPTokenProvider.token(at: fixedDate)
    precondition(token == expectedToken)
    // fixedDate sits 20 s inside its window (window boundary 1_700_000_040).
    precondition(TOTPTokenProvider.token(at: fixedDate.addingTimeInterval(39)) == expectedToken)
    precondition(TOTPTokenProvider.token(at: fixedDate.addingTimeInterval(40)) != expectedToken)
    precondition(!token.contains("="))
  }

  static func checkEndpoints() {
    let key = EndpointVault.signingKey
    precondition(key.hasPrefix("llm_totp_"))
    precondition(key.count == 64)
    precondition(
      EndpointVault.chatCompletionsURL().absoluteString
        == "https://llmapps.space/v1/chat/completions")
    precondition(
      EndpointVault.mediaURL(for: .speechSynthesis).absoluteString
        == "https://llmapps.space/media/text2speech")
    precondition(
      EndpointVault.mediaURL(for: .speechRecognition).absoluteString
        == "https://llmapps.space/media/speech2text")
    let override = URL(string: "https://media-fixture.invalid")!
    precondition(
      EndpointVault.mediaURL(for: .speechSynthesis, debugOverride: override).absoluteString
        == "https://media-fixture.invalid/media/text2speech")
  }

  /// prepare() must buffer every chunk of one reply before its reveal and
  /// never speak, and it must fail closed (no throw, no fallback) when the
  /// network fails, so the reply can be revealed immediately instead.
  @MainActor static func checkSpeechPreparation() async {
    let sessionConfig = URLSessionConfiguration.ephemeral
    sessionConfig.protocolClasses = [MediaFixtureURLProtocol.self]
    let session = URLSession(configuration: sessionConfig)
    defer { session.invalidateAndCancel() }
    let fallback = SystemTextToSpeechService()
    let service = RemoteVoiceSpeechService(
      client: MediaGenerationClient(session: session) { fixedDate }, fallback: fallback)
    defer { service.stop() }

    MediaFixtureURLProtocol.status = 200
    MediaFixtureURLProtocol.failure = nil
    MediaFixtureURLProtocol.body = Data(
      """
      {"id":"gen-p","media_type":"speech","urls":["https://cdn.example.invalid/prepared.mp3"],"generation_time_ms":100,"estimated_cost_cents":0.1}
      """.utf8)
    let prepared = await service.prepare("Hello there", voice: nil, timeout: 5)
    precondition(prepared, "Fully-fixtured preparation must buffer the reply audio")
    precondition(fallback.spokenText == nil, "Preparation must not speak or fall back")

    MediaFixtureURLProtocol.failure = URLError(.notConnectedToInternet)
    let failed = await service.prepare("Hello again", voice: nil, timeout: 5)
    precondition(!failed, "Network failure must fail preparation without throwing")
    precondition(fallback.spokenText == nil, "Failed preparation must stay silent")
    precondition(service.loadingText == nil, "Preparation never reports UI loading")
    MediaFixtureURLProtocol.failure = nil
  }

  static func checkChunker() {
    precondition(TextChunker.chunks(from: "   ").isEmpty)
    precondition(TextChunker.chunks(from: "Hello") == ["Hello"])
    precondition(TextChunker.chunks(from: String(repeating: "a", count: 500)).count == 1)
    let oversized = TextChunker.chunks(from: String(repeating: "a", count: 501))
    precondition(oversized.count == 2)
    precondition(oversized.allSatisfy { $0.count <= 500 })
    precondition(oversized.joined() == String(repeating: "a", count: 501))
    let words = (0..<120).map { "word\($0)" }.joined(separator: " ")
    let chunks = TextChunker.chunks(from: words)
    precondition(chunks.count > 1)
    precondition(chunks.allSatisfy { $0.count <= 500 })
    precondition(chunks.joined(separator: " ") == words)
  }

  @MainActor static func checkMediaClient() async throws {
    let sessionConfig = URLSessionConfiguration.ephemeral
    sessionConfig.protocolClasses = [MediaFixtureURLProtocol.self]
    let session = URLSession(configuration: sessionConfig)
    defer { session.invalidateAndCancel() }
    let client = MediaGenerationClient(session: session) { fixedDate }

    MediaFixtureURLProtocol.body = Data(
      """
      {"id":"gen-1","media_type":"speech","urls":["https://cdn.example.invalid/voice.mp3"],"generation_time_ms":3316,"estimated_cost_cents":0.7}
      """.utf8)
    let generation = try await client.synthesizeSpeech(
      text: "Hello there", voiceID: "girlfriend_1_speech02")
    precondition(generation.id == "gen-1")
    precondition(generation.mediaType == "speech")
    precondition(
      generation.urls.first?.absoluteString == "https://cdn.example.invalid/voice.mp3")
    precondition(generation.generationTimeMilliseconds == 3316)
    precondition(generation.estimatedCostCents == 0.7)

    var request = MediaFixtureURLProtocol.captured!
    precondition(request.url?.absoluteString == "https://llmapps.space/media/text2speech")
    precondition(request.httpMethod == "POST")
    precondition(
      request.value(forHTTPHeaderField: "Authorization") == "Bearer \(expectedToken)")
    precondition(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    var wire =
      try JSONSerialization.jsonObject(with: MediaFixtureURLProtocol.body(of: request))
      as! [String: Any]
    precondition(wire["text"] as! String == "Hello there")
    precondition(wire["voice_id"] as! String == "girlfriend_1_speech02")
    precondition(wire["voice_speed"] as! Double == 1.0)
    precondition(wire["model"] as! String == "default")

    MediaFixtureURLProtocol.body = Data("{\"text\":\"  Hello world  \"}".utf8)
    let audio = Data([0x00, 0x01, 0x02, 0xFF]) + Data("m4a".utf8)
    let transcript = try await client.transcribeSpeech(audio: audio, contentType: "audio/m4a")
    precondition(transcript == "Hello world")
    request = MediaFixtureURLProtocol.captured!
    precondition(request.url?.absoluteString == "https://llmapps.space/media/speech2text")
    wire =
      try JSONSerialization.jsonObject(with: MediaFixtureURLProtocol.body(of: request))
      as! [String: Any]
    precondition(wire["audio_data"] as! String == audio.base64EncodedString())
    precondition(wire["content_type"] as! String == "audio/m4a")
    precondition(wire["task"] as! String == "transcribe")
    precondition(wire["model"] as! String == "default")
    precondition(wire["language"] == nil)

    MediaFixtureURLProtocol.body = Data("{\"text\":\"   \"}".utf8)
    do {
      _ = try await client.transcribeSpeech(audio: audio, contentType: "audio/m4a")
      preconditionFailure("Blank transcripts must be rejected")
    } catch ServiceError.invalidResponse {}

    MediaFixtureURLProtocol.status = 403
    do {
      _ = try await client.synthesizeSpeech(text: "Hi", voiceID: "girlfriend_1_speech02")
      preconditionFailure("HTTP failure must not decode as success")
    } catch ServiceError.invalidResponse {}
    MediaFixtureURLProtocol.status = 200

    PremiumStore.shared.isPremium = false
    defer { PremiumStore.shared.isPremium = true }
    MediaFixtureURLProtocol.captured = nil
    do {
      _ = try await client.synthesizeSpeech(text: "Paid voice", voiceID: "girlfriend_1_speech02")
      preconditionFailure("Free remote synthesis must be rejected")
    } catch is AccessPolicy.Denial {}
    do {
      _ = try await client.transcribeSpeech(audio: audio, contentType: "audio/m4a")
      preconditionFailure("Free remote recognition must be rejected")
    } catch is AccessPolicy.Denial {}
    precondition(MediaFixtureURLProtocol.captured == nil)
    print("PASS: remote TTS/STT denied at service boundary without a network request")

    let audioBytes = Data("mp3-bytes".utf8)
    MediaFixtureURLProtocol.body = audioBytes
    let downloaded = try await client.download(
      URL(string: "https://cdn.example.invalid/voice.mp3")!)
    precondition(downloaded == audioBytes)
    request = MediaFixtureURLProtocol.captured!
    precondition(request.httpMethod == "GET")
    precondition(request.value(forHTTPHeaderField: "Authorization") == nil)
  }
}
