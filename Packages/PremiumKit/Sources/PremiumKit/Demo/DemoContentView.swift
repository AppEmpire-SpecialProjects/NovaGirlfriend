import SwiftUI
import StoreKit

public struct DemoContentView: View {
    @AppStorage("hasPassedOnboarding") var hasPassedOnboarding = false
    @ObservedObject private var premiumService = Premium.shared
    
    public init() {}
    
    public var body: some View {
        Group {
            if hasPassedOnboarding {
                DemoMainView()
                    .taskOnce {
                        await premiumService.loadPaywall(.main)
                    }
            } else {
                DemoOnboardingBuilderCustom(onComplete: {
                    hasPassedOnboarding = true
                })
                .taskOnce {
                    await premiumService.loadPaywall(.onboarding)
                }
            }
        }
        .overlay {
            if premiumService.isShowingSplash {
                DemoSplashView()
            }
        }
        .fullScreenCover(isPresented: $premiumService.isShowingPaywall) {
            DemoPaywallBuilderCustom()
        }
        .webBannerOverlay()
    }
}
