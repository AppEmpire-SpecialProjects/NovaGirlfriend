import Foundation

// Transport-only fixtures: never compiled into the application or written to Keychain.
@MainActor enum RecordingController {
  static func remove(_ file: String) throws {}
}

final class FixtureURLProtocol: URLProtocol {
  static var status = 200
  static var body = Data(
    "{\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"Transport fixture\"}}]}".utf8)
  static var failure: URLError?
  static var delayed = false
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
    DispatchQueue.main.asyncAfter(deadline: .now() + (Self.delayed ? 5 : 0), execute: work)
  }

  override func stopLoading() {
    pending?.cancel()
    pending = nil
  }

  /// Custom URL protocols move `httpBody` into a stream; read either form.
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

@main struct TransportChecks {
  static let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
  static let expectedToken =
    "llm_totp_wXcBIGySKgE_kgmUmHgwaJ85-zSHKTKm1paJwGARGK91oc5N1M545NY"

  @MainActor static func main() async throws {
    let bundle = Bundle(path: CommandLine.arguments[1])!
    let config = AppConfiguration(bundle: bundle)
    let sessionConfig = URLSessionConfiguration.ephemeral
    sessionConfig.protocolClasses = [FixtureURLProtocol.self]
    let session = URLSession(configuration: sessionConfig)
    defer { session.invalidateAndCancel() }
    let service = URLSessionAIService(configuration: config, session: session) { fixedDate }
    let content = ProductContentRepository()
    let character = content.characters[0]
    guard let scenario = content.scenarios.first else {
      preconditionFailure("Catalog must expose at least one scenario")
    }
    let history: [ChatMessage] = [
      ChatMessage(
        id: UUID(), conversationID: UUID(), role: .user, text: "Hi there",
        createdAt: .now, deliveryState: .sent),
      ChatMessage(
        id: UUID(), conversationID: UUID(), role: .assistant, text: "Hello!",
        createdAt: .now, deliveryState: .sent),
      ChatMessage(
        id: UUID(), conversationID: UUID(), role: .user, text: "What do you see?",
        createdAt: .now, deliveryState: .sent),
    ]
    let instruction = ChatMessage(
      id: UUID(), conversationID: UUID(), role: .system, text: "Extra guidance block.",
      createdAt: .now, deliveryState: .sent)

    PremiumStore.shared.isPremium = false
    for blocked in [
      AICompletionRequest(messages: history, character: character, scenario: scenario),
      AICompletionRequest(
        messages: history, character: character, scenario: nil, photoJPEGData: Data([0xFF])),
    ] {
      do {
        _ = try await service.complete(blocked)
        preconditionFailure("Paid AI feature must be rejected before networking")
      } catch is AccessPolicy.Denial {}
    }
    precondition(FixtureURLProtocol.captured == nil)
    PremiumStore.shared.isPremium = true
    print("PASS: scenario and photo AI are denied at transport boundary before network access")

    // 1. Persona chat request with a photo on the latest user turn.
    let photo = Data([0xFF, 0xD8, 0xFF, 0xE0]) + Data("vision".utf8)
    let request = AICompletionRequest(
      messages: history + [instruction], character: character, scenario: scenario,
      photoJPEGData: photo)
    let response = try await service.complete(request)
    precondition(response.text == "Transport fixture")
    precondition(
      FixtureURLProtocol.captured?.url?.absoluteString
        == "https://transport.invalid/v1/chat/completions")
    precondition(FixtureURLProtocol.captured?.httpMethod == "POST")
    precondition(
      FixtureURLProtocol.captured?.value(forHTTPHeaderField: "Authorization")
        == "Bearer \(expectedToken)")
    precondition(
      FixtureURLProtocol.captured?.value(forHTTPHeaderField: "Content-Type")
        == "application/json")

    let capturedRequest = FixtureURLProtocol.captured!
    let wire =
      try JSONSerialization.jsonObject(with: FixtureURLProtocol.body(of: capturedRequest))
      as! [String: Any]
    let messages = wire["messages"] as! [[String: Any]]
    precondition(messages.count == 4)
    precondition(messages[0]["role"] as! String == "system")
    let systemText = messages[0]["content"] as! String
    precondition(systemText.contains(character.name))
    precondition(systemText.contains(scenario.systemContext))
    precondition(systemText.contains("Extra guidance block."))
    precondition(messages[1]["role"] as! String == "user")
    precondition(messages[1]["content"] as! String == "Hi there")
    precondition(messages[2]["role"] as! String == "assistant")
    precondition(messages[2]["content"] as! String == "Hello!")
    precondition(messages[3]["role"] as! String == "user")
    let parts = messages[3]["content"] as! [[String: Any]]
    precondition(parts.count == 2)
    precondition(parts[0]["type"] as! String == "text")
    precondition(parts[0]["text"] as! String == "What do you see?")
    precondition(parts[1]["type"] as! String == "image_url")
    let imagePayload = parts[1]["image_url"] as! [String: Any]
    let dataURL = imagePayload["url"] as! String
    precondition(dataURL.hasPrefix("data:image/jpeg;base64,"))
    precondition(dataURL.hasSuffix(photo.base64EncodedString()))

    // 2. Utility request: no persona block, plain text content only.
    let utility = AICompletionRequest(
      messages: [
        ChatMessage(
          id: UUID(), conversationID: UUID(), role: .user, text: "List facts",
          createdAt: .now, deliveryState: .sent)
      ],
      character: character, scenario: nil, includesPersona: false)
    _ = try await service.complete(utility)
    let utilityWire =
      try JSONSerialization.jsonObject(
        with: FixtureURLProtocol.body(of: FixtureURLProtocol.captured!)
      ) as! [String: Any]
    let utilityMessages = utilityWire["messages"] as! [[String: Any]]
    precondition(utilityMessages.count == 1)
    precondition(utilityMessages[0]["role"] as! String == "user")
    precondition(utilityMessages[0]["content"] as! String == "List facts")

    // 3. Production endpoint coordinates (no debug override).
    precondition(
      EndpointVault.chatCompletionsURL().absoluteString
        == "https://llmapps.space/v1/chat/completions")

    // 4. Error paths.
    FixtureURLProtocol.status = 503
    do {
      _ = try await service.complete(request)
      preconditionFailure("HTTP failure must not decode as success")
    } catch ServiceError.invalidResponse {}
    FixtureURLProtocol.status = 200
    FixtureURLProtocol.body = Data("not JSON".utf8)
    do {
      _ = try await service.complete(request)
      preconditionFailure("Malformed JSON must fail")
    } catch is DecodingError {}
    FixtureURLProtocol.body = Data("{\"choices\":[]}".utf8)
    do {
      _ = try await service.complete(request)
      preconditionFailure("Empty choices must fail")
    } catch ServiceError.invalidResponse {}
    FixtureURLProtocol.failure = URLError(.timedOut)
    do {
      _ = try await service.complete(request)
      preconditionFailure("Timeout must propagate")
    } catch let error as URLError {
      precondition(error.code == .timedOut)
    }
    FixtureURLProtocol.failure = nil
    FixtureURLProtocol.delayed = true
    let task = Task { try await service.complete(request) }
    try await Task.sleep(for: .milliseconds(100))
    task.cancel()
    do {
      _ = try await task.value
      preconditionFailure("Cancelled URLSession request must not succeed")
    } catch let error as URLError {
      precondition(error.code == .cancelled)
    } catch is CancellationError {}
    print(
      "PASS: chat adapter URL/auth/content-type, wire mapping (persona merge, roles, "
        + "vision content, utility mode), deterministic token, HTTP503 rejection, "
        + "malformed JSON, empty choices, timeout propagation, active request cancellation")
    print("LIMIT: URLProtocol fixtures do not prove live server availability")
  }
}
