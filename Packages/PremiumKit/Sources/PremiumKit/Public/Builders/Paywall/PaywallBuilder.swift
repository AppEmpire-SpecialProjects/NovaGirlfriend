import SwiftUI
import UIKit

public struct PaywallBuilder<TermsView: View, PrivacyView: View>: View {
    @StateObject private var viewModel: PaywallBuilderViewModel
    @State private var isLandscape = UIDevice.current.orientation.isLandscape
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    private let style: PaywallStyle
    private let termsView: TermsView?
    private let privacyView: PrivacyView?
    private let termsURL: String?
    private let privacyURL: String?
    private let legalPresentation: LegalPresentationStyle
    private let linksConfig: LinksConfiguration
    private let backgroundContent: AnyView?
    private let middleContent: AnyView?
    private let overlayContent: AnyView?
    private let offerContent: ((String, Bool) -> AnyView)?
    private let subtitleText: ((String?) -> String)?
    private let buttonText: ((String?) -> String?)?
    private let onDebugUnlock: (() -> Void)?
    private let secondaryPaywallContent: AnyView?
    private let showCloseButton: Bool
    private let navigationBarHidden: Bool
    private let edgeToEdge: Bool
    private let showCancelledAlert: Bool
    
    public init(
        images: AdaptiveResources,
        style: PaywallStyle = .default,
        legalPresentation: LegalPresentationStyle = .sheet,
        linksConfig: LinksConfiguration = .default,
        showCloseButton: Bool = true,
        navigationBarHidden: Bool = false,
        edgeToEdge: Bool = false,
        showCancelledAlert: Bool = true,
        @ViewBuilder termsView: () -> TermsView,
        @ViewBuilder privacyView: () -> PrivacyView,
        backgroundView: AnyView? = nil,
        middleView: AnyView? = nil,
        overlayView: AnyView? = nil,
        offerView: ((String, Bool) -> AnyView)? = nil,
        subtitleText: ((String?) -> String)? = nil,
        buttonText: ((String?) -> String?)? = nil,
        onDebugUnlock: (() -> Void)? = nil,
        secondaryPaywallView: AnyView? = nil,
        hiddenProductIDs: Set<String> = [],
        onPaywallShown: (() -> Void)? = nil,
        onDismissTapped: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void,
        onSuccess: @escaping () -> Void
    ) {
        self.style = style
        self.termsView = termsView()
        self.privacyView = privacyView()
        self.termsURL = nil
        self.privacyURL = nil
        self.legalPresentation = legalPresentation
        self.linksConfig = linksConfig
        self.showCloseButton = showCloseButton
        self.navigationBarHidden = navigationBarHidden
        self.edgeToEdge = edgeToEdge
        self.showCancelledAlert = showCancelledAlert
        self.backgroundContent = backgroundView
        self.middleContent = middleView
        self.overlayContent = overlayView
        self.offerContent = offerView
        self.subtitleText = subtitleText
        self.buttonText = buttonText
        self.onDebugUnlock = onDebugUnlock
        self.secondaryPaywallContent = secondaryPaywallView
        _viewModel = StateObject(wrappedValue: PaywallBuilderViewModel(
            images: images,
            style: style,
            hasSecondaryPaywall: secondaryPaywallView != nil,
            hiddenProductIDs: hiddenProductIDs,
            onPaywallShown: onPaywallShown,
            onDismissTapped: onDismissTapped,
            onDismiss: onDismiss,
            onSuccess: onSuccess
        ))
    }
    
