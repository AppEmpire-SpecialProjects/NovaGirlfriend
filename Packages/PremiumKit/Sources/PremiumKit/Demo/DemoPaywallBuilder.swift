import SwiftUI

public struct DemoPaywallBuilderDefault: View {
    @Environment(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some View {
        PaywallBuilder(
            images: AdaptiveResources(iphone: Image("")),
            onDismiss: { dismiss() },
            onSuccess: { dismiss() }
        )
    }
}

public struct DemoPaywallBuilderCustom: View {
    @Environment(\.dismiss) var dismiss
    
    public init() {}
    
    private var customStyle: PaywallStyle {
        PaywallStyle(
            accentColor: .purple,
            backgroundColor: .black,
            contentBackgroundBorderColor: Color.clear,
            contentBackgroundBorderWidth: 0.5,
            contentBackgroundShadow: nil,
            contentBackgroundPadding: BackgroundPadding(horizontal: 20, bottom: 20),
            titleOrder: .subtitleFirst,
            titleFont: .system(size: 28, weight: .bold),
            titleColor: .black,
            titleBottomPadding: 0,
            subtitleFont: .system(size: 15, weight: .medium),
            subtitleColor: .purple.opacity(0.7),
            subtitleBottomPadding: 0,
            titleSubtitleSpacing: 0,
            buttonFont: .system(size: 18, weight: .bold),
            buttonTextColor: .white,
            buttonBackgroundColor: LinearGradient(
                colors: [.purple, .pink],
                startPoint: .leading,
                endPoint: .trailing
            ),
            buttonCornerRadius: 16,
            buttonHeight: 52,
            buttonBottomPadding: 0,
            linksFont: .system(size: 12, weight: .regular),
            linksColor: .purple.opacity(0.5),
            linksShowDividers: false,
            linksBottomPadding: 0,
            horizontalPadding: 16,
            bottomPadding: UIDevice.isIpad ? 40 : 60,
            offerHeight: 64,
            offerCornerRadius: 16,
            offerSpacing: 4,
            offersBottomPadding: 0,
            offerTitleFont: .system(size: 17, weight: .bold),
            offerTitleColor: .purple,
            offerSelectedTitleFont: .system(size: 17, weight: .bold),
            offerSelectedTitleColor: .purple,
            offerSubtitleFont: .system(size: 14, weight: .regular),
            offerSubtitleColor: .purple.opacity(0.6),
            offerSelectedSubtitleFont: .system(size: 14, weight: .regular),
            offerSelectedSubtitleColor: Color.purple.opacity(0.6),
            offerPriceFont: .system(size: 17, weight: .bold),
            offerPriceColor: .purple,
            offerSelectedPriceFont: .system(size: 17, weight: .bold),
            offerSelectedPriceColor: .purple,
            offerBorderColor: .purple.opacity(0.2),
            offerSelectedBorderColor: .purple,
            offerBorderWidth: 0,
            offerSelectedBorderWidth: 0.5,
            offerShowCheckmark: true,
            offerCheckmarkSize: 22,
            offerCheckmarkActiveBGColor: .white,
            offerCheckmarkInactiveBGColor: .white,
            offerCheckmarkActiveColor: .purple,
            offerCheckmarkInactiveColor: .white,
            offerCheckmarkActiveBorderColor: .gray.opacity(0.3),
            offerCheckmarkInactiveBorderColor: .clear,
            offerCheckmarkIconSize: 14,
            offerCheckmarkIconWeight: .semibold,
            offerShowDivider: true,
            offerDividerActiveColor: .black,
            offerDividerInactiveColor: .black,
            closeButtonIcon: "xmark",
            closeButtonColor: .white,
            closeButtonPlacement: .topBarLeading,
            closeButtonShowGlass: false
        )
    }
    
    public var body: some View {
        PaywallBuilder(
            images: AdaptiveResources(iphone: Image("")),
            style: customStyle,
            legalPresentation: .sheet,
            termsView: { DemoTermsView() },
            privacyView: { DemoPrivacyView() },
            onDismiss: { dismiss() },
            onSuccess: { dismiss() }
        )
    }
}
