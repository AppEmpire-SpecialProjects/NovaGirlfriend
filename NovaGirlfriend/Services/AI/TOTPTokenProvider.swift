import CryptoKit
import Foundation

/// Derives the per-minute bearer credential used to sign remote service
/// requests from the stored signing key.
///
/// The key has the shape `<scheme><prefix>_<secret>` where the secret is a
/// base64url string. A token is the key prefix followed by the base64url
/// HMAC-SHA256 signature of the current minute counter (big-endian) keyed by
/// the decoded secret. Tokens are valid for roughly one minute and are
/// regenerated for every request.
enum TOTPTokenProvider {
  static func token(at date: Date = .now, key: String = EndpointVault.signingKey) -> String {
    let prefix = String(key.prefix(20))
    let secret = String(key.dropFirst(21))
    guard !prefix.isEmpty, !secret.isEmpty,
      let secretData = Data(base64Encoded: secret.base64URLToBase64())
    else { return "" }
    let minutes = UInt64(date.timeIntervalSince1970 / 60)
    let message = withUnsafeBytes(of: minutes.bigEndian) { Data($0) }
    let signature = HMAC<SHA256>.authenticationCode(
      for: message,
      using: SymmetricKey(data: secretData))
    return prefix + "_" + Data(signature).base64URLEncodedString()
  }
}

extension String {
  /// Converts a base64url string (unpadded `-`/`_` alphabet) into the
  /// standard base64 alphabet required by `Data(base64Encoded:)`.
  func base64URLToBase64() -> String {
    var standard = replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    while standard.count % 4 != 0 {
      standard += "="
    }
    return standard
  }
}

extension Data {
  /// Standard base64 output converted to the unpadded base64url alphabet.
  func base64URLEncodedString() -> String {
    base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}
