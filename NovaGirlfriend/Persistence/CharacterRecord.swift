import Foundation
import SwiftData

@Model
final class CharacterRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    var genderRawValue: String = CharacterGender.female.rawValue
    var tagline: String
    var biography: String
    var avatarAssetName: String?
    var symbolName: String
    var accentHex: String
    var originRawValue: String
    var warmth: Int
    var humor: Int
    var curiosity: Int
    var confidence: Int
    var communicationStyle: String
    var preferredScenarioID: String?
    var voiceID: String?
    var voiceDisplayName: String?
    var voiceLocaleIdentifier: String?
    var voiceProviderIdentifier: String?
    var voiceSpeakingRate: Double?
    var voicePitch: Double?
    var createdAt: Date

    init(profile: CharacterProfile, createdAt: Date = .now) {
        id = profile.id
        name = profile.name
        tagline = profile.tagline
        biography = profile.biography
        avatarAssetName = profile.avatarAssetName
        symbolName = profile.symbolName
        accentHex = profile.accentHex
        originRawValue = profile.origin.rawValue
        warmth = profile.personality.warmth
        humor = profile.personality.humor
        curiosity = profile.personality.curiosity
        confidence = profile.personality.confidence
        communicationStyle = profile.personality.communicationStyle
        preferredScenarioID = profile.preferredScenarioID
        self.createdAt = createdAt
        update(with: profile)
    }

    func update(with profile: CharacterProfile) {
        name = profile.name
        genderRawValue = profile.gender.rawValue
        tagline = profile.tagline
        biography = profile.biography
        avatarAssetName = profile.avatarAssetName
        symbolName = profile.symbolName
        accentHex = profile.accentHex
        originRawValue = CharacterOrigin.custom.rawValue
        warmth = profile.personality.warmth
        humor = profile.personality.humor
        curiosity = profile.personality.curiosity
        confidence = profile.personality.confidence
        communicationStyle = profile.personality.communicationStyle
        preferredScenarioID = profile.preferredScenarioID
        voiceID = profile.voice?.id
        voiceDisplayName = profile.voice?.displayName
        voiceLocaleIdentifier = profile.voice?.localeIdentifier
        voiceProviderIdentifier = profile.voice?.providerIdentifier
        voiceSpeakingRate = profile.voice?.speakingRate
        voicePitch = profile.voice?.pitch
    }

    var profile: CharacterProfile {
        CharacterProfile(
            id: id,
            name: name,
            gender: CharacterGender(rawValue: genderRawValue) ?? .female,
            tagline: tagline,
            biography: biography,
            avatarAssetName: avatarAssetName,
            symbolName: symbolName,
            accentHex: accentHex,
            personality: Personality(
                warmth: warmth,
                humor: humor,
                curiosity: curiosity,
                confidence: confidence,
                communicationStyle: communicationStyle
            ),
            preferredScenarioID: preferredScenarioID,
            voice: voiceProfile,
            origin: CharacterOrigin(rawValue: originRawValue) ?? .custom
        )
    }

    private var voiceProfile: VoiceProfile? {
        guard let voiceID, let voiceDisplayName, let voiceLocaleIdentifier else { return nil }
        return VoiceProfile(
            id: voiceID,
            displayName: voiceDisplayName,
            localeIdentifier: voiceLocaleIdentifier,
            providerIdentifier: voiceProviderIdentifier,
            speakingRate: voiceSpeakingRate ?? 0.5,
            pitch: voicePitch ?? 1
        )
    }
}

@Model
final class ScenarioRecord {
    @Attribute(.unique) var id: String
    var title: String
    var summary: String
    var systemContext: String
    var symbolName: String
    var isBuiltIn: Bool

    init(scenario: Scenario, isBuiltIn: Bool) {
        id = scenario.id
        title = scenario.title
        summary = scenario.summary
        systemContext = scenario.systemContext
        symbolName = scenario.symbolName
        self.isBuiltIn = isBuiltIn
    }
}
