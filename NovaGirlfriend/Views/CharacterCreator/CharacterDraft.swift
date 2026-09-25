import Foundation

struct CharacterDraft: Equatable {
  var id: UUID
  var name: String
  var gender: CharacterGender
  var symbolName: String
  var accentHex: String
  var avatarReference: String?
  var warmth: Double
  var humor: Double
  var curiosity: Double
  var confidence: Double
  var communicationStyle: String
  var voice: VoiceProfile?

  static var fresh: CharacterDraft {
    CharacterDraft(
      id: UUID(),
      name: "",
      gender: .female,
      symbolName: "sparkles",
      accentHex: AppColors.accentHex,
      avatarReference: nil,
      warmth: 75,
      humor: 65,
      curiosity: 80,
      confidence: 70,
      communicationStyle: "Warm and thoughtful",
      voice: nil
    )
  }

  init(profile: CharacterProfile) {
    id = profile.id
    name = profile.name
    gender = profile.gender
    symbolName = profile.symbolName
    accentHex = profile.accentHex
    avatarReference = profile.avatarAssetName
    warmth = Double(profile.personality.warmth)
    humor = Double(profile.personality.humor)
    curiosity = Double(profile.personality.curiosity)
    confidence = Double(profile.personality.confidence)
    communicationStyle = profile.personality.communicationStyle
    voice = profile.voice
  }

  private init(
    id: UUID,
    name: String,
    gender: CharacterGender,
    symbolName: String,
    accentHex: String,
    avatarReference: String?,
    warmth: Double,
    humor: Double,
    curiosity: Double,
    confidence: Double,
    communicationStyle: String,
    voice: VoiceProfile?
  ) {
    self.id = id
    self.name = name
    self.gender = gender
    self.symbolName = symbolName
    self.accentHex = accentHex
    self.avatarReference = avatarReference
    self.warmth = warmth
    self.humor = humor
    self.curiosity = curiosity
    self.confidence = confidence
    self.communicationStyle = communicationStyle
    self.voice = voice
  }

  var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

  var summary: String {
    "\(trimmedName) is a \(communicationStyle.lowercased()) companion with warmth \(Int(warmth)), humor \(Int(humor)), curiosity \(Int(curiosity)), and confidence \(Int(confidence))."
  }

  var profile: CharacterProfile {
    CharacterProfile(
      id: id,
      name: trimmedName,
      gender: gender,
      tagline: communicationStyle,
      biography: summary,
      avatarAssetName: avatarReference,
      symbolName: symbolName,
      accentHex: accentHex,
      personality: Personality(
        warmth: Int(warmth),
        humor: Int(humor),
        curiosity: Int(curiosity),
        confidence: Int(confidence),
        communicationStyle: communicationStyle
      ),
      voice: voice,
      origin: .custom
    )
  }
}
