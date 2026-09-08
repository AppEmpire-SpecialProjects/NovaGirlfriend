import SwiftData
import SwiftUI

struct ContentView: View {
  @AppStorage("preferences.hasCompletedOnboarding") private var hasCompletedOnboarding = false
  @AppStorage("preferences.reduceMotion") private var prefersReducedMotion = false
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
  private var reduceMotion: Bool { prefersReducedMotion || systemReduceMotion }

  var body: some View {
    Group {
      if hasCompletedOnboarding {
        MainTabView()
      } else {
        OnboardingView {
          hasCompletedOnboarding = true
        }
      }
    }
    .font(NovaTheme.Typography.body)
    .foregroundStyle(NovaTheme.text)
    .tint(NovaTheme.primary)
    .background(NovaTheme.background.ignoresSafeArea())
    .preferredColorScheme(.dark)
    .animation(reduceMotion ? nil : .easeInOut, value: hasCompletedOnboarding)
  }
}

#Preview {
  ContentView()
    .modelContainer(try! PersistenceController.makeContainer(inMemory: true))
}
