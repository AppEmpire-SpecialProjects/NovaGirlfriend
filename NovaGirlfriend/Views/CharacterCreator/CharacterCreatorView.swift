import PhotosUI
import SwiftData
import SwiftUI

@MainActor
struct CharacterCreatorView: View {
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
  @AppStorage("preferences.reduceMotion") private var prefersReducedMotion = false
  private var reduceMotion: Bool { systemReduceMotion || prefersReducedMotion }
  enum Step: Int, CaseIterable {
    case identity, appearance, personality, voice, preview

    var title: String {
      switch self {
      case .identity: "Identity"
      case .appearance: "Appearance"
      case .personality: "Personality"
      case .voice: "Voice"
      case .preview: "Preview"
      }
    }
  }

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @State private var draft: CharacterDraft
  @State private var step: Step = .identity
  @State private var photoItem: PhotosPickerItem?
  @State private var photoImportTask: Task<Void, Never>?
  @State private var errorMessage: String?
  @State private var isSaving = false
  @State private var didSave = false
  private let isEditing: Bool
  private let originalAvatarReference: String?
  private let onSaved: (CharacterProfile) -> Void
  private let speech = SystemTextToSpeechService()

  init(profile: CharacterProfile? = nil, onSaved: @escaping (CharacterProfile) -> Void) {
    _draft = State(initialValue: profile.map(CharacterDraft.init(profile:)) ?? .fresh)
    isEditing = profile != nil
    originalAvatarReference = profile?.avatarAssetName
    self.onSaved = onSaved
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        progressHeader
        ScrollView {
          stepContent
            .padding(NovaTheme.Spacing.screenMargin)
            .frame(maxWidth: .infinity)
        }
        controls
      }
      .novaScreen()
      .novaNavigationTitle(isEditing ? "Edit Companion" : "Create Companion")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Back", systemImage: "chevron.backward") {
            if step == .identity {
              dismiss()
            } else {
              move(by: -1)
            }
          }
          .labelStyle(.iconOnly)
          .novaActionColor()
          .disabled(isSaving)
          .accessibilityIdentifier("creator.back")
        }
      }
      .alert("Couldn’t Complete Action", isPresented: .constant(errorMessage != nil)) {
        Button("OK") { errorMessage = nil }
      } message: {
        Text(errorMessage ?? "Unknown error")
      }
    }
    .interactiveDismissDisabled(isSaving)
    .onChange(of: photoItem) { _, item in
      guard let item else { return }
      photoImportTask?.cancel()
      photoImportTask = Task { await importPhoto(item) }
    }
    .onDisappear {
      photoImportTask?.cancel()
      speech.stop()
      if !didSave, draft.avatarReference != originalAvatarReference {
        AvatarStorage.delete(reference: draft.avatarReference)
      }
    }
  }

  private var progressHeader: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.small) {
      HStack {
        Text("Step \(step.rawValue + 1) of \(Step.allCases.count)")
        Spacer()
        Text(step.title)
          .font(NovaTheme.Typography.headline)
          .foregroundStyle(NovaTheme.text)
          .accessibilityIdentifier("creator.step")
      }
      .font(NovaTheme.Typography.label)
      .foregroundStyle(NovaTheme.textSecondary)
      ProgressView(value: Double(step.rawValue + 1), total: Double(Step.allCases.count))
        .tint(NovaTheme.primary)
    }
    .padding(.horizontal, NovaTheme.Spacing.screenMargin)
    .padding(.top, NovaTheme.Spacing.screenMargin)
    .accessibilityElement(children: .combine)
  }

  @ViewBuilder private var stepContent: some View {
    switch step {
    case .identity:
      IdentityStepView(draft: $draft)
    case .appearance:
      AppearanceStepView(
        draft: $draft, photoItem: $photoItem, originalAvatarReference: originalAvatarReference)
    case .personality:
      PersonalityStepView(draft: $draft)
    case .voice:
      VoiceStepView(draft: $draft, preview: previewVoice)
    case .preview:
      PreviewStepView(draft: draft)
    }
  }

  private var controls: some View {
    Button {
      if step == .preview { save() } else { move(by: 1) }
    } label: {
      Text(step == .preview ? (isEditing ? "Save Changes" : "Create Companion") : "Continue")
        .font(NovaTheme.Typography.label)
        .foregroundStyle(NovaTheme.background)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
    .id(step)
    .buttonStyle(NovaPrimaryButtonStyle())
    .tint(NovaTheme.primary)
    .controlSize(.large)
    .frame(maxWidth: .infinity)
    .disabled(isSaving || (step == .identity && draft.trimmedName.isEmpty))
    .accessibilityIdentifier("creator.primary")
    .padding(NovaTheme.Spacing.screenMargin)
    .background(NovaTheme.surface)
    .overlay(alignment: .top) {
      Rectangle()
        .fill(NovaTheme.border)
        .frame(height: 1)
    }
  }

  private func move(by offset: Int) {
    guard let destination = Step(rawValue: step.rawValue + offset) else { return }
    withAnimation(reduceMotion ? nil : .default) { step = destination }
  }

  private func importPhoto(_ item: PhotosPickerItem) async {
    do {
      guard let data = try await item.loadTransferable(type: Data.self) else {
        throw AvatarStorageError.unsupportedImage
      }
      try Task.checkCancellation()
      let replacement = try AvatarStorage.save(imageData: data, characterID: UUID())
      let previous = draft.avatarReference
      draft.avatarReference = replacement
      if previous != originalAvatarReference {
        AvatarStorage.delete(reference: previous)
      }
    } catch is CancellationError {
      // Dismissal or a newer selection superseded this import.
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func previewVoice() {
    guard let voice = draft.voice else { return }
    speech.stop()
    speech.speak(
      "Hi, I’m \(draft.trimmedName.isEmpty ? "your companion" : draft.trimmedName). This is how my voice sounds.",
      voice: voice)
  }

  private func save() {
    guard !draft.trimmedName.isEmpty else {
      step = .identity
      return
    }
    isSaving = true
    do {
      let profile = draft.profile
      try SwiftDataCharacterRepository(context: modelContext).saveCustom(profile)
      if originalAvatarReference != profile.avatarAssetName {
        AvatarStorage.delete(reference: originalAvatarReference)
      }
      didSave = true
      onSaved(profile)
      dismiss()
    } catch {
      isSaving = false
      errorMessage = error.localizedDescription
    }
  }
}
