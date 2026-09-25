import SwiftUI
import UIKit

public struct OnboardingBuilder<TermsView: View, PrivacyView: View>: View {
    @StateObject private var viewModel: OnboardingBuilderViewModel
    @State private var isLandscape = UIDevice.current.orientation.isLandscape
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    private let style: OnboardingStyle
    private let termsView: TermsView?
    private let privacyView: PrivacyView?
    private let termsURL: String?
    private let privacyURL: String?
    private let legalPresentation: LegalPresentationStyle
    private let linksConfig: LinksConfiguration
    private let paywallBackgroundContent: AnyView?
    private let paywallMiddleContent: AnyView?
    private let paywallOverlayContent: AnyView?
    private let secondaryPaywallContent: AnyView?
    private let secondaryPaywallBackgroundContent: AnyView?
    private let secondaryPaywallMiddleContent: AnyView?
    private let secondaryPaywallOverlayContent: AnyView?
    private let secondaryPaywallPickerSubtitle: SecondaryPaywallPickerSubtitle?
    private let showCancelledAlert: Bool
    private let controller: OnboardingController?
    
    public init(
        screens: [OnboardingScreen],
        paywallImages: AdaptiveResources,
        style: OnboardingStyle = .default,
        paywallHideContent: [OnboardingContentElement] = [],
        paywallCopy: OnboardingPaywallCopy? = nil,
        legalPresentation: LegalPresentationStyle = .sheet,
        linksConfig: LinksConfiguration = .default,
        isTrialEnabled: Bool = false,
        showReviewRequestOnComplete: Bool = true,
        requestReviewSetup: RequestReviewSetup? = nil,
        showCancelledAlert: Bool = true,
        @ViewBuilder termsView: () -> TermsView,
        @ViewBuilder privacyView: () -> PrivacyView,
        paywallBackgroundView: AnyView? = nil,
        paywallMiddleView: AnyView? = nil,
        paywallOverlayView: AnyView? = nil,
        secondaryPaywallView: AnyView? = nil,
        secondaryPaywallID: PremiumPaywallID? = nil,
        secondaryPaywallImages: AdaptiveResources? = nil,
        secondaryPaywallBackgroundView: AnyView? = nil,
        secondaryPaywallMiddleView: AnyView? = nil,
        secondaryPaywallOverlayView: AnyView? = nil,
        secondaryPaywallCountsAsStep: Bool = false,
        secondaryPaywallPickerSubtitle: SecondaryPaywallPickerSubtitle? = nil,
        hiddenProductIDs: Set<String> = [],
        secondaryHiddenProductIDs: Set<String> = [],
        controller: OnboardingController? = nil,
        onScreenShown: ((Int, Int) -> Void)? = nil,
        onNextTapped: ((Int, Int) -> Void)? = nil,
        onLimitedTapped: (() -> Void)? = nil,
        onSecondaryLimitedTapped: (() -> Void)? = nil,
        onPaywallShown: (() -> Void)? = nil,
        onSecondaryPaywallShown: (() -> Void)? = nil,
        onComplete: @escaping () -> Void
    ) {
        self.style = style
        self.controller = controller
        self.termsView = termsView()
        self.privacyView = privacyView()
        self.termsURL = nil
        self.privacyURL = nil
        self.legalPresentation = legalPresentation
        self.linksConfig = linksConfig
        self.showCancelledAlert = showCancelledAlert
        self.paywallBackgroundContent = paywallBackgroundView
        self.paywallMiddleContent = paywallMiddleView
        self.paywallOverlayContent = paywallOverlayView
        self.secondaryPaywallContent = secondaryPaywallView
        self.secondaryPaywallBackgroundContent = secondaryPaywallBackgroundView
        self.secondaryPaywallMiddleContent = secondaryPaywallMiddleView
        self.secondaryPaywallOverlayContent = secondaryPaywallOverlayView
        self.secondaryPaywallPickerSubtitle = secondaryPaywallPickerSubtitle
        _viewModel = StateObject(wrappedValue: OnboardingBuilderViewModel(
            screens: screens,
            paywallImages: paywallImages,
            style: style,
            paywallHideContent: paywallHideContent,
            paywallCopy: paywallCopy,
            isTrialEnabled: isTrialEnabled,
            showReviewRequestOnComplete: showReviewRequestOnComplete,
            requestReviewSetup: requestReviewSetup,
            hasSecondaryPaywall: secondaryPaywallView != nil,
            secondaryPaywallID: secondaryPaywallID,
            secondaryPaywallImages: secondaryPaywallImages,
            secondaryPaywallCountsAsStep: secondaryPaywallCountsAsStep,
            hiddenProductIDs: hiddenProductIDs,
            secondaryHiddenProductIDs: secondaryHiddenProductIDs,
            onScreenShown: onScreenShown,
            onNextTapped: onNextTapped,
            onLimitedTapped: onLimitedTapped,
            onSecondaryLimitedTapped: onSecondaryLimitedTapped,
            onPaywallShown: onPaywallShown,
            onSecondaryPaywallShown: onSecondaryPaywallShown,
            onComplete: onComplete
        ))
    }
    
