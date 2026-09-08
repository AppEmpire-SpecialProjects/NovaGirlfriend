import Foundation

enum CharacterOrigin: String, Codable, Sendable {
    case builtIn
    case custom
}

enum CharacterGender: String, Codable, CaseIterable, Identifiable, Sendable {
    case female = "Female"
    case male = "Male"
    case nonBinary = "Non-binary"

    var id: String { rawValue }
}

struct CharacterProfile: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var gender: CharacterGender
    var tagline: String
    var biography: String
    var avatarAssetName: String?
    var symbolName: String
    var accentHex: String
    var personality: Personality
    var preferredScenarioID: String?
    var voice: VoiceProfile?
    var origin: CharacterOrigin

    init(
        id: UUID,
        name: String,
        gender: CharacterGender = .female,
        tagline: String,
        biography: String,
        avatarAssetName: String? = nil,
        symbolName: String,
        accentHex: String,
        personality: Personality,
        preferredScenarioID: String? = nil,
        voice: VoiceProfile? = nil,
        origin: CharacterOrigin
    ) {
        self.id = id
        self.name = name
        self.gender = gender
        self.tagline = tagline
        self.biography = biography
        self.avatarAssetName = avatarAssetName
        self.symbolName = symbolName
        self.accentHex = accentHex
        self.personality = personality
        self.preferredScenarioID = preferredScenarioID
        self.voice = voice
        self.origin = origin
    }
}