    public var body: some View {
        if viewModel.isShowingSecondPaywall, let secondaryView = secondaryPaywallContent {
            secondaryView
        } else {
            mainContent
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if edgeToEdge {
            GeometryReader { _ in
                paywallContent
                    .ignoresSafeArea()
                    .overlay(alignment: .topTrailing) {
                        if showCloseButton {
                            closeButton
                                .padding(.trailing, 16)
                        }
                    }
            }
        } else {
            NavigationStack {
                paywallContent
            }
        }
    }

    private var paywallContent: some View {
        ZStack {
            if let bg = backgroundContent {
                bg
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            } else {
                backgroundImage
            }

            VStack {
                if let middle = middleContent {
                    middle
                }
                Spacer()

                HStack {
                    content
                }
                .frame(maxWidth: .infinity)
                .background {
                    if style.contentBackgroundShow {
                        contentBackground
                            .padding(.horizontal, style.contentBackgroundPadding.horizontal)
                            .padding(.bottom, style.contentBackgroundPadding.bottom)
                    }
                }
            }
        }
        .overlay {
            if let overlay = overlayContent {
                overlay
            }
        }
        .toolbar {
            if showCloseButton && !edgeToEdge {
                if style.closeButtonShowGlass {
                    ToolbarItem(placement: style.closeButtonPlacement.toolbarPlacement) {
                        closeButton
                    }
                } else {
                    ToolbarItem(placement: style.closeButtonPlacement.toolbarPlacement) {
                        closeButton
                    }
                    .hideGlass()
                }
            }
        }
        .overlay { loadingOverlay }
        .alert(isPresented: $viewModel.isShowAlert) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
        .alert(Text(viewModel.alertMessage), isPresented: showCancelledAlert ? $viewModel.isShowCancelledAlert : .constant(false)) {
            Button(L10n.Alert.cancel, role: .cancel) { }
            Button(L10n.Alert.retry) { viewModel.retryPurchase() }
        } message: {
            Text(L10n.Alert.retryMessage)
        }
        .legalPresentation(
            style: legalPresentation,
            showTerms: $showTerms,
            showPrivacy: $showPrivacy,
            termsView: termsView,
            privacyView: privacyView
        )
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            isLandscape = UIDevice.current.orientation.isValidInterfaceOrientation
                ? UIDevice.current.orientation.isLandscape
                : UIScreen.main.bounds.width > UIScreen.main.bounds.height
        }
        .onAppear {
            viewModel.paywallShown()
        }
        .navigationBarHidden(navigationBarHidden)
    }

