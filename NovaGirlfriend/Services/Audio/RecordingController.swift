import AVFoundation
import Combine
import Foundation

@MainActor
final class RecordingController: NSObject, ObservableObject, AVAudioPlayerDelegate {
  @Published private(set) var isRecording = false
  @Published private(set) var playingFile: String?
  @Published var error: String?
  @Published var permissionDenied = false
  private var recorder: AVAudioRecorder?
  private var player: AVAudioPlayer?
  private var interruption: NSObjectProtocol?
  private var generation = UUID()

  override init() {
    super.init()
    interruption = NotificationCenter.default.addObserver(
      forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
    ) { [weak self] _ in
      Task { @MainActor [weak self] in self?.cancel() }
    }
  }

  static func url(for file: String) throws -> URL {
    guard file == URL(fileURLWithPath: file).lastPathComponent else {
      throw ServiceError.invalidResponse
    }
    let directory = try FileManager.default.url(
      for: .applicationSupportDirectory, in: .userDomainMask,
      appropriateFor: nil, create: true
    )
    .appendingPathComponent("Recordings", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory.appendingPathComponent(file)
  }

  static func remove(_ file: String) throws {
    try FileManager.default.removeItem(at: url(for: file))
  }

  func start() async {
    guard !isRecording else { return }
    let token = UUID()
    generation = token
    let granted = await SystemAudioService().requestRecordingPermission()
    guard generation == token else { return }
    permissionDenied = !granted
    error = nil
    guard granted else {
      permissionDenied = true
      error = "Microphone access is denied. Enable it in Settings to record."
      return
    }
    do {
      stopPlayback()
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
      try session.setActive(true)
      let url = try Self.url(for: UUID().uuidString + ".m4a")
      let recorder = try AVAudioRecorder(
        url: url,
        settings: [
          AVFormatIDKey: kAudioFormatMPEG4AAC,
          AVSampleRateKey: 44100,
          AVNumberOfChannelsKey: 1,
          AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ])
      self.recorder = recorder
      guard recorder.record() else { throw ServiceError.invalidResponse }
      isRecording = true
    } catch {
      self.error = error.localizedDescription
      cancel()
    }
  }

  func finish() -> String? {
    guard let recorder, isRecording else { return nil }
    recorder.stop()
    let name = recorder.url.lastPathComponent
    self.recorder = nil
    isRecording = false
    deactivate()
    return name
  }

  func cancel() {
    generation = UUID()
    recorder?.stop()
    recorder?.deleteRecording()
    recorder = nil
    isRecording = false
    stopPlayback()
    deactivate()
  }

  func play(_ file: String) {
    guard !isRecording else { return }
    if playingFile == file {
      stopPlayback()
      return
    }
    do {
      stopPlayback()
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
      try AVAudioSession.sharedInstance().setActive(true)
      let player = try AVAudioPlayer(contentsOf: Self.url(for: file))
      self.player = player
      player.delegate = self
      guard player.play() else { throw ServiceError.invalidResponse }
      playingFile = file
    } catch { self.error = error.localizedDescription }
  }

  func stopPlayback() {
    player?.stop()
    player = nil
    playingFile = nil
    deactivate()
  }

  nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    Task { @MainActor in self.stopPlayback() }
  }

  private func deactivate() {
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }

  deinit {
    if let interruption { NotificationCenter.default.removeObserver(interruption) }
  }
}
