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
  private var task: SFSpeechRecognitionTask?
  private var generation = UUID()

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
      state = .failed
      error = "Speech recognition is currently unavailable."
      return
    }
    do {
      let request = SFSpeechURLRecognitionRequest(url: try RecordingController.url(for: file))
      request.shouldReportPartialResults = true
      state = .recognizing
      task = recognizer.recognitionTask(with: request) { [weak self] result, error in
        let text = result?.bestTranscription.formattedString
        let final = result?.isFinal ?? false
        let failure = error?.localizedDescription
        Task { @MainActor in
          guard let self, self.generation == token else { return }
          if let text { self.transcript = text }
          if final { self.state = .complete }
          if let failure {
            self.error = failure
            self.state = .failed
          }
        }
      }
    } catch {
      self.error = error.localizedDescription
      state = .failed
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
