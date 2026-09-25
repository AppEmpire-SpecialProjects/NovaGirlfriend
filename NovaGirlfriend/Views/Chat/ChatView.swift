import PhotosUI
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
  @ObservedObject private var access = AccessPolicy.shared
  @StateObject private var audio = RecordingController()
  @StateObject private var speech = TranscriptionController()
  @StateObject private var speaker = RemoteVoiceSpeechService()
  @StateObject private var aiConsent = AIConsentGate()
  @State private var draft = ""
  @State private var audioDraft: String?
  @State private var photoItem: PhotosPickerItem?
  @State private var photoFileName: String?
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
              AffinityBadge(
                stage: AffinityStage.stage(forPoints: model.affinityPoints),
                points: model.affinityPoints)
            }
            .frame(maxWidth: .infinity)
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
                voiceLoading: speaker.loadingText == message.text,
                retry: { model.retry(message) },
                play: { file in
                  speaker.stop()
                  audio.play(file)
                },
                speak: {
                  guard model.allow(.remoteSpeech) else { return }
                  aiConsent.run {
                    audio.stopPlayback()
                    speaker.speak(
                      message.text, voice: VoiceSettingsView.selectedVoice ?? character.voice)
                  }
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
          if !model.isThinking, model.error == nil, voiceEnabled, access.isPremium,
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
    .overlay(alignment: .top) {
      if let stage = model.stageUp {
        CelebrationToast(
          title: stage.title,
          subtitle: "Your bond with \(character.name) has grown to \(stage.title).",
          symbolName: stage.symbolName
        )
        .onTapGesture { model.clearCelebrations() }
        .task(id: stage) {
          try? await Task.sleep(for: .seconds(4))
          if model.stageUp == stage { model.clearCelebrations() }
        }
      } else if let achievement = model.unlockedAchievement {
        CelebrationToast(
          title: achievement.title, subtitle: achievement.subtitle,
          symbolName: achievement.symbolName
        )
        .onTapGesture { model.clearCelebrations() }
        .task(id: achievement.id) {
          try? await Task.sleep(for: .seconds(4))
          if model.unlockedAchievement?.id == achievement.id { model.clearCelebrations() }
        }
      }
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
    .aiConsentAlert(aiConsent)
    .fullScreenCover(isPresented: $model.showPremiumPaywall) {
      PremiumPaywallView { _ in model.showPremiumPaywall = false }
    }
    .sheet(isPresented: $showScenarios) {
      ChatScenarioSelectionView(model: model)
    }
    .task {
      model.open(
        context: context, character: character, scenario: scenario, existing: existingConversation,
        startNew: startNew)
      // Buffer the companion voice for each incoming reply before it is
      // revealed, so text and audio surface together (TC-2). Defaults are
      // read live so voice-settings changes apply mid-conversation.
      model.prepareReplyVoice = { text in
        guard Self.voicePlaybackEnabledNow, access.isPremium else { return }
        await speaker.prepare(text, voice: VoiceSettingsView.selectedVoice ?? character.voice)
      }
      if model.conversation?.messages.isEmpty == true { model.seedGreeting() }
    }
    .onDisappear {
      model.stop()
      stopMedia()
      discardAudio()
      discardPhoto()
    }
    .onChange(of: photoItem) { _, item in
      guard let item else { return }
      guard model.allow(.photoAI) else {
        photoItem = nil
        return
      }
      Task { await loadPhoto(item) }
    }
    .onChange(of: speech.showPremiumPaywall) { _, show in
      if show {
        model.showPremiumPaywall = true
        speech.showPremiumPaywall = false
      }
    }
    .onChange(of: scenePhase) { if scenePhase != .active { stopMedia() } }
  }

  /// Live value of "preferences.voicePlaybackEnabled" (true until first set),
  /// read straight from defaults so the preparation hook stays correct even
  /// when its closure was created in an earlier render cycle.
  private static var voicePlaybackEnabledNow: Bool {
    guard
      UserDefaults.standard.object(forKey: "preferences.voicePlaybackEnabled") != nil
    else { return true }
    return UserDefaults.standard.bool(forKey: "preferences.voicePlaybackEnabled")
  }

  private var composer: some View {
    VStack(spacing: NovaTheme.Spacing.sectionGap) {
      if !access.isPremium {
        Text("\(access.remainingTextReplies) of 10 free AI replies available today")
          .font(.caption)
          .foregroundStyle(NovaTheme.textSecondary)
          .accessibilityIdentifier("chat.freeReplyAllowance")
      }
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
          Button("Transcribe") {
            aiConsent.run {
              Task { await speech.transcribe(file: file) }
            }
          }
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
      if let photoFile = photoFileName {
        HStack(spacing: NovaTheme.Spacing.small) {
          PhotoThumb(fileName: photoFile)
          Text("Photo attached")
            .font(NovaTheme.Typography.caption)
            .foregroundStyle(NovaTheme.textSecondary)
          Spacer()
          Button("Discard", role: .destructive) { discardPhoto() }
            .novaActionColor(.red)
        }
      }
      HStack(alignment: .bottom) {
        PhotosPicker(selection: $photoItem, matching: .images) {
          Image(systemName: "photo.fill")
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel("Attach photo")
        .novaActionColor()
        .disabled(model.isThinking || audio.isRecording || photoFileName != nil)
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
          aiConsent.run(sendDraft)
        } label: {
          Image(systemName: "arrow.up.circle.fill")
            .font(.largeTitle)
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel("Send message")
        .novaActionColor()
        .disabled(
          model.isThinking || audio.isRecording || model.conversation == nil
            || (draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && audioDraft == nil
              && photoFileName == nil)
        )
      }
    }
    .padding(NovaTheme.Spacing.screenMargin)
    .background(NovaTheme.surface)
  }

  private func sendDraft() {
    guard model.send(text: draft, audioFileName: audioDraft, photoFileName: photoFileName)
    else { return }
    draft = ""
    audioDraft = nil
    photoFileName = nil
    speech.cancel()
    audio.stopPlayback()
  }

  private func discardAudio() {
    audio.stopPlayback()
    speech.cancel()
    if let audioDraft { try? RecordingController.remove(audioDraft) }
    audioDraft = nil
  }

  private func discardPhoto() {
    if let photoFileName { ChatPhotoStore.remove(photoFileName) }
    photoFileName = nil
    photoItem = nil
  }

  private func loadPhoto(_ item: PhotosPickerItem) async {
    do {
      guard let raw = try await item.loadTransferable(type: Data.self) else {
        throw ChatPhotoError.invalidData
      }
      guard let scaled = ImageDownscaler.jpegData(from: raw) else {
        throw ChatPhotoError.invalidData
      }
      discardPhoto()
      photoFileName = try ChatPhotoStore.save(data: scaled)
    } catch {
      model.error = error.localizedDescription
    }
    photoItem = nil
  }

  private func stopMedia() {
    audio.stopPlayback()
    audio.cancel()
    speech.cancel()
    speaker.stop()
  }

}

private struct PhotoThumb: View {
  let fileName: String

  var body: some View {
    Group {
      if let url = try? ChatPhotoStore.url(for: fileName),
        let image = UIImage(contentsOfFile: url.path)
      {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
      } else {
        Image(systemName: "photo")
          .foregroundStyle(NovaTheme.textTertiary)
      }
    }
    .frame(width: 44, height: 44)
    .clipShape(RoundedRectangle(cornerRadius: NovaTheme.Radius.small))
    .accessibilityHidden(true)
  }
}
