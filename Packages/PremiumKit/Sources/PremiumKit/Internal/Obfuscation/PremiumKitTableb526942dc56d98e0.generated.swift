// Generated placement table. Regenerate from a clean clone; do not edit.
internal enum PremiumKitTableb526942dc56d98e0 {
    private static let stream: [UInt8] = [99, 244, 151, 232, 89, 114, 204, 33, 110, 82, 2, 99, 250, 126, 16]
    private static let rows: [[UInt8]] = [[12, 154, 245, 135, 56, 0, 168, 72, 0, 53], [14, 149, 254, 134], [0, 155, 249, 155, 44, 31, 173, 67, 2, 55], [1, 149, 249, 134, 60, 0]]

    @inline(never)
    static func placement(_ index: Int) -> String {
        guard rows.indices.contains(index) else { return "" }
        let row = rows[index]
        let bytes = row.enumerated().map { offset, value in
            value ^ stream[offset % stream.count]
        }
        return String(decoding: bytes, as: UTF8.self)
    }
}
