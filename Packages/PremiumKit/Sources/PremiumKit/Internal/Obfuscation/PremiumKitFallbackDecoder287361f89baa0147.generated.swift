// Generated authenticated fallback decoder. Regenerate from a clean clone.
import CryptoKit
import Foundation

internal enum PremiumKitFallbackDecoder287361f89baa0147 {
    private static let headerBytes = 16
    private static let positions: [Int] = [9, 13, 29, 2, 4, 6, 16, 20, 14, 18, 22, 15, 24, 17, 31, 7, 5, 21, 27, 10, 11, 25, 28, 1, 8, 23, 26, 12, 3, 19, 30, 0]
    private static let orders: [[Int]] = [[0, 4, 24, 9, 17, 27, 16, 25, 6, 13, 29, 12, 31, 2, 10, 26, 21, 11, 14, 22, 18, 20, 19, 15, 30, 7, 28, 5, 3, 1, 8, 23], [22, 6, 18, 25, 28, 17, 7, 9, 14, 11, 20, 4, 1, 31, 30, 10, 2, 0, 21, 27, 23, 26, 16, 13, 24, 15, 8, 5, 29, 19, 12, 3], [12, 19, 29, 22, 14, 7, 9, 25, 6, 8, 28, 10, 30, 31, 1, 0, 23, 4, 24, 21, 26, 17, 20, 18, 2, 13, 16, 11, 3, 15, 27, 5], [1, 16, 6, 30, 26, 18, 9, 2, 25, 24, 10, 20, 27, 14, 28, 22, 3, 15, 31, 17, 4, 29, 19, 21, 7, 0, 11, 8, 13, 12, 5, 23], [4, 26, 25, 28, 30, 2, 20, 6, 13, 15, 12, 5, 19, 21, 0, 14, 7, 9, 27, 3, 24, 22, 1, 8, 17, 16, 29, 10, 18, 23, 11, 31], [15, 5, 25, 27, 13, 2, 22, 7, 26, 12, 20, 16, 0, 24, 21, 28, 18, 19, 4, 3, 10, 11, 29, 31, 1, 8, 9, 23, 6, 17, 14, 30], [22, 8, 21, 2, 9, 16, 25, 3, 6, 23, 26, 31, 15, 5, 27, 24, 4, 28, 0, 19, 1, 13, 29, 11, 20, 17, 7, 12, 14, 30, 10, 18], [29, 24, 20, 7, 19, 15, 23, 6, 3, 30, 12, 14, 28, 16, 8, 22, 5, 27, 18, 26, 9, 1, 4, 0, 17, 21, 10, 31, 25, 2, 11, 13]]

    static func decrypt(_ encryptedData: Data) -> Data? {
        guard encryptedData.count > headerBytes else { return nil }
        let payload = encryptedData.subdata(in: headerBytes..<encryptedData.count)
        let fragments: [[UInt8]] = [Segment1a6a4ca35806bf83.nibbles, Segmenta51bf171ef4dd674.nibbles, Segment4c4649147e0c3550.nibbles, Segment01c29334b819c8bc.nibbles, Segmentae76525f9c7283d9.nibbles, Segment0a671fc1b3ac7872.nibbles, Segment9147bc4b9693a6f0.nibbles, Segment88184541d2bbbc7e.nibbles]
        guard fragments.count == orders.count,
              fragments.allSatisfy({ $0.count == positions.count }) else { return nil }
        var permuted = [UInt8](repeating: 0, count: positions.count)
        for pair in stride(from: 0, to: fragments.count, by: 2) {
            var share = [UInt8](repeating: 0, count: positions.count)
            for slot in 0..<positions.count {
                share[orders[pair][slot]] = fragments[pair][slot] << 4
            }
            for slot in 0..<positions.count {
                share[orders[pair + 1][slot]] |= fragments[pair + 1][slot]
            }
            for index in share.indices {
                permuted[index] ^= share[index]
            }
        }
        var keyBytes = [UInt8](repeating: 0, count: positions.count)
        for (position, originalIndex) in positions.enumerated() {
            guard keyBytes.indices.contains(originalIndex) else { return nil }
            keyBytes[originalIndex] = permuted[position]
        }
        let key = SymmetricKey(data: Data(keyBytes))
        guard let sealedBox = try? AES.GCM.SealedBox(combined: payload) else { return nil }
        return try? AES.GCM.open(sealedBox, using: key)
    }
}
