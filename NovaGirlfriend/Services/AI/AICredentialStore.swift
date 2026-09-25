import Foundation
import Security

struct AICredentialStore {
  private static var query: [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: "NovaGirlfriend.AI",
      kSecAttrAccount as String: "access-token",
    ]
  }

  static func load() throws -> String? {
    var query = query
    query[kSecReturnData as String] = true
    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecItemNotFound { return nil }
    guard status == errSecSuccess, let data = result as? Data else {
      throw ServiceError.invalidConfiguration("Unable to read AI credential from Keychain")
    }
    return String(data: data, encoding: .utf8)
  }

  static func save(_ token: String) throws {
    let token = token.trimmingCharacters(in: .whitespacesAndNewlines)
    let deletion = SecItemDelete(query as CFDictionary)
    guard deletion == errSecSuccess || deletion == errSecItemNotFound else {
      throw ServiceError.invalidConfiguration("Unable to update Keychain")
    }
    guard !token.isEmpty else { return }
    var query = query
    query[kSecValueData as String] = Data(token.utf8)
    query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else {
      throw ServiceError.invalidConfiguration("Unable to save AI credential")
    }
  }
}
