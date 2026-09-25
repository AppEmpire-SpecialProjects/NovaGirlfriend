import Foundation

// Compile-coverage stubs for the speech-transcription slice of the media
// harness. They replace iOS-only collaborators (AVAudioSession-based
// recording, TCC-prompting authorization) and never ship in the app.

@MainActor
enum RecordingController {
  static func url(for file: String) throws -> URL {
    URL(fileURLWithPath: file)
  }

  static func remove(_ file: String) throws {}
}

struct SystemSpeechRecognitionService: SpeechRecognitionServiceProtocol {
  func requestAuthorization() async -> Bool { true }
}

// Harness-only stand-in for the app's on-device synthesizer from
// MediaServices.swift (not compiled here): satisfies RemoteVoiceSpeechService's
// default argument without any AVSpeechSynthesizer dependency.
@MainActor
final class SystemTextToSpeechService: TextToSpeechServiceProtocol {
  private(set) var spokenText: String?

  nonisolated init() {}

  func speak(_ text: String, voice: VoiceProfile?) {
    spokenText = text
  }

  func stop() {}
}
