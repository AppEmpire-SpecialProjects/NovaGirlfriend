import AVFoundation
import Combine
import Foundation

/// Speaks companion lines with a remote companion voice, falling back to the
/// on-device synthesizer when generation or playback fails.
///
/// Long text is split into synthesis-sized chunks that are generated and
/// played strictly in order. Generation failures never surface in the UI:
/// the fallback silently takes over.
///
/// `prepare` buffers the full audio for one reply before it is revealed, and
/// `speak` then plays that buffer so text and voice surface together.
@MainActor
final class RemoteVoiceSpeechService: NSObject, ObservableObject, TextToSpeechServiceProtocol, AVAudioPlayerDelegate {
  private let client: MediaGenerationClient
  private let fallback: any TextToSpeechServiceProtocol
  private var task: Task<Void, Never>?
  private var player: AVAudioPlayer?
  private var chunkContinuation: CheckedContinuation<Void, Never>?
  private var bufferedText: String?
  private var bufferedChunks: [Data] = []

  /// Text whose audio is currently being downloaded by an unbuffered
  /// `speak(_:voice:)` call. Views observe it to show a loader on the exact
  /// message that was tapped; buffered replays never set it.
  @Published private(set) var loadingText: String?

  nonisolated init(
    client: MediaGenerationClient = MediaGenerationClient(),
    fallback: any TextToSpeechServiceProtocol = SystemTextToSpeechService()
  ) {
    self.client = client
    self.fallback = fallback
    super.init()
  }

  func speak(_ text: String, voice: VoiceProfile?) {
    stop()
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    let voiceID = Self.voiceID(for: voice)
    task = Task { [weak self] in
      guard let self else { return }
      do {
        activatePlaybackSession()
        if bufferedText == trimmed, !bufferedChunks.isEmpty {
          // Audio was fully buffered by prepare(): replay it without network.
          for data in bufferedChunks {
            try Task.checkCancellation()
            await self.playAndWait(data)
          }
        } else {
          loadingText = trimmed
          for chunk in TextChunker.chunks(from: trimmed) {
            try Task.checkCancellation()
            let generation = try await self.client.synthesizeSpeech(
              text: chunk, voiceID: voiceID)
            guard let url = generation.urls.first else { throw ServiceError.invalidResponse }
            try Task.checkCancellation()
            let data = try await self.client.download(url)
            try Task.checkCancellation()
            loadingText = nil
            await self.playAndWait(data)
          }
        }
        loadingText = nil
        deactivatePlaybackSession()
      } catch {
        deactivatePlaybackSession()
        loadingText = nil
        guard !Task.isCancelled else { return }
        self.fallback.speak(trimmed, voice: voice)
      }
    }
  }

  /// Downloads every voice chunk for `text` ahead of the reveal so the reply
  /// can appear together with its audio. Returns false (buffering nothing)
  /// when generation or download fails or exceeds `timeout`; the caller then
  /// reveals the text immediately and `speak` falls back to live synthesis
  /// or the on-device voice. Never plays anything and never throws.
  @discardableResult
  func prepare(_ text: String, voice: VoiceProfile?, timeout: TimeInterval = 30) async -> Bool {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    let chunks = TextChunker.chunks(from: trimmed)
    guard !chunks.isEmpty else { return false }
    let voiceID = Self.voiceID(for: voice)
    let download = Task { [weak self]() -> [Data]? in
      guard let self else { return nil }
      var buffers: [Data] = []
      for chunk in chunks {
        do {
          let generation = try await self.client.synthesizeSpeech(
            text: chunk, voiceID: voiceID)
          guard let url = generation.urls.first else { return nil }
          buffers.append(try await self.client.download(url))
        } catch {
          return nil
        }
      }
      return buffers.isEmpty ? nil : buffers
    }
    // Bounded wait: a stalled network must never hold the reply hostage.
    let watchdog = Task {
      try? await Task.sleep(for: .seconds(timeout))
      download.cancel()
    }
    let buffers = await download.value
    watchdog.cancel()
    guard let buffers, !Task.isCancelled else { return false }
    bufferedText = trimmed
    bufferedChunks = buffers
    return true
  }

  func stop() {
    task?.cancel()
    task = nil
    loadingText = nil
    finishChunkPlayback()
    fallback.stop()
  }

  /// Maps a selected on-device voice onto the remote companion voice roster,
  /// deterministically per voice so each companion keeps her own timbre.
  static func voiceID(for voice: VoiceProfile?) -> String {
    let roster = [
      "girlfriend_1_speech02",
      "girlfriend_2_speech02",
      "girlfriend_3_speech02",
      "girlfriend_4_speech02",
    ]
    guard let voice else { return roster[0] }
    let checksum = voice.id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return roster[checksum % roster.count]
  }

  private func playAndWait(_ data: Data) async {
    await withCheckedContinuation { continuation in
      chunkContinuation = continuation
      do {
        let player = try AVAudioPlayer(data: data)
        player.delegate = self
        self.player = player
        player.play()
      } catch {
        finishChunkPlayback()
      }
    }
  }

  private func finishChunkPlayback() {
    player?.stop()
    player = nil
    chunkContinuation?.resume()
    chunkContinuation = nil
  }

  nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    Task { @MainActor in
      self.finishChunkPlayback()
    }
  }

  private func activatePlaybackSession() {
    #if os(iOS)
    try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
    try? AVAudioSession.sharedInstance().setActive(true)
    #endif
  }

  private func deactivatePlaybackSession() {
    #if os(iOS)
    try? AVAudioSession.sharedInstance().setActive(
      false, options: [.notifyOthersOnDeactivation])
    #endif
  }
}
