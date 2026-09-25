import PhotosUI
import SwiftUI

struct IdentityStepView: View {
  @Binding var draft: CharacterDraft
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.sectionGap) {
      CreatorHeading(
        title: "Who are they?",
        subtitle: "Give your companion an identity. You can change it later.")
      TextField(
        "Name", text: $draft.name,
        prompt: Text("Name").foregroundStyle(NovaTheme.textTertiary)
      )
      .font(NovaTheme.Typography.body)
      .textFieldStyle(.plain)
      .padding(NovaTheme.Spacing.medium)
      .novaInput(cornerRadius: NovaTheme.Radius.medium)
      .textContentType(.name)
      .submitLabel(.next)
      .accessibilityHint("A name is required to continue")
      VStack(alignment: .leading, spacing: NovaTheme.Spacing.small) {
        Text("Gender").font(NovaTheme.Typography.headline)
        if dynamicTypeSize.isAccessibilitySize {
          genderPicker.pickerStyle(.menu)
        } else {
          genderPicker.pickerStyle(.segmented)
        }
      }
    }
  }

  private var genderPicker: some View {
    Picker("Gender", selection: $draft.gender) {
      ForEach(CharacterGender.allCases) { gender in
        Text(gender.rawValue).tag(gender)
      }
    }
    .font(NovaTheme.Typography.body)
  }
}

struct AppearanceStepView: View {
  @Binding var draft: CharacterDraft
  @Binding var photoItem: PhotosPickerItem?
  let originalAvatarReference: String?
  private let portraits = ProductContentRepository().characters

  private var photoPickerTitle: String {
    guard let reference = draft.avatarReference else { return "Choose a Photo" }
    return portraits.contains { $0.avatarAssetName == reference }
      ? "Choose a Photo" : "Replace Selected Photo"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.sectionGap) {
      CreatorHeading(
        title: "Choose a look",
        subtitle: "Pick a companion portrait or a photo that stays on this device.")
      PhotosPicker(selection: $photoItem, matching: .images) {
        Label(photoPickerTitle, systemImage: "photo.badge.plus")
          .font(NovaTheme.Typography.label)
          .foregroundStyle(NovaTheme.primary)
          .frame(maxWidth: .infinity)
          .padding(NovaTheme.Spacing.medium)
          .background(NovaTheme.surface, in: Capsule())
          .overlay {
            Capsule()
              .strokeBorder(Color.white.opacity(0.30), lineWidth: 2)
              .allowsHitTesting(false)
          }
          .contentShape(Capsule())
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier("creator.choosePhoto")
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 76), spacing: NovaTheme.Spacing.cardGap)],
        spacing: NovaTheme.Spacing.cardGap
      ) {
        ForEach(portraits) { character in
          let isSelected = draft.avatarReference == character.avatarAssetName
          Button {
            if draft.avatarReference != originalAvatarReference {
              AvatarStorage.delete(reference: draft.avatarReference)
            }
            draft.symbolName = character.symbolName
            draft.accentHex = AppColors.accentHex
            draft.avatarReference = character.avatarAssetName
          } label: {
            CharacterAvatarView(profile: character, size: 68)
              .accessibilityHidden(true)
              .overlay {
                Circle()
                  .strokeBorder(
                    isSelected ? NovaTheme.primary : .clear, lineWidth: 2)
              }
          }
          .buttonStyle(.plain)
          .accessibilityLabel("Select \(character.name) avatar")
          .accessibilityAddTraits(isSelected ? .isSelected : [])
          .accessibilityIdentifier("creator.avatar.\(character.id.uuidString)")
        }
      }
      Text("Imported photos are copied into the app’s private storage. They are never uploaded.")
        .font(.footnote)
        .foregroundStyle(NovaTheme.textSecondary)
    }
  }
}

struct PersonalityStepView: View {
  @Binding var draft: CharacterDraft