    public var body: some View {
        Group {
            if !viewModel.hasEmbeddedSecondary, viewModel.isShowingSecondPaywall, let secondaryView = secondaryPaywallContent {
                secondaryView
                    .onDisappear {
                        viewModel.performReviewOnComplete()
                    }
            } else {
                mainContent
            }
        }
        .onAppear {
            controller?.onNext = { viewModel.nextTapped() }
            viewModel.notifyScreenShown()
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        VStack {
            if viewModel.isSecondaryStep, let middle = secondaryPaywallMiddleContent {
                middle
            } else if viewModel.isPaywallStep, let middle = paywallMiddleContent {
                middle
            } else if let middle = viewModel.currentScreen?.middleContent {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if viewModel.isSecondaryStep, let bg = secondaryPaywallBackgroundContent {
                bg.ignoresSafeArea()
            } else if viewModel.isPaywallStep, let bg = paywallBackgroundContent {
                bg.ignoresSafeArea()
            } else if !viewModel.isSecondaryStep, let bg = viewModel.currentScreen?.backgroundContent {
                bg.ignoresSafeArea()
            } else {
                backgroundImage
            }
        }
        .overlay {
            if viewModel.isSecondaryStep, let overlay = secondaryPaywallOverlayContent {
                overlay
            } else if viewModel.isPaywallStep, let overlay = paywallOverlayContent {
                overlay
            } else if let overlay = viewModel.currentScreen?.overlayContent {
                overlay
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(style.backgroundColor)
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
        .alert(L10n.Alert.trialExpiredTitle, isPresented: $viewModel.showTrialExpiredAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(L10n.Alert.trialExpiredMessage)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            isLandscape = UIDevice.current.orientation.isValidInterfaceOrientation
                ? UIDevice.current.orientation.isLandscape
                : UIScreen.main.bounds.width > UIScreen.main.bounds.height
        }
        .legalPresentation(
            style: legalPresentation,
            showTerms: $showTerms,
            showPrivacy: $showPrivacy,
            termsView: termsView,
            privacyView: privacyView
        )
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
            ForEach(style.contentOrder, id: \.self) { element in
                switch element {
                case .indicators:
                    if !viewModel.isHideContent(for: element) {
                        indicators.padding(.bottom, style.indicatorsBottomPadding)
                    }
                case .title:
                    if !viewModel.isHideContent(for: element) {
                        if !viewModel.isPickerActive {
                            titleSection.padding(.bottom, style.titleBottomPadding)
                        }
                    }
                case .subtitle:
                    if !viewModel.isHideContent(for: element) {
                        subtitleSection.padding(.bottom, style.subtitleBottomPadding)
                    }
                case .message:
                    if viewModel.showMessageSection {
                        if !viewModel.isHideContent(for: element) {
                            messageSection.padding(.bottom, style.messageBottomPadding)
                        }
                    }
                case .button:
                    EmptyView()
                }
            }
            
            VStack(spacing: 6) {
                if !viewModel.isHideContent(for: .button) {
                    nextButton
                        .padding(.bottom, style.buttonBottomPadding)
                }
                links
                    .padding(.bottom, style.linksBottomPadding)
            }
        }
        .padding(.top, style.contentBackgroundShow ? 24 : 0)
        .padding(.horizontal, style.horizontalPadding)
        .padding(.bottom, style.bottomPadding)
        .frame(maxWidth: style.maxWidth)
    }
    
    @ViewBuilder
    private var indicators: some View {
        HStack(spacing: style.indicatorSpacing) {
            ForEach(0..<viewModel.totalSteps, id: \.self) { index in
                let color: AnyShapeStyle = {
                    if index < viewModel.indicatorIndex {
                        return style.indicatorInactiveColor
                    } else if index == viewModel.indicatorIndex {
                        return style.indicatorActiveColor
                    } else {
                        return style.indicatorFutureColor
                    }
                }()
                
                RoundedRectangle(cornerRadius: style.indicatorCornerRadius)
                    .fill(color)
                    .frame(width: index == viewModel.indicatorIndex ? style.indicatorActiveWidth : style.indicatorInactiveWidth,
                        height: index == viewModel.indicatorIndex ? style.indicatorActiveHeight : style.indicatorInactiveHeight)
            }
        }
        .padding(.horizontal, style.indicatorHorizontalPadding)
        .padding(.vertical, style.indicatorVerticalPadding)
        .background(
            style.indicatorBackgroundColor,
            in: RoundedRectangle(cornerRadius: style.indicatorBackgroundCornerRadius)
        )
        .animation(.easeInOut(duration: 0.3), value: viewModel.indicatorIndex)
    }
    
    @ViewBuilder
    private var titleSection: some View {
        let t1 = viewModel.title1()
        let t2 = viewModel.title2()
        
        if !t1.isEmpty || !t2.isEmpty {
            VStack(spacing: 0) {
                if !t1.isEmpty {
                    Text(t1)
                        .font(style.titleFont)
                        .foregroundStyle(style.title1Color)
                        .minimumScaleFactor(style.minimumScaleFactor)
                }
                
                if !t2.isEmpty {
                    Text(t2)
                        .font(style.titleFont)
                        .foregroundStyle(style.title2Color)
                        .minimumScaleFactor(style.minimumScaleFactor)
                }
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: style.titleFixedSize)
        }
    }
    
    @ViewBuilder
    private var subtitleSection: some View {
        let sub = viewModel.subtitle()
        let price = viewModel.pricePerPeriod()
        
        if !sub.isEmpty || viewModel.isAnyPaywallStep {
            VStack(spacing: 0) {
                if !sub.isEmpty {
                    Text(attributedSubtitle(sub: sub, price: price))
                        .font(style.subtitleFont)
                        .foregroundStyle(style.subtitleColor)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(style.minimumScaleFactor)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .fixedSize(horizontal: false, vertical: style.subtitleFixedSize)
                }
                
                if viewModel.isAnyPaywallStep && !viewModel.isPickerActive {
                    Button { viewModel.skipTapped() } label: {
                        Text(viewModel.limitedButtonTitle())
                            .font(style.limitedButtonFont ?? style.subtitleFont)
                            .foregroundStyle(style.limitedButtonColor ?? style.subtitleColor)
                            .underline(style.limitedButtonUnderline)
                            .minimumScaleFactor(style.minimumScaleFactor)
                    }
                }
            }
        }
    }
    
    private func attributedSubtitle(sub: String, price: String) -> AttributedString {
        var result = AttributedString(sub)

        if let splitIndex = style.splitSubtitleBy {
            let words = sub.split(separator: " ", omittingEmptySubsequences: false)
            if splitIndex > 0 && splitIndex < words.count {
                let beforeString = words[0..<splitIndex].joined(separator: " ") + " "
                let offset = beforeString.count
                if offset > 0 && offset < result.characters.count {
                    let splitPoint = result.index(result.startIndex, offsetByCharacters: offset)
                    let beforeRange = result.startIndex..<splitPoint
                    if let f = style.subtitleBeforeFont { result[beforeRange].font = f }
                    if let c = style.subtitleBeforeColor { result[beforeRange].foregroundColor = c }

                    let afterRange = splitPoint..<result.endIndex
                    if let f = style.subtitleAfterFont { result[afterRange].font = f }
                    if let c = style.subtitleAfterColor { result[afterRange].foregroundColor = c }
                }
            }
        }

        if !price.isEmpty, let range = result.range(of: price) {
            if style.priceCustomization?.contains(.heavy) == true {
                result[range].font = style.subtitleFont.weight(.heavy)
            }
            if style.priceCustomization?.contains(.underline) == true {
                result[range].underlineStyle = .single
            }
            if let f = style.priceCustomizationFont { result[range].font = f }
            if let c = style.priceCustomizationColor { result[range].foregroundColor = c }
        }

        return result
    }
    
    @ViewBuilder
    private var messageSection: some View {
        if viewModel.isPickerActive, let pickerStyle = style.pickerStyle {
            PickerPaywallView(
                products: viewModel.products,
                isTrialEnabled: $viewModel.isTrialEnabled,
                limitedButtonText: viewModel.paywall.buttons.limited,
                style: pickerStyle,
                isSecondaryStep: viewModel.isSecondaryStep,
                secondaryPaywallPickerSubtitle: secondaryPaywallPickerSubtitle,
                onTrialToggle: { wantsTrial in
                    if wantsTrial {
                        viewModel.tryEnableTrial()
                    } else {
                        viewModel.isTrialEnabled = false
                    }
                },
                onLimitedTapped: { viewModel.skipTapped() }
            )
        } else {
            HStack {
                Text(viewModel.message())
                    .font(style.messageFont)
                    .foregroundStyle(style.messageColor)
                    .minimumScaleFactor(style.minimumScaleFactor)
            }
            .frame(height: style.messageHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .trailing) {
                if style.showNewToggle {
                    trialCheckmark
                        .opacity(viewModel.isAnyPaywallStep ? 1 : 0)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if viewModel.isTrialEnabled {
                                viewModel.isTrialEnabled = false
                            } else {
                                viewModel.tryEnableTrial()
                            }
                        }
                } else {
                    Toggle("", isOn: Binding(
                        get: { viewModel.isTrialEnabled },
                        set: { newValue in
                            if newValue {
                                viewModel.tryEnableTrial()
                            } else {
                                viewModel.isTrialEnabled = false
                            }
                        }
                    ))
                        .tint(style.toggleColor)
                        .opacity(viewModel.isAnyPaywallStep ? 1 : 0)
                }
            }
            .padding(.horizontal, 16)
            .background(style.messageBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: style.messageCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: style.messageCornerRadius)
                    .stroke(style.messageBorderColor, lineWidth: style.messageBorderWidth)
                    .opacity(style.messageShowBorder ? 1 : 0)
            )
        }
    }
    
    @ViewBuilder
    private var trialCheckmark: some View {
        ZStack {
            Circle()
                .fill(viewModel.isTrialEnabled ? style.checkmarkActiveBGColor : style.checkmarkInactiveBGColor)
                .frame(width: style.checkmarkSize, height: style.checkmarkSize)
            
            Circle()
                .stroke(viewModel.isTrialEnabled ? style.checkmarkActiveBorderColor : style.checkmarkInactiveBorderColor, lineWidth: 1.5)
                .frame(width: style.checkmarkSize, height: style.checkmarkSize)
            
            if viewModel.isTrialEnabled {
                Image(systemName: "checkmark")
                    .font(.system(size: style.checkmarkIconSize, weight: style.checkmarkIconWeight))
                    .foregroundStyle(style.checkmarkActiveColor)
            }
        }
    }
    
    @ViewBuilder
    private var nextButton: some View {
        AnimatedScaleButton(
            isActive: style.showPaywallButtonAnimation && (style.showButtonAnimationAlways || viewModel.isAnyPaywallStep),
            duration: style.buttonAnimationDuration,
            scale: style.buttonAnimationScale,
            action: { viewModel.nextTapped() }
        ) {
            Text(viewModel.buttonTitle())
                .font(style.buttonFont)
                .foregroundStyle(style.buttonTextColor)
                .minimumScaleFactor(style.minimumScaleFactor)
                .frame(maxWidth: .infinity)
                .frame(height: style.buttonHeight)
                .background(style.buttonBackgroundColor)
                .cornerRadius(style.buttonCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: style.buttonCornerRadius)
                        .stroke(style.buttonBorderColor, lineWidth: style.buttonBorderWidth)
                        .opacity(style.buttonShowBorder ? 1 : 0)
                )
        }
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
        .minimumScaleFactor(style.minimumScaleFactor)
        .frame(height: 20)
        .frame(maxWidth: .infinity, alignment: .center)
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

extension OnboardingBuilder where TermsView == EmptyView, PrivacyView == EmptyView {
    public init(
        screens: [OnboardingScreen],
        paywallImages: AdaptiveResources,
        style: OnboardingStyle = .default,
        paywallHideContent: [OnboardingContentElement] = [],
        linksConfig: LinksConfiguration = .default,
        isTrialEnabled: Bool = false,
        showReviewRequestOnComplete: Bool = true,
        requestReviewSetup: RequestReviewSetup? = nil,
        showCancelledAlert: Bool = true,
        termsURL: String? = nil,
        privacyURL: String? = nil,
        paywallBackgroundView: AnyView? = nil,
        paywallMiddleView: AnyView? = nil,
        paywallOverlayView: AnyView? = nil,
        secondaryPaywallView: AnyView? = nil,
        secondaryPaywallID: PremiumPaywallID? = nil,
        secondaryPaywallImages: AdaptiveResources? = nil,
        secondaryPaywallBackgroundView: AnyView? = nil,
        secondaryPaywallMiddleView: AnyView? = nil,
        secondaryPaywallOverlayView: AnyView? = nil,
        secondaryPaywallCountsAsStep: Bool = false,
        secondaryPaywallPickerSubtitle: SecondaryPaywallPickerSubtitle? = nil,
        hiddenProductIDs: Set<String> = [],
        secondaryHiddenProductIDs: Set<String> = [],
        controller: OnboardingController? = nil,
        onScreenShown: ((Int, Int) -> Void)? = nil,
        onNextTapped: ((Int, Int) -> Void)? = nil,
        onLimitedTapped: (() -> Void)? = nil,
        onSecondaryLimitedTapped: (() -> Void)? = nil,
        onPaywallShown: (() -> Void)? = nil,
        onSecondaryPaywallShown: (() -> Void)? = nil,
        onComplete: @escaping () -> Void
    ) {
        self.style = style
        self.controller = controller
        self.termsView = nil
        self.privacyView = nil
        self.termsURL = termsURL
        self.privacyURL = privacyURL
        self.legalPresentation = .sheet
        self.linksConfig = linksConfig
        self.showCancelledAlert = showCancelledAlert
        self.paywallBackgroundContent = paywallBackgroundView
        self.paywallMiddleContent = paywallMiddleView
        self.paywallOverlayContent = paywallOverlayView
        self.secondaryPaywallContent = secondaryPaywallView
        self.secondaryPaywallBackgroundContent = secondaryPaywallBackgroundView
        self.secondaryPaywallMiddleContent = secondaryPaywallMiddleView
        self.secondaryPaywallOverlayContent = secondaryPaywallOverlayView
        self.secondaryPaywallPickerSubtitle = secondaryPaywallPickerSubtitle
        _viewModel = StateObject(wrappedValue: OnboardingBuilderViewModel(
            screens: screens,
            paywallImages: paywallImages,
            style: style,
            paywallHideContent: paywallHideContent,
            isTrialEnabled: isTrialEnabled,
            showReviewRequestOnComplete: showReviewRequestOnComplete,
            requestReviewSetup: requestReviewSetup,
            hasSecondaryPaywall: secondaryPaywallView != nil,
            secondaryPaywallID: secondaryPaywallID,
            secondaryPaywallImages: secondaryPaywallImages,
            secondaryPaywallCountsAsStep: secondaryPaywallCountsAsStep,
            hiddenProductIDs: hiddenProductIDs,
            secondaryHiddenProductIDs: secondaryHiddenProductIDs,
            onScreenShown: onScreenShown,
            onNextTapped: onNextTapped,
            onLimitedTapped: onLimitedTapped,
            onSecondaryLimitedTapped: onSecondaryLimitedTapped,
            onPaywallShown: onPaywallShown,
            onSecondaryPaywallShown: onSecondaryPaywallShown,
            onComplete: onComplete
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
