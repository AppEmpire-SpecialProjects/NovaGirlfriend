import CryptoKit
import Foundation

/// Authenticated encrypted client configuration. Embedded key shares raise the
/// cost of static extraction, but are not a substitute for server-side secrets.
enum EndpointVault {
  enum MediaKind {
    case speechSynthesis
    case speechRecognition
  }

  private static let shareA: [UInt8] = [
    214, 195, 69, 236, 53, 228, 157, 42, 39, 170, 122, 152,
    115, 255, 243, 87, 77, 185, 131, 140, 31, 232, 180, 146,
    30, 30, 91, 254, 231, 47, 208, 226,
  ]

  private static let shareB: [UInt8] = [
    198, 137, 20, 226, 147, 18, 185, 150, 102, 46, 202, 162,
    200, 26, 150, 6, 209, 167, 228, 141, 191, 255, 113, 203,
    240, 30, 2, 101, 107, 174, 121, 89,
  ]

  private static let hostCipher: [UInt8] = [
    43, 205, 168, 179, 10, 103, 184, 131, 227, 85, 163, 91,
    88, 236, 86, 117, 200, 34, 78, 0, 146, 84, 120, 67,
    56, 218, 236, 119, 144, 108, 32, 164, 178, 104, 226, 25,
    31, 29, 107, 110, 57,
  ]

  private static let chatPathCipher: [UInt8] = [
    100, 131, 173, 192, 136, 34, 1, 103, 230, 239, 112, 121,
    146, 70, 236, 157, 41, 11, 136, 161, 183, 88, 206, 199,
    254, 199, 169, 154, 166, 153, 36, 117, 82, 255, 195, 251,
    44, 17, 161, 78, 103, 134, 160, 164, 4, 181, 226, 221,
  ]

  private static let speechSynthesisPathCipher: [UInt8] = [
    178, 236, 2, 152, 55, 145, 98, 100, 123, 96, 213, 116,
    118, 201, 24, 251, 50, 94, 188, 87, 55, 164, 76, 140,
    207, 226, 63, 53, 89, 113, 93, 35, 185, 44, 28, 139,
    164, 14, 84, 207, 91, 134, 245, 68, 13, 161,
  ]

  private static let speechRecognitionPathCipher: [UInt8] = [
    23, 198, 52, 59, 100, 22, 114, 115, 14, 100, 114, 20,
    239, 240, 71, 59, 40, 126, 233, 208, 225, 226, 163, 78,
    36, 18, 177, 1, 235, 30, 209, 140, 242, 182, 94, 120,
    19, 48, 153, 12, 196, 199, 147, 181, 199, 6,
  ]

  private static let signingKeyCipher: [UInt8] = [
    29, 208, 37, 3, 104, 100, 95, 134, 132, 97, 117, 57,
    116, 116, 146, 51, 135, 7, 14, 35, 203, 164, 93, 17,
    82, 14, 196, 62, 128, 151, 1, 250, 197, 215, 1, 145,
    239, 73, 122, 130, 199, 154, 177, 241, 4, 228, 246, 208,
    254, 119, 86, 133, 26, 198, 91, 57, 52, 197, 5, 179,
    18, 132, 54, 150, 9, 204, 143, 137, 118, 109, 239, 83,
    183, 142, 152, 213, 226, 155, 177, 113, 236, 235, 228, 32,
    78, 193, 90, 57, 90, 53, 230, 160,
  ]

  private static let apphudCipher: [UInt8] = [
    149, 162, 66, 135, 231, 131, 63, 141, 157, 40, 158, 117,
    23, 245, 189, 24, 218, 210, 254, 103, 251, 70, 168, 189,
    117, 158, 194, 39, 209, 130, 251, 37, 223, 176, 68, 219,
    249, 18, 98, 44, 167, 188, 31, 122, 157, 26, 57, 0,
    224, 10, 255, 202, 142, 154, 235, 59, 112, 36, 245, 209,
    173, 207,
  ]

  static var apphudAPIKey: String { decode(apphudCipher) }

  /// Endpoint for chat completion traffic.
  ///
  /// `debugOverride` is honored by debug builds only and exists so harness
  /// fixtures and local diagnostics can point the client at a stub server.
  static func chatCompletionsURL(debugOverride: URL? = nil) -> URL {
    #if DEBUG
      if let debugOverride, debugOverride.scheme?.lowercased() == "https" {
        return debugOverride.appending(path: decode(chatPathCipher))
      }
    #endif
    return assemble(host: decode(hostCipher), path: decode(chatPathCipher))
  }

  /// Endpoint for media generation traffic.
  static func mediaURL(for kind: MediaKind, debugOverride: URL? = nil) -> URL {
    let cipher: [UInt8]
    switch kind {
    case .speechSynthesis: cipher = speechSynthesisPathCipher
    case .speechRecognition: cipher = speechRecognitionPathCipher
    }
    #if DEBUG
      if let debugOverride, debugOverride.scheme?.lowercased() == "https" {
        return debugOverride.appending(path: decode(cipher))
      }
    #endif
    return assemble(host: decode(hostCipher), path: decode(cipher))
  }

  /// Signing credential from which per-minute request tokens are derived.
  static var signingKey: String {
    decode(signingKeyCipher)
  }

  private static func assemble(host: String, path: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = host
    components.path = path
    guard let url = components.url else {
      preconditionFailure("Stored endpoint coordinates are invalid")
    }
    return url
  }

  private static func decode(_ cipher: [UInt8]) -> String {
    let bytes = zip(shareA, shareB).map { $0 ^ $1 }
    do {
      let box = try AES.GCM.SealedBox(combined: Data(cipher))
      let data = try AES.GCM.open(box, using: SymmetricKey(data: bytes))
      guard let value = String(data: data, encoding: .utf8) else {
        preconditionFailure("Invalid encrypted configuration encoding")
      }
      return value
    } catch {
      preconditionFailure("Encrypted configuration authentication failed")
    }
  }
}
