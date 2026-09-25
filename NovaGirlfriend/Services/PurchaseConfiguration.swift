import Foundation

enum PurchaseConfiguration {
  static var apiKey: String { EndpointVault.apphudAPIKey }

  static var productIDs: Set<String> {
    let rows: [[UInt8]] = [
      [
        227, 194, 219, 204, 131, 234, 196, 223, 193, 203, 223, 196, 200, 195, 201, 131, 204, 221,
        221, 131, 250, 200, 200, 198,
      ],
      [
        227, 194, 219, 204, 131, 234, 196, 223, 193, 203, 223, 196, 200, 195, 201, 131, 204, 221,
        221, 131, 224, 194, 195, 217, 197,
      ],
      [
        227, 194, 219, 204, 131, 234, 196, 223, 193, 203, 223, 196, 200, 195, 201, 131, 204, 221,
        221, 131, 244, 200, 204, 223,
      ],
      [
        227, 194, 219, 204, 131, 234, 196, 223, 193, 203, 223, 196, 200, 195, 201, 131, 204, 221,
        221, 131, 250, 200, 200, 198, 249, 223, 196, 204, 193,
      ],
      [
        227, 194, 219, 204, 131, 234, 196, 223, 193, 203, 223, 196, 200, 195, 201, 131, 204, 221,
        221, 131, 225, 196, 203, 200, 217, 196, 192, 200,
      ],
    ]
    return Set(rows.map { String(decoding: $0.map { $0 ^ 173 }, as: UTF8.self) })
  }

  static var forceFallback: Bool {
    #if DEBUG
      ProcessInfo.processInfo.arguments.contains("--premium-force-fallback")
    #else
      false
    #endif
  }
}