  var body: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.sectionGap) {
      CreatorHeading(
        title: "Shape their personality",
        subtitle:
          "These grouped traits are saved in the shared personality model and guide conversations.")
      VStack(spacing: NovaTheme.Spacing.cardGap) {
        TraitGroup(
          title: "Connection",
          traits: [
            TraitBinding(name: "Warmth", value: $draft.warmth),
            TraitBinding(name: "Humor", value: $draft.humor),
          ])
        TraitGroup(
          title: "Presence",
          traits: [
            TraitBinding(name: "Curiosity", value: $draft.curiosity),
            TraitBinding(name: "Confidence", value: $draft.confidence),
          ])
        Menu {
          Picker("Communication style", selection: $draft.communicationStyle) {
            Text("Warm and thoughtful").tag("Warm and thoughtful")
            Text("Playful and expressive").tag("Playful and expressive")
            Text("Calm and reflective").tag("Calm and reflective")
            Text("Witty and direct").tag("Witty and direct")
          }
          .pickerStyle(.inline)
        } label: {
          HStack(spacing: NovaTheme.Spacing.medium) {
            Text(draft.communicationStyle)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.up.chevron.down")
              .font(.caption.weight(.semibold))
              .accessibilityHidden(true)
          }
          .font(NovaTheme.Typography.body)
          .foregroundStyle(NovaTheme.primary)
          .padding(NovaTheme.Spacing.medium)
          .frame(maxWidth: .infinity, alignment: .leading)
          .novaSurface()
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .accessibilityLabel("Communication style")
        .accessibilityValue(draft.communicationStyle)
      }
    }
  }
}

private struct TraitBinding: Identifiable {
  let name: String
  let value: Binding<Double>
  var id: String { name }
}

private struct TraitGroup: View {
  let title: String
  let traits: [TraitBinding]

  var body: some View {
    NovaCard {
      VStack(alignment: .leading, spacing: NovaTheme.Spacing.medium) {
        Text(title).font(NovaTheme.Typography.headline)
        ForEach(traits) { trait in
          VStack(alignment: .leading) {
            HStack {
              Text(trait.name)
              Spacer()
              Text("\(Int(trait.value.wrappedValue))")
                .monospacedDigit()
                .foregroundStyle(NovaTheme.textSecondary)
            }
            Slider(value: trait.value, in: 0...100, step: 1)
              .accessibilityValue("\(Int(trait.value.wrappedValue)) percent")
          }
        }
      }
    }
  }
}

struct VoiceStepView: View {
  @Binding var draft: CharacterDraft
  let preview: () -> Void
  private let voices = VoiceCatalog.available

  var body: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.sectionGap) {
      CreatorHeading(
        title: "Find their voice",
        subtitle: "Choose an installed system voice and hear a real on-device preview.")
      if voices.isEmpty {
        NovaEmptyState(
          title: "No System Voice Available", message: "You can finish without a voice.",
          systemImage: "speaker.slash", isEmbedded: true)
      } else {
        Picker("Voice", selection: $draft.voice) {
          Text("No voice").tag(Optional<VoiceProfile>.none)
          ForEach(voices) { voice in
            Text(voice.displayName).tag(Optional(voice))
          }
        }
        .pickerStyle(.inline)
        .font(NovaTheme.Typography.body)
        .padding(NovaTheme.Spacing.small)
        .novaSurface()
        Button(action: preview) {
          Label("Preview Voice", systemImage: "speaker.wave.2.fill")
            .font(NovaTheme.Typography.label)
            .foregroundStyle(NovaTheme.background)
        }
        .buttonStyle(NovaPrimaryButtonStyle())
        .tint(NovaTheme.primary)
        .disabled(draft.voice == nil)
      }
    }
  }
}

struct PreviewStepView: View {
  let draft: CharacterDraft

  var body: some View {
    VStack(spacing: NovaTheme.Spacing.sectionGap) {
      CharacterAvatarView(profile: draft.profile, size: 120)
      VStack(spacing: NovaTheme.Spacing.titleSubtitle) {
        Text(draft.trimmedName)
          .font(NovaTheme.Typography.display)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
        Text(draft.gender.rawValue).foregroundStyle(NovaTheme.textSecondary)
      }
      NovaCard {
        VStack(alignment: .leading, spacing: NovaTheme.Spacing.small) {
          VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
            Label(draft.communicationStyle, systemImage: "quote.bubble")
            Text(draft.summary).foregroundStyle(NovaTheme.textSecondary)
          }
          if let voice = draft.voice {
            Label(voice.displayName, systemImage: "speaker.wave.2")
          }
        }
      }
    }
  }
}

private struct CreatorHeading: View {
  let title: String
  let subtitle: String

  var body: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
      Text(title).font(NovaTheme.Typography.title)
        .foregroundStyle(NovaTheme.text)
        .fixedSize(horizontal: false, vertical: true)
      Text(subtitle)
        .font(NovaTheme.Typography.body)
        .foregroundStyle(NovaTheme.textSecondary)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}
