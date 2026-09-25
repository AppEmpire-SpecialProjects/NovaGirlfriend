import Combine
import Speech

@MainActor
final class TranscriptionController: ObservableObject {
  enum State: Equatable {
    case idle, authorizing, recognizing, complete, denied, failed
  }
  @Published private(set) var state: State = .idle
  @Published private(set) var transcript = ""
  @Published var error: String?
  @Published var showPremiumPaywall = false
  private var task: SFSpeechRecognitionTask?
  private var generation = UUID()
  private let cloud: MediaGenerationClient

  nonisolated init(cloud: MediaGenerationClient = MediaGenerationClient()) {
    self.cloud = cloud
  }

  func transcribe(file: String) async {
    cancel()
    let token = UUID()
    generation = token
    state = .authorizing
    let authorized = await SystemSpeechRecognitionService().requestAuthorization()
    guard generation == token else { return }
    guard authorized else {
      state = .denied
      error = "Speech recognition permission is denied. You can still send the recording."
      return
    }
    guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
      await recognizeRemotely(file: file, token: token)
      return
    }
    do {
      let request = SFSpeechURLRecognitionRequest(url: try RecordingController.url(for: file))
      request.shouldReportPartialResults = true
      if !AccessPolicy.shared.isPremium {
        guard recognizer.supportsOnDeviceRecognition else {
          throw AccessPolicy.Denial.premiumRequired
        }
        request.requiresOnDeviceRecognition = true
      }
      state = .recognizing
      task = recognizer.recognitionTask(with: request) { [weak self] result, error in
        let text = result?.bestTranscription.formattedString
        let final = result?.isFinal ?? false
        let failure = error?.localizedDescription
        Task { @MainActor in
          guard let self, self.generation == token else { return }
          if let text { self.transcript = text }
          if final {
            if self.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              await self.recognizeRemotely(file: file, token: token)
            } else {
              self.state = .complete
            }
          }
          if let failure {
            self.error = failure
            await self.recognizeRemotely(file: file, token: token)
          }
        }
      }
    } catch {
      if error is AccessPolicy.Denial { showPremiumPaywall = true }
      self.error = error.localizedDescription
      state = .failed
    }
  }

  /// Cloud fallback when on-device recognition is unavailable, fails, or
  /// returns an empty transcript. Never surfaces provider details.
  private func recognizeRemotely(file: String, token: UUID) async {
    guard generation == token else { return }
    state = .recognizing
    do {
      let audio = try Data(contentsOf: RecordingController.url(for: file))
      let text = try await cloud.transcribeSpeech(audio: audio, contentType: "audio/m4a")
      guard generation == token else { return }
      transcript = text
      state = .complete
      error = nil
    } catch {
      guard generation == token else { return }
      if error is AccessPolicy.Denial { showPremiumPaywall = true }
      if transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        // A plain `catch` shadows the property with an immutable `error`
        // constant; qualify with `self` to assign the published property.
        if self.error == nil {
          self.error = "Speech recognition is currently unavailable."
        }
        state = .failed
      } else {
        state = .complete
      }
    }
  }

  func cancel() {
    generation = UUID()
    task?.cancel()
    task = nil
    transcript = ""
    state = .idle
  }
}
