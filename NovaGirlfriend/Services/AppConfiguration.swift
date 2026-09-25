import Foundation

struct AppConfiguration: Sendable {
  let aiBaseURL: URL?
  let appStoreID: String?
  let supportEmail: String?

  init(bundle: Bundle = .main) {
    if let value = bundle.object(forInfoDictionaryKey: "NovaAIBaseURL") as? String,
      !value.isEmpty
    {
      aiBaseURL = URL(string: value)
    } else {
      aiBaseURL = nil
    }
    appStoreID = Self.validAppStoreID(
      bundle.object(forInfoDictionaryKey: "APP_STORE_ID") as? String)
    supportEmail = Self.validSupportEmail(
      bundle.object(forInfoDictionaryKey: "SUPPORT_EMAIL") as? String)
  }

  var appStoreURL: URL? {
    appStoreID.flatMap { URL(string: "https://apps.apple.com/app/id\($0)") }
  }

  var reviewURL: URL? {
    appStoreID.flatMap { URL(string: "https://apps.apple.com/app/id\($0)?action=write-review") }
  }

  var supportURL: URL? {
    guard let supportEmail else { return nil }
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = supportEmail
    components.queryItems = [URLQueryItem(name: "subject", value: "Support")]
    return components.url
  }

  private static func validAppStoreID(_ raw: String?) -> String? {
    guard let value = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
      !value.isEmpty,
      value.allSatisfy({ $0.isASCII && $0.isNumber })
    else { return nil }
    return value
  }

  private static func validSupportEmail(_ raw: String?) -> String? {
    guard let value = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
      !value.isEmpty,
      value.range(
        of: #"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$"#,
        options: .regularExpression) != nil,
      !value.lowercased().contains("example")
    else { return nil }
    return value
  }

  func validatedAIBaseURL() throws -> URL {
    guard let aiBaseURL else {
      throw ServiceError.notConfigured("AI service URL")
    }
    guard aiBaseURL.scheme?.lowercased() == "https",
      let host = aiBaseURL.host, !host.isEmpty,
      aiBaseURL.user == nil, aiBaseURL.password == nil
    else {
      throw ServiceError.invalidConfiguration(
        "AI service URL must use HTTPS with a valid host and no embedded credentials")
    }
    return aiBaseURL
  }
}
