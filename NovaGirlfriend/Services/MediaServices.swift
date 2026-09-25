import AVFoundation
import Photos
import Speech

struct SystemAudioService: AudioServiceProtocol {
  func requestRecordingPermission() async -> Bool {
    await withCheckedContinuation { continuation in
      AVAudioApplication.requestRecordPermission { granted in
        continuation.resume(returning: granted)
      }
    }
  }
}

struct SystemSpeechRecognitionService: SpeechRecognitionServiceProtocol {
  func requestAuthorization() async -> Bool {
    await withCheckedContinuation { continuation in
      SFSpeechRecognizer.requestAuthorization { status in
        continuation.resume(returning: status == .authorized)
      }
    }
  }
}

@MainActor
final class SystemTextToSpeechService: TextToSpeechServiceProtocol {
  private static let sharedSynthesizer = AVSpeechSynthesizer()
  private var synthesizer: AVSpeechSynthesizer { Self.sharedSynthesizer }

  nonisolated init() {}

  func speak(_ text: String, voice: VoiceProfile?) {
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
    synthesizer.stopSpeaking(at: .immediate)
    let utterance = AVSpeechUtterance(string: text)
    if let voice {
      utterance.voice =
        voice.providerIdentifier.flatMap(AVSpeechSynthesisVoice.init(identifier:))
        ?? AVSpeechSynthesisVoice(language: voice.localeIdentifier)
      utterance.rate = Float(voice.speakingRate)
      utterance.pitchMultiplier = Float(voice.pitch)
    }
    synthesizer.speak(utterance)
  }

  func stop() {
    synthesizer.stopSpeaking(at: .immediate)
  }
}

struct PhotoLibraryGalleryAccessService: GalleryAccessServiceProtocol {
  func requestAddOnlyAuthorization() async -> Bool {
    let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
    return status == .authorized || status == .limited
  }
}
