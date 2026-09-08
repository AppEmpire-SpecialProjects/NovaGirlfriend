import SwiftData
import SwiftUI

struct ChatView: View {
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
  @AppStorage("preferences.reduceMotion") private var prefersReducedMotion = false
  private var reduceMotion: Bool { systemReduceMotion || prefersReducedMotion }
  let character: CharacterProfile
  var scenario: Scenario? = nil
  var existingConversation: ConversationRecord? = nil
  var startNew = false
  @Environment(\.modelContext) private var context
  @Environment(\.scenePhase) private var scenePhase
  @StateObject private var model = ChatViewModel()
  @StateObject private var audio = RecordingController()
  @StateObject private var speech = TranscriptionController()
  @State private var speaker = SystemTextToSpeechService()
  @State private var draft = ""
  @State private var audioDraft: String?
  @State private var showClear = false
  @State private var showScenarios = false
  @AppStorage("preferences.voicePlaybackEnabled") private var voiceEnabled = true

  var body: some View {
    VStack(spacing: 0) {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(spacing: NovaTheme.Spacing.cardGap) {
            VStack(spacing: NovaTheme.Spacing.small) {
              CharacterAvatarView(profile: character, size: 48)
                .accessibilityHidden(true)
              Text("Your conversation with \(character.name)")
                .font(.caption)
                .foregroundStyle(NovaTheme.textSecondary)
              if let scenario = model.scenario {
                Text(scenario.title)
                  .font(NovaTheme.Typography.label)
                  .foregroundStyle(NovaTheme.primary)
                  .multilineTextAlignment(.center)
                  .accessibilityIdentifier("chat.scenarioTitle")
              }
            }
            .padding(.bottom, NovaTheme.Spacing.sectionGap - NovaTheme.Spacing.cardGap)
            if model.conversation?.messages.isEmpty == true {
              VStack(spacing: NovaTheme.Spacing.small) {
                Image(systemName: "bubble.left.and.bubble.right")
                  .font(.largeTitle)
                  .foregroundStyle(NovaTheme.inactiveIcon)
                VStack(spacing: NovaTheme.Spacing.titleSubtitle) {
                  Text("Say hello").font(NovaTheme.Typography.section)
                  Text("Send a message or record your voice to begin.")
                    .font(.subheadline)
                    .foregroundStyle(NovaTheme.textSecondary)
                    .multilineTextAlignment(.center)
                }
              }
              .frame(maxWidth: .infinity)
            }
            ForEach(model.conversation?.orderedMessages ?? []) { message in
              MessageBubble(
                message: message, isThinking: model.isThinking,
                playingFile: audio.playingFile,
                retry: { model.retry(message) },
                play: { file in
                  speaker.stop()
                  audio.play(file)
                },
                speak: {
                  audio.stopPlayback()
                  speaker.speak(
                    message.text, voice: VoiceSettingsView.selectedVoice ?? character.voice)
                })
            }
            if model.isThinking {
              HStack {
                ProgressView()
                Text("Thinking…")
                Spacer()
              }
            }
            Color.clear.frame(height: 1).id("bottom")
          }
          .padding(NovaTheme.Spacing.screenMargin)
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: model.conversation?.messages.count) { oldCount, newCount in
          guard let oldCount, let newCount, newCount > oldCount else { return }
          withAnimation(reduceMotion ? nil : .default) { proxy.scrollTo("bottom", anchor: .bottom) }
        }
        .onChange(of: model.isThinking) {
          if !model.isThinking, model.error == nil, voiceEnabled,
            let last = model.conversation?.orderedMessages.last,
            last.roleRawValue == "assistant"
          {
            audio.stopPlayback()
            speaker.speak(last.text, voice: VoiceSettingsView.selectedVoice ?? character.voice)
          }
        }
      }
    }
    .safeAreaInset(edge: .bottom, spacing: 0) {
      composer
    }
    .novaScreen()
    .toolbar(.hidden, for: .tabBar)
    .novaNavigationTitle(character.name)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu {
          Button("Choose Scenario", systemImage: "sparkles") { showScenarios = true }
            .disabled(model.isThinking || model.conversation == nil)
            .accessibilityIdentifier("chat.chooseScenario")
          NavigationLink("Voice Settings") { VoiceSettingsView() }
          Button("Clear conversation", role: .destructive) { showClear = true }
            .disabled(model.isThinking)
        } label: {
          Image(systemName: "ellipsis.circle")
            .novaActionColor()
        }
        .accessibilityLabel("Conversation actions")
      }
    }
    .confirmationDialog("Clear all messages?", isPresented: $showClear, titleVisibility: .visible) {
      Button("Clear messages", role: .destructive) {
        guard let conversation = model.conversation else { return }
        stopMedia()
        do { try ConversationMaintenance(context: context).clear(conversation) } catch {
          model.error = error.localizedDescription
        }
      }
    }
    .sheet(isPresented: $showScenarios) {
      ChatScenarioSelectionView(model: model)
    }
    .task {
      model.open(
        context: context, character: character, scenario: scenario, existing: existingConversation,
        startNew: startNew)
    }
    .onDisappear {
      model.stop()
      stopMedia()
      discardAudio()
    }
    .onChange(of: scenePhase) { if scenePhase != .active { stopMedia() } }
  }

  private var composer: some View {
    VStack(spacing: NovaTheme.Spacing.sectionGap) {
      if let error = model.error ?? audio.error ?? speech.error {
        HStack(alignment: .top) {
          Text(error).font(.caption).foregroundStyle(.red)
          Spacer()
          Button("Dismiss") {
            model.error = nil
            audio.error = nil
            speech.error = nil
          }
          .novaActionColor()
        }
      }
      if audio.permissionDenied || speech.state == .denied {
        Link("Open Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
          .novaActionColor()
      }
      if audio.isRecording {
        HStack {
          Label("Recording", systemImage: "record.circle").foregroundStyle(.red)
          Spacer()
          Button("Cancel") { audio.cancel() }
            .novaActionColor()
          Button("Done") { audioDraft = audio.finish() }
            .novaActionColor()
        }
      }
      if let file = audioDraft {
        HStack {
          Button("Play recording") {
            speaker.stop()
            audio.play(file)
          }
          .novaActionColor()
          Button("Transcribe") { Task { await speech.transcribe(file: file) } }
            .novaActionColor()
          Button("Discard", role: .destructive) { discardAudio() }
            .novaActionColor(.red)
        }.font(.caption)
        if speech.state == .recognizing || speech.state == .authorizing {
          ProgressView("Transcribing…")
        }
        if !speech.transcript.isEmpty {
          Text(speech.transcript).font(.caption).lineLimit(4)
          Button("Use transcript") { draft = speech.transcript }
            .novaActionColor()
        }
      }
      HStack(alignment: .bottom) {
        Button {
          speaker.stop()
          Task { await audio.start() }
        } label: {
          Image(systemName: "mic.fill")
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel("Record voice message")
        .novaActionColor()
        .disabled(audio.isRecording || audioDraft != nil || model.isThinking)
        TextField(
          "Message \(character.name)…", text: $draft,
          prompt: Text("Message \(character.name)…").foregroundStyle(NovaTheme.textTertiary),
          axis: .vertical
        )
        .font(NovaTheme.Typography.body)
        .lineLimit(1...6)
        .padding(12)
        .novaInput(cornerRadius: 18)
        Button {
          guard model.send(text: draft, audioFileName: audioDraft) else { return }
          draft = ""
          audioDraft = nil
          speech.cancel()
          audio.stopPlayback()
        } label: {
          Image(systemName: "arrow.up.circle.fill")
            .font(.largeTitle)
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel("Send message")
        .novaActionColor()
        .disabled(
          model.isThinking || audio.isRecording || model.conversation == nil
            || (draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && audioDraft == nil))
      }
    }
    .padding(NovaTheme.Spacing.screenMargin)
    .background(NovaTheme.surface)
  }

  private func discardAudio() {
    audio.stopPlayback()
    speech.cancel()
    if let audioDraft { try? RecordingController.remove(audioDraft) }
    audioDraft = nil
  }

  private func stopMedia() {
    audio.stopPlayback()
    audio.cancel()
    speech.cancel()
    speaker.stop()
  }

}