    @ViewBuilder
    private var backgroundImage: some View {
        viewModel.currentImage(isLandscape: isLandscape)
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .clipped()
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var contentBackground: some View {
        let hasPadding = style.contentBackgroundPadding.horizontal > 0 || style.contentBackgroundPadding.bottom > 0
        
        if hasPadding {
            RoundedRectangle(cornerRadius: style.contentBackgroundCornerRadius)
                .foregroundStyle(style.contentBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: style.contentBackgroundCornerRadius)
                        .strokeBorder(style.contentBackgroundBorderColor, lineWidth: style.contentBackgroundBorderWidth)
                )
                .shadow(
                    color: style.contentBackgroundShadow?.color ?? .clear,
                    radius: style.contentBackgroundShadow?.radius ?? 0,
                    x: style.contentBackgroundShadow?.x ?? 0,
                    y: style.contentBackgroundShadow?.y ?? 0
                )
        } else {
            UnevenRoundedRectangle(
                topLeadingRadius: style.contentBackgroundCornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: style.contentBackgroundCornerRadius
            )
            .foregroundStyle(style.contentBackgroundColor)
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: style.contentBackgroundCornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: style.contentBackgroundCornerRadius
                )
                .strokeBorder(style.contentBackgroundBorderColor, lineWidth: style.contentBackgroundBorderWidth)
            )
            .shadow(
                color: style.contentBackgroundShadow?.color ?? .clear,
                radius: style.contentBackgroundShadow?.radius ?? 0,
                x: style.contentBackgroundShadow?.x ?? 0,
                y: style.contentBackgroundShadow?.y ?? 0
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    @ViewBuilder
    private var closeButton: some View {
        Button(action: { viewModel.dismissTapped() }) {
            Image(systemName: style.closeButtonIcon)
                .foregroundStyle(style.closeButtonColor)
                .font(style.closeButtonFont)
                .padding(8)
                .background {
                    if style.closeButtonShowBackground {
                        Circle()
                            .fill(style.closeButtonBackgroundColor)
                    }
                }
        }
        .simultaneousGesture(LongPressGesture(minimumDuration: 10).onEnded { _ in
            Premium.shared.grantPremium()
            onDebugUnlock?()
            viewModel.onDismiss()
        })
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            BlurEffectView()
                .ignoresSafeArea()
                .overlay {
                    ProgressView()
                        .tint(.white)
                        .padding(20)
                        .background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(spacing: style.contentSpacing) {
            VStack(spacing: style.titleSubtitleSpacing) {
                if style.titleOrder == .titleFirst {
                    titleSection
                        .padding(.bottom, style.titleBottomPadding)
                    subtitleSection
                        .padding(.bottom, style.subtitleBottomPadding)
                } else {
                    subtitleSection
                        .padding(.bottom, style.subtitleBottomPadding)
                    titleSection
                        .padding(.bottom, style.titleBottomPadding)
                }
            }
            offers
                .padding(.bottom, style.offersBottomPadding)
            nextButton
                .padding(.bottom, style.buttonBottomPadding)
            links
                .padding(.bottom, style.linksBottomPadding)
        }
        .padding(.top, style.contentBackgroundShow ? 24 : 0)
        .padding(.horizontal, style.horizontalPadding)
        .padding(.bottom, style.bottomPadding)
        .frame(maxWidth: style.maxWidth)
    }
    
    @ViewBuilder
    private var subtitleSection: some View {
        Text(subtitleText?(viewModel.selectedProduct?.id) ?? viewModel.subtitle())
            .font(style.subtitleFont)
            .foregroundStyle(style.subtitleColor)
            .fixedSize(horizontal: false, vertical: style.subtitleFixedSize)
    }
    
    @ViewBuilder
    private var titleSection: some View {
        Text(viewModel.title())
            .font(style.titleFont)
            .foregroundStyle(style.titleColor)
            .fixedSize(horizontal: false, vertical: style.titleFixedSize)
    }
    
    @ViewBuilder
    private var offers: some View {
        VStack(spacing: style.offerSpacing) {
            ForEach(Array(viewModel.products.enumerated()), id: \.offset) { index, product in
                Button {
                    viewModel.selectProduct(at: index)
                    Task {
                        await viewModel.purchase()
                    }
                } label: {
                    if let offerContent {
                        offerContent(product.id, viewModel.selectedIndex == index)
                    } else {
                        offerRow(product: product, index: index)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func offerRow(product: PremiumProduct, index: Int) -> some View {
        let isSelected = viewModel.selectedIndex == index
        
        HStack(spacing: 12) {
            if style.offerShowCheckmark {
                offerCheckmark(isSelected: isSelected)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.hasTrial ? L10n.Product.trialTitle : product.title)
                    .font(isSelected ? style.offerSelectedTitleFont : style.offerTitleFont)
                    .foregroundStyle(isSelected ? style.offerSelectedTitleColor : style.offerTitleColor)
                
                Text(product.pricePerWeek)
                    .font(isSelected ? style.offerSelectedSubtitleFont : style.offerSubtitleFont)
                    .foregroundStyle(isSelected ? style.offerSelectedSubtitleColor : style.offerSubtitleColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if style.offerShowDivider {
                Rectangle()
                    .fill(isSelected ? style.offerDividerActiveColor : style.offerDividerInactiveColor)
                    .frame(
                        width: isSelected ? style.offerDividerActiveWidth : style.offerDividerInactiveWidth,
                        height: isSelected ? style.offerDividerActiveHeight : style.offerDividerInactiveHeight
                    )
                    .padding(.horizontal, style.offerDividerPaddingHorizontal)
                    .padding(.vertical, style.offerDividerPaddingVertical)
            }
            
            Text(product.pricePerPeriod)
                .font(isSelected ? style.offerSelectedPriceFont : style.offerPriceFont)
                .foregroundStyle(isSelected ? style.offerSelectedPriceColor : style.offerPriceColor)
                .frame(width: style.offerShowDivider ? style.offerPriceWidth : nil, alignment: .trailing)
        }
        .padding(.horizontal)
        .frame(height: style.offerHeight)
        .background(isSelected ? style.offerSelectedBackgroundColor : style.offerBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: style.offerCornerRadius))
        .shadow(
            color: (isSelected ? style.offerSelectedShadow?.color : style.offerShadow?.color) ?? .clear,
            radius: (isSelected ? style.offerSelectedShadow?.radius : style.offerShadow?.radius) ?? 0,
            x: (isSelected ? style.offerSelectedShadow?.x : style.offerShadow?.x) ?? 0,
            y: (isSelected ? style.offerSelectedShadow?.y : style.offerShadow?.y) ?? 0
        )
        .overlay(
            RoundedRectangle(cornerRadius: style.offerCornerRadius)
                .stroke(isSelected ? style.offerSelectedBorderColor : style.offerBorderColor, lineWidth: isSelected ? style.offerSelectedBorderWidth : style.offerBorderWidth)
        )
    }
    
    @ViewBuilder
    private func offerCheckmark(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? style.offerCheckmarkActiveBGColor : style.offerCheckmarkInactiveBGColor)
                .frame(width: style.offerCheckmarkSize, height: style.offerCheckmarkSize)
            
            Circle()
                .stroke(isSelected ? style.offerCheckmarkActiveBorderColor : style.offerCheckmarkInactiveBorderColor, lineWidth: 1.5)
                .frame(width: style.offerCheckmarkSize, height: style.offerCheckmarkSize)
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: style.offerCheckmarkIconSize, weight: style.offerCheckmarkIconWeight))
                    .foregroundStyle(style.offerCheckmarkActiveColor)
            }
        }
    }
    
    @ViewBuilder
    private var nextButton: some View {
        AnimatedScaleButton(
            isActive: style.showPaywallButtonAnimation,
            duration: style.buttonAnimationDuration,
            scale: style.buttonAnimationScale,
            action: { Task { await viewModel.purchase() } }
        ) {
            Text(buttonText?(viewModel.selectedProduct?.id) ?? viewModel.buttonTitle())
                .font(style.buttonFont)
                .foregroundStyle(style.buttonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: style.buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: style.buttonCornerRadius)
                        .fill(style.buttonBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: style.buttonCornerRadius)
                        .stroke(style.buttonBorderColor, lineWidth: style.buttonBorderWidth)
                        .opacity(style.buttonShowBorder ? 1 : 0)
                )
        }
        .disabled(viewModel.isLoading)
    }
    
    @ViewBuilder
    private var links: some View {
        HStack(spacing: style.linksSpacing) {
            ForEach(Array(linksConfig.order.enumerated()), id: \.offset) { index, linkType in
                if index > 0 && style.linksShowDividers {
                    linksDivider
                }
                
                switch linkType {
                case .terms:
                    Button(linksConfig.termsTitle) { openTerms() }
                case .privacy:
                    Button(linksConfig.privacyTitle) { openPrivacy() }
                case .restore:
                    Button(linksConfig.restoreTitle) {
                        Task { await viewModel.restore() }
                    }
                }
            }
        }
        .font(style.linksFont)
        .foregroundStyle(style.linksColor)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 20)
    }
    
