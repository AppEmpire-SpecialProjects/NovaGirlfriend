import Combine
import SwiftUI

@MainActor
final class AppPreferences: ObservableObject {
  @AppStorage("preferences.hasCompletedOnboarding") var hasCompletedOnboarding = false
  @AppStorage("preferences.selectedScenarioID") var selectedScenarioID = ""
  @AppStorage("preferences.voicePlaybackEnabled") var voicePlaybackEnabled = true
  @AppStorage("preferences.hapticsEnabled") var hapticsEnabled = true
  @AppStorage("preferences.preferredLocale") var preferredLocale = ""
}
