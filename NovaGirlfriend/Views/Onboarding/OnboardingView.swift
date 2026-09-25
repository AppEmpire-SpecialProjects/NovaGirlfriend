import PremiumKit
import StoreKit
import SwiftUI

struct OnboardingView: View {
  let onComplete: () -> Void
  let onLimited: () -> Void

  @ObservedObject private var store = PremiumStore.shared
  @State private var isReady = false
  @State private var skipped = false
  @State private var completionHandled = false
  @State private var entitlementError = false

  var body: some View {
    Group {
      if isReady {
        OnboardingBuilder(
          screens: screens,
          paywallImages: artwork(5),
          style: style,
          paywallCopy: OnboardingPaywallCopy(
            title1: "Unlimited", title2: "Access",
            subtitle: "Get full access for just $4.99/week",
            trialSubtitle: "Try 3 days free then $4.99/week",
            message: "Not sure yet? Start a free trial",
            trialMessage: "Free trial enabled",
            limitedButton: "Or proceed with limited version",
            button: "Continue", trialButton: "Try free & subscribe"
          ),
          linksConfig: LinksConfiguration(
            termsTitle: "Terms of Use", privacyTitle: "Privacy Policy", restoreTitle: "Restore"
          ),
          isTrialEnabled: false,
          showReviewRequestOnComplete: false,
          termsView: { LegalSheetView(document: .terms) },
          privacyView: { LegalSheetView(document: .privacy) },
          hiddenProductIDs: hiddenProductIDs,
          onLimitedTapped: { skipped = true },
          onComplete: finish
        )
      } else {
        VStack(spacing: 16) {
          if store.isLoading {
            ProgressView("Loading plans…")
              .tint(OnboardingPalette.dot)
              .foregroundStyle(.white)
              .padding(24)
              .background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
          } else {
            Text(store.errorMessage ?? "Plans are unavailable. Please try again.")
            Button("Retry") { Task { await load() } }
            Button("Continue with free access") { onLimited() }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingPalette.background)
      }
    }
    .task { await load() }
    .onChange(of: store.hasVerifiedEntitlement) { _, active in
      if active && entitlementError && !completionHandled {
        completionHandled = true
        onComplete()
      }
    }
    .alert("Purchases", isPresented: $entitlementError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Your purchase is processing. Access will update when Apple verifies it.")
    }
  }

  private func load() async {
    guard !isReady else { return }
    await store.load(.onboarding)
    guard !Task.isCancelled else { return }
    isReady = !store.products.isEmpty
  }

  private func finish() {
    guard !completionHandled else { return }
    if skipped {
      completionHandled = true
      onLimited()
      return
    }
    Task {
      await store.refreshEntitlements()
      if store.hasVerifiedEntitlement {
        completionHandled = true
        onComplete()
      } else {
        entitlementError = true
      }
    }
  }

  private var hiddenProductIDs: Set<String> {
    let available = Set(store.products.map(\.id))
    return Set(Premium.shared.availablePaywall.products.map(\.id)).subtracting(available)
  }

  private func artwork(_ number: Int) -> AdaptiveResources {
    AdaptiveResources(
      iphone: Image("Onboarding_\(number)"),
      iphoneS: Image("Onboarding_se\(number)"),
      ipadL: Image("Onboarding_landscape\(number)")
    )
  }

  private var screens: [OnboardingScreen] {
    [
      OnboardingScreen(
        id: 0, title1: "Someone Who", title2: "Gets You",
        subtitle:
          "Talk about anything with an AI companion who\nlistens, understands, and supports you",
        message: "Start a real conversation", images: artwork(1)
      ),
      OnboardingScreen(
        id: 1, title1: "Your Perfect", title2: "Companion",
        subtitle: "Choose who feels right today, or create a unique\ncompanion of your own",
        message: "Find your connection", images: artwork(2)
      ),
      OnboardingScreen(
        id: 2, title1: "We Value", title2: "Your Feedback",
        subtitle: "Any feedback is important to us\nso that we could improve our app",
        message: "Check why users love it", images: artwork(3)
      ),
      OnboardingScreen(
        id: 3, title1: "Unlock", title2: "Special Moments",
        subtitle: "Discover exclusive photos and videos as your\nconnection grows deeper",
        message: "See what awaits", images: artwork(4)
      ),
    ]
  }

  private var style: OnboardingStyle {
    OnboardingStyle(
      backgroundColor: OnboardingPalette.background,
      titleFont: .system(size: 24, weight: .heavy),
      title1Color: .white,
      title2Color: OnboardingPalette.dot,
      subtitleFont: .system(size: 14),
      subtitleColor: .white.opacity(0.8),
      messageFont: .system(size: 14),
      messageColor: .white,
      messageBackgroundColor: OnboardingPalette.pillFill,
      buttonFont: .system(size: 18, weight: .bold),
      buttonTextColor: OnboardingPalette.onGradient,
      buttonBackgroundColor: OnboardingPalette.gradient,
      linksColor: .white.opacity(0.8),
      contentSpacing: 8,
      indicatorActiveColor: OnboardingPalette.dot,
      indicatorInactiveColor: .white.opacity(0.2),
      indicatorFutureColor: .white.opacity(0.2),
      indicatorActiveWidth: 20,
      indicatorInactiveWidth: 10,
      indicatorHeight: 10,
      showNewToggle: true,
      checkmarkActiveBGColor: OnboardingPalette.dot,
      checkmarkInactiveBGColor: .clear,
      checkmarkActiveColor: OnboardingPalette.onGradient
    )
  }
}

#Preview {
  OnboardingView(onComplete: {}, onLimited: {})
    .preferredColorScheme(.dark)
}