    private var linksDivider: some View {
        RoundedRectangle(cornerRadius: 100)
            .fill(style.linksColor)
            .frame(width: 1, height: 20)
    }
    
    private func openTerms() {
        if let urlString = termsURL, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        } else {
            showTerms = true
        }
    }
    
    private func openPrivacy() {
        if let urlString = privacyURL, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        } else {
            showPrivacy = true
        }
    }
}

extension PaywallBuilder where TermsView == EmptyView, PrivacyView == EmptyView {
    public init(
        images: AdaptiveResources,
        style: PaywallStyle = .default,
        linksConfig: LinksConfiguration = .default,
        showCloseButton: Bool = true,
        navigationBarHidden: Bool = false,
        edgeToEdge: Bool = false,
        showCancelledAlert: Bool = true,
        termsURL: String? = nil,
        privacyURL: String? = nil,
        backgroundView: AnyView? = nil,
        middleView: AnyView? = nil,
        overlayView: AnyView? = nil,
        offerView: ((String, Bool) -> AnyView)? = nil,
        subtitleText: ((String?) -> String)? = nil,
        buttonText: ((String?) -> String?)? = nil,
        onDebugUnlock: (() -> Void)? = nil,
        secondaryPaywallView: AnyView? = nil,
        hiddenProductIDs: Set<String> = [],
        onPaywallShown: (() -> Void)? = nil,
        onDismissTapped: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void,
        onSuccess: @escaping () -> Void
    ) {
        self.style = style
        self.termsView = nil
        self.privacyView = nil
        self.termsURL = termsURL
        self.privacyURL = privacyURL
        self.legalPresentation = .sheet
        self.linksConfig = linksConfig
        self.showCloseButton = showCloseButton
        self.navigationBarHidden = navigationBarHidden
        self.edgeToEdge = edgeToEdge
        self.showCancelledAlert = showCancelledAlert
        self.backgroundContent = backgroundView
        self.middleContent = middleView
        self.overlayContent = overlayView
        self.offerContent = offerView
        self.subtitleText = subtitleText
        self.buttonText = buttonText
        self.onDebugUnlock = onDebugUnlock
        self.secondaryPaywallContent = secondaryPaywallView
        _viewModel = StateObject(wrappedValue: PaywallBuilderViewModel(
            images: images,
            style: style,
            hasSecondaryPaywall: secondaryPaywallView != nil,
            hiddenProductIDs: hiddenProductIDs,
            onPaywallShown: onPaywallShown,
            onDismissTapped: onDismissTapped,
            onDismiss: onDismiss,
            onSuccess: onSuccess
        ))
    }
}

private extension View {
    @ViewBuilder
    func legalPresentation<T: View, P: View>(
        style: LegalPresentationStyle,
        showTerms: Binding<Bool>,
        showPrivacy: Binding<Bool>,
        termsView: T?,
        privacyView: P?
    ) -> some View {
        switch style {
        case .sheet:
            self
                .sheet(isPresented: showTerms) { termsView }
                .sheet(isPresented: showPrivacy) { privacyView }
        case .fullScreenCover:
            self
                .fullScreenCover(isPresented: showTerms) { termsView }
                .fullScreenCover(isPresented: showPrivacy) { privacyView }
        }
    }
}
