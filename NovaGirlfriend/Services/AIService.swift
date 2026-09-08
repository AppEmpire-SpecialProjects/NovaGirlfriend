import Foundation

@MainActor
final class URLSessionAIService: AIServiceProtocol {
  private let configuration: AppConfiguration
  private let session: URLSession
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  init(configuration: AppConfiguration, session: URLSession = .shared) {
    self.configuration = configuration
    self.session = session
  }

  func complete(_ request: AICompletionRequest) async throws -> AICompletionResponse {
    let baseURL = try configuration.validatedAIBaseURL()
    let endpoint = baseURL.appending(path: "v1/completions")
    var urlRequest = URLRequest(url: endpoint)
    guard let token = try AICredentialStore.load(), !token.isEmpty else {
      throw ServiceError.notConfigured("AI access token")
    }
    urlRequest.timeoutInterval = 60
    urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.httpBody = try encoder.encode(request)

    let (data, response) = try await session.data(for: urlRequest)
    guard let httpResponse = response as? HTTPURLResponse,
      200..<300 ~= httpResponse.statusCode
    else {
      throw ServiceError.invalidResponse
    }
    return try decoder.decode(AICompletionResponse.self, from: data)
  }
}
