import AVFoundation
import SwiftUI

struct VoiceSettingsView: View {
  @AppStorage("preferences.voicePlaybackEnabled") private var enabled = true
  @AppStorage("preferences.voiceIdentifier") private var identifier = ""
  @AppStorage("preferences.voiceRate") private var rate = Double(AVSpeechUtteranceDefaultSpeechRate)
  @State private var speaker = SystemTextToSpeechService()
  @Environment(\.scenePhase) private var scenePhase

  static var selectedVoice: VoiceProfile? {
    let defaults = UserDefaults.standard
    guard let id = defaults.string(forKey: "preferences.voiceIdentifier"),
      let voice = AVSpeechSynthesisVoice(identifier: id)
    else { return nil }
    let rate =
      defaults.object(forKey: "preferences.voiceRate") as? Double
      ?? Double(AVSpeechUtteranceDefaultSpeechRate)
    return VoiceProfile(
      id: id, displayName: voice.name, localeIdentifier: voice.language,
      providerIdentifier: id, speakingRate: rate, pitch: 1)
  }

  var body: some View {
    Form {
      Section {
        Toggle("Read responses aloud", isOn: $enabled)
        Picker("System voice", selection: $identifier) {
          Text("Default").tag("")
          ForEach(AVSpeechSynthesisVoice.speechVoices(), id: \.identifier) { voice in
            Text("\(voice.name) · \(voice.language)").tag(voice.identifier)
          }
        }
        .pickerStyle(.navigationLink)
      } header: {
        Text("Playback")
          .font(NovaTheme.Typography.headline)
          .textCase(nil)
          .foregroundStyle(NovaTheme.textSecondary)
      } footer: {
        Text(
          "Your selection picks the companion voice used for replies in chat. "
            + "The system voice itself plays only as an offline fallback."
        )
        .foregroundStyle(NovaTheme.textSecondary)
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
      Section {
        Slider(value: $rate, in: 0.3...0.6) {
          Text("Speaking speed")
        } minimumValueLabel: {
          Image(systemName: "tortoise")
        } maximumValueLabel: {
          Image(systemName: "hare")
        }
        .disabled(identifier.isEmpty)
      } header: {
        Text("Speaking speed")
          .font(NovaTheme.Typography.headline)
          .textCase(nil)
          .foregroundStyle(NovaTheme.textSecondary)
      } footer: {
        if identifier.isEmpty {
          Text("Select a system voice to customize its speed.")
            .foregroundStyle(NovaTheme.textSecondary)
        }
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
      Section {
        Button("Preview voice") {
          speaker.speak("This is a preview of your selected voice.", voice: Self.selectedVoice)
        }
        .novaActionColor()
        Button("Stop preview") { speaker.stop() }
          .novaActionColor()
      } footer: {
        Text(
          "Voices are provided by iOS. Additional voices can be downloaded in device Accessibility settings."
        )
        .foregroundStyle(NovaTheme.textSecondary)
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
    }
    .novaGroupedListSpacing()
    .novaScreen()
    .novaNavigationTitle("Voice Settings")
    .toolbar(.hidden, for: .tabBar)
    .onDisappear { speaker.stop() }
    .onChange(of: scenePhase) { if scenePhase != .active { speaker.stop() } }
  }
}
