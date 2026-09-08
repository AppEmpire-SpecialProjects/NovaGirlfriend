import AVFoundation
import Foundation

enum VoiceCatalog {
    static var available: [VoiceProfile] {
        let preferredLanguages = ["en-US", "en-GB", "en-AU"]
        let systemVoices = AVSpeechSynthesisVoice.speechVoices()
        var result: [VoiceProfile] = []
        for language in preferredLanguages {
            guard let voice = systemVoices.first(where: { $0.language == language }) else { continue }
            result.append(
                VoiceProfile(
                    id: voice.identifier,
                    displayName: "\(voice.name) · \(language)",
                    localeIdentifier: voice.language,
                    providerIdentifier: voice.identifier,
                    speakingRate: 0.5,
                    pitch: 1
                )
            )
        }
        if result.isEmpty, let voice = systemVoices.first {
            result.append(
                VoiceProfile(
                    id: voice.identifier,
                    displayName: voice.name,
                    localeIdentifier: voice.language,
                    providerIdentifier: voice.identifier,
                    speakingRate: 0.5,
                    pitch: 1
                )
            )
        }
        return result
    }
}
