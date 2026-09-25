import Foundation

struct Personality: Codable, Hashable, Sendable {
    let warmth: Int
    let humor: Int
    let curiosity: Int
    let confidence: Int
    let communicationStyle: String

    init(
        warmth: Int,
        humor: Int,
        curiosity: Int,
        confidence: Int,
        communicationStyle: String
    ) {
        self.warmth = Self.clamp(warmth)
        self.humor = Self.clamp(humor)
        self.curiosity = Self.clamp(curiosity)
        self.confidence = Self.clamp(confidence)
        self.communicationStyle = communicationStyle
    }

    private static func clamp(_ value: Int) -> Int {
        min(max(value, 0), 100)
    }
}
