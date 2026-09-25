import Foundation

struct VoiceProfile: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let displayName: String
    let localeIdentifier: String
    let providerIdentifier: String?
    let speakingRate: Double
    let pitch: Double
}
