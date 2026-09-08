import Foundation

// Transport-only fixtures: never compiled into the application or written to Keychain.
@MainActor enum AICredentialStore {
  static func load() throws -> String? { "transport-test-token" }
}

@MainActor enum RecordingController {
  static func remove(_ file: String) throws {}
}

final class FixtureURLProtocol: URLProtocol {
  static var status = 200
  static var body = Data("{\"text\":\"Transport fixture\"}".utf8)
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
}

@main struct TransportChecks {
  @MainActor static func main() async throws {
    let bundle = Bundle(path: CommandLine.arguments[1])!
    let config = AppConfiguration(bundle: bundle)
    let sessionConfig = URLSessionConfiguration.ephemeral
    sessionConfig.protocolClasses = [FixtureURLProtocol.self]
    let session = URLSession(configuration: sessionConfig)
    defer { session.invalidateAndCancel() }
    let service = URLSessionAIService(configuration: config, session: session)
    let character = ProductContentRepository().characters[0]
    let request = AICompletionRequest(messages: [], character: character, scenario: nil)
    let response = try await service.complete(request)
    precondition(response.text == "Transport fixture")
    precondition(FixtureURLProtocol.captured?.url?.absoluteString == "https://transport.invalid/v1/completions")
    precondition(FixtureURLProtocol.captured?.httpMethod == "POST")
    precondition(FixtureURLProtocol.captured?.value(forHTTPHeaderField: "Authorization") == "Bearer transport-test-token")
    precondition(FixtureURLProtocol.captured?.value(forHTTPHeaderField: "Content-Type") == "application/json")
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
    print("PASS: URLSession adapter HTTPS endpoint, POST/auth/content-type, success decode, HTTP503 rejection, malformed JSON, timeout propagation, active request cancellation")
    print("LIMIT: URLProtocol fixtures do not prove live server availability or Keychain authorization")
  }
}
