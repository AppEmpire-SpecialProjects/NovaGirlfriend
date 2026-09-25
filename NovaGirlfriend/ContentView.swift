import PremiumKit
import SwiftData
import SwiftUI

struct ContentView: View {
  @AppStorage("preferences.hasCompletedOnboarding") private var hasCompletedOnboarding = false
  @AppStorage("preferences.hasSeenPaywall") private var hasSeenPaywall = false
  @AppStorage("preferences.reduceMotion") private var prefersReducedMotion = false
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
  private var reduceMotion: Bool { prefersReducedMotion || systemReduceMotion }

  @State private var showSplash = true
  @Environment(\.scenePhase) private var scenePhase

  private var uiTestShowsPaywallDirectly: Bool {
    #if DEBUG
      ProcessInfo.processInfo.arguments.contains("--uitest-show-paywall")
    #else
      false
    #endif
  }

  var body: some View {
    Group {
      if showSplash {
        SplashView()
          .ignoresSafeArea()
      } else if !hasCompletedOnboarding && !uiTestShowsPaywallDirectly {
        OnboardingView {
          hasCompletedOnboarding = true
          hasSeenPaywall = true
        } onLimited: {
          hasCompletedOnboarding = true
          hasSeenPaywall = true
        }
      } else if !hasSeenPaywall {
        PremiumPaywallView(placement: .main) { _ in
          hasSeenPaywall = true
        }
      } else {
        MainTabView()
      }
    }
    .task {
      try? await Task.sleep(for: .seconds(1.4))
      withAnimation(reduceMotion ? nil : .easeOut(duration: 0.35)) {
        showSplash = false
      }
    }
    .task { await PremiumStore.shared.refreshEntitlements() }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        Task { await PremiumStore.shared.refreshEntitlements() }
      }
    }
    .font(NovaTheme.Typography.body)
    .foregroundStyle(NovaTheme.text)
    .tint(NovaTheme.primary)
    .background(NovaTheme.background.ignoresSafeArea())
    .preferredColorScheme(.dark)
    .animation(reduceMotion ? nil : .easeInOut, value: hasCompletedOnboarding)
    .animation(reduceMotion ? nil : .easeInOut, value: hasSeenPaywall)
  }
}

#Preview {
  ContentView()
    .modelContainer(try! PersistenceController.makeContainer(inMemory: true))
}
