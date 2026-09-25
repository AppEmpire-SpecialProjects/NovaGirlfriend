import SwiftUI

public struct DemoOnboardingBuilderDefault: View {
    let onComplete: () -> Void
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        OnboardingBuilder(
            screens: [
                OnboardingScreen(
                    id: 0,
                    title1: "Welcome to",
                    title2: "PremiumKit",
                    subtitle: "Discover amazing\nfeatures",
                    message: "Start your journey",
                    images: AdaptiveResources(iphone: Image(""))
                ),
                OnboardingScreen(
                    id: 1,
                    title1: "Stay",
                    title2: "Organized",
                    subtitle: "Keep everything\nin one place",
                    message: "Manage with ease",
                    images: AdaptiveResources(iphone: Image(""))
                ),
                OnboardingScreen(
                    id: 2,
                    title1: "Get",
                    title2: "Started",
                    subtitle: "Begin your\njourney today",
                    message: "Use now!",
                    images: AdaptiveResources(iphone: Image(""))
                )
            ],
            paywallImages: AdaptiveResources(iphone: Image("")),
            showReviewRequestOnComplete: true,
            requestReviewSetup: RequestReviewSetup(launch: 2),
            onComplete: onComplete
        )
    }
}

public struct DemoOnboardingBuilderCustom: View {
    let onComplete: () -> Void
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    private var customStyle: OnboardingStyle {
        OnboardingStyle(
            priceCustomization: [.heavy, .underline],
            limitedButtonUnderline: true,
            toggleColor: .pink,
            backgroundColor: .black,
            contentBackgroundShow: false,
            contentBackgroundColor: Color.blue.opacity(0.3),
            contentBackgroundCornerRadius: 32,
            contentBackgroundBorderColor: Color.clear,
            contentBackgroundBorderWidth: 0.5,
            contentBackgroundShadow: nil,
            contentBackgroundPadding: BackgroundPadding(horizontal: 20, bottom: 40),
            titleFont: .system(size: 26, weight: .heavy),
            title1Color: .black,
            title2Color: LinearGradient(
                colors: [.pink, .purple],
                startPoint: .leading,
                endPoint: .trailing
            ),
            titleBottomPadding: 0,
            subtitleFont: .system(size: 15, weight: .regular),
            subtitleColor: Color.secondary.opacity(0.6),
            subtitleBottomPadding: 0,
            messageFont: .system(size: 15, weight: .regular),
            messageColor: .black,
            messageBackgroundColor: Color.secondary.opacity(0.1),
            messageHeight: 48,
            messageCornerRadius: 100,
            messageBottomPadding: 0,
            buttonFont: .system(size: 20, weight: .bold),
            buttonTextColor: .white,
            buttonBackgroundColor: LinearGradient(
                colors: [.pink, .purple],
                startPoint: .leading,
                endPoint: .trailing
            ),
            buttonCornerRadius: 100,
            buttonHeight: 56,
            showPaywallButtonAnimation: true,
            buttonBottomPadding: 0,
            linksFont: .system(size: 13, weight: .regular),
            linksColor: Color.secondary.opacity(0.3),
            linksSpacing: 10,
            linksShowDividers: true,
            linksBottomPadding: 0,
            contentSpacing: 20,
            horizontalPadding: 16,
            bottomPadding: 40,
            indicatorActiveColor: LinearGradient(
                colors: [.pink, .purple],
                startPoint: .leading,
                endPoint: .trailing
            ),
            indicatorInactiveColor: Color.pink.opacity(0.2),
            indicatorFutureColor: Color.pink.opacity(0.2),
            indicatorActiveWidth: 24,
            indicatorInactiveWidth: 6,
            indicatorHeight: 6,
            indicatorActiveHeight: 6,
            indicatorInactiveHeight: 6,
            indicatorSpacing: 4,
            indicatorsBottomPadding: 0
        )
    }
    
    public var body: some View {
        OnboardingBuilder(
            screens: [
                OnboardingScreen(
                    id: 0,
                    title1: "Welcome to",
                    title2: "PremiumKit",
                    subtitle: "Discover\namazing features",
                    message: "Start your journey",
                    images: AdaptiveResources(iphone: Image(""))
                ),
                OnboardingScreen(
                    id: 1,
                    title1: "Stay",
                    title2: "Organized",
                    subtitle: "Keep everything\nin one place",
                    message: "Manage with ease",
                    images: AdaptiveResources(iphone: Image(""))
                ),
                OnboardingScreen(
                    id: 2,
                    title1: "Get",
                    title2: "Started",
                    subtitle: "Begin your\njourney today",
                    message: "Enjoy",
                    images: AdaptiveResources(iphone: Image(""))
                )
            ],
            paywallImages: AdaptiveResources(iphone: Image("")),
            style: customStyle,
            requestReviewSetup: RequestReviewSetup(launch: 2),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            onComplete: onComplete
        )
    }
}
