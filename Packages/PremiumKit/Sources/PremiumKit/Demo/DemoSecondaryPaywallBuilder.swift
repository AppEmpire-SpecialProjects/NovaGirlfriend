import SwiftUI

public struct DemoSecondaryPaywallBuilderDefault: View {
    @Environment(\.dismiss) var dismiss

    public init() {}

    public var body: some View {
        SecondaryPaywallBuilder(
            paywallID: PremiumPaywallID("second_group"),
            images: AdaptiveResources(iphone: Image("")),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            onDismiss: { dismiss() },
            onSuccess: { dismiss() }
        )
    }
}

public struct DemoSecondaryPaywallBuilderCustom: View {
    @Environment(\.dismiss) var dismiss

    public init() {}

    private var customStyle: SecondaryPaywallStyle {
        SecondaryPaywallStyle(
            contentBackground: .init(
                show: true,
                color: Color.black.opacity(0.7),
                cornerRadius: 32
            ),
            title: .init(
                font: .system(size: 28, weight: .black),
                color1: Color.white,
                color2: Color.white.opacity(0.8),
                subtitleColor: Color.white.opacity(0.6),
                limitedButtonUnderline: true,
                priceCustomization: [.heavy, .underline]
            ),
            messageToggle: .init(
                color: Color.white,
                backgroundColor: Color.white.opacity(0.15),
                toggleColor: .pink
            ),
            offer: .init(
                cornerRadius: 16,
                selectedTitleColor: Color.pink,
                selectedBorderColor: Color.pink,
                selectedBorderWidth: 1,
                checkmarkActiveBGColor: Color.pink,
                checkmarkActiveColor: Color.white
            ),
            button: .init(
                font: .system(size: 18, weight: .bold),
                backgroundColor: LinearGradient(
                    colors: [.pink, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                cornerRadius: 16,
                showAnimation: true
            ),
            links: .init(
                color: Color.white.opacity(0.5),
                showDividers: false
            ),
            closeButton: .init(
                color: Color.white,
                showGlass: false
            )
        )
    }

    public var body: some View {
        SecondaryPaywallBuilder(
            paywallID: PremiumPaywallID("second_group"),
            images: AdaptiveResources(iphone: Image("")),
            style: customStyle,
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            onDismiss: { dismiss() },
            onSuccess: { dismiss() }
        )
    }
}

public struct DemoOnboardingWithSecondaryPaywall: View {
    let onComplete: () -> Void

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    private let adaptiveImages = AdaptiveResources(iphone: Image(""))

    public var body: some View {
        OnboardingBuilder(
            screens: [
                OnboardingScreen(
                    id: 0,
                    title1: "Welcome to",
                    title2: "PremiumKit",
                    subtitle: "Discover amazing\nfeatures",
                    message: "Start your journey",
                    images: adaptiveImages
                ),
                OnboardingScreen(
                    id: 1,
                    title1: "Get",
                    title2: "Started",
                    subtitle: "Begin your\njourney today",
                    message: "Enjoy",
                    images: adaptiveImages
                )
            ],
            paywallImages: adaptiveImages,
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            secondaryPaywallView: AnyView(secondaryPaywall),
            onComplete: onComplete
        )
    }

    private var secondaryPaywall: some View {
        SecondaryPaywallBuilder(
            paywallID: PremiumPaywallID("second_group"),
            images: adaptiveImages,
            style: SecondaryPaywallStyle(
                contentBackground: .init(show: true, color: Color.black.opacity(0.7), cornerRadius: 32),
                title: .init(color1: Color.white, color2: Color.white.opacity(0.8)),
                links: .init(color: Color.white.opacity(0.6)),
                closeButton: .init(color: Color.white)
            ),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            onDismiss: onComplete,
            onSuccess: onComplete
        )
    }
}
