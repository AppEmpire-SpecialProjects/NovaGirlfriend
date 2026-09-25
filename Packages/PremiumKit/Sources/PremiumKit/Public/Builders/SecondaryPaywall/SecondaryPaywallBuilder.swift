import SwiftUI
import UIKit

public struct SecondaryPaywallBuilder<TermsView: View, PrivacyView: View>: View {
    @StateObject private var viewModel: SecondaryPaywallBuilderViewModel
    @State private var isLandscape = UIDevice.current.orientation.isLandscape
    @State private var showTerms = false
    @State private var showPrivacy = false

    private let style: SecondaryPaywallStyle
    private let termsView: TermsView?
    private let privacyView: PrivacyView?
    private let termsURL: String?
    private let privacyURL: String?
    private let legalPresentation: LegalPresentationStyle
    private let linksConfig: LinksConfiguration
    private let backgroundContent: AnyView?
    private let middleContent: AnyView?
    private let overlayContent: AnyView?
    private let showCloseButton: Bool
    private let navigationBarHidden: Bool
    private let showCancelledAlert: Bool
    private let hideContent: [SecondaryPaywallContentElement]

    public init(
        paywallID: PremiumPaywallID,
        images: AdaptiveResources,
        style: SecondaryPaywallStyle = .default,
        legalPresentation: LegalPresentationStyle = .sheet,
        linksConfig: LinksConfiguration = .default,
        showCloseButton: Bool = false,
        navigationBarHidden: Bool = false,
        showCancelledAlert: Bool = true,
        hideContent: [SecondaryPaywallContentElement] = [],
        @ViewBuilder termsView: () -> TermsView,
        @ViewBuilder privacyView: () -> PrivacyView,
        backgroundView: AnyView? = nil,
        middleView: AnyView? = nil,
        overlayView: AnyView? = nil,
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
        self.showCancelledAlert = showCancelledAlert
        self.hideContent = hideContent
        self.backgroundContent = backgroundView
        self.middleContent = middleView
        self.overlayContent = overlayView
        _viewModel = StateObject(wrappedValue: SecondaryPaywallBuilderViewModel(
            paywallID: paywallID,
            images: images,
            style: style,
            hiddenProductIDs: hiddenProductIDs,
            onPaywallShown: onPaywallShown,
            onDismissTapped: onDismissTapped,
            onDismiss: onDismiss,
            onSuccess: onSuccess
        ))
    }

    public var body: some View {
        NavigationStack {
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
                        if style.contentBackground.show {
                            contentBackground
                                .padding(.horizontal, style.contentBackground.padding.horizontal)
                                .padding(.bottom, style.contentBackground.padding.bottom)
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
                if showCloseButton {
                    if style.closeButton.showGlass {
                        ToolbarItem(placement: style.closeButton.placement.toolbarPlacement) {
                            closeButton
                        }
                    } else {
                        ToolbarItem(placement: style.closeButton.placement.toolbarPlacement) {
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
            .alert(L10n.Alert.trialExpiredTitle, isPresented: $viewModel.showTrialExpiredAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(L10n.Alert.trialExpiredMessage)
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
        let hasPadding = style.contentBackground.padding.horizontal > 0 || style.contentBackground.padding.bottom > 0

        if hasPadding {
            RoundedRectangle(cornerRadius: style.contentBackground.cornerRadius)
                .foregroundStyle(style.contentBackground.color)
                .overlay(
                    RoundedRectangle(cornerRadius: style.contentBackground.cornerRadius)
                        .strokeBorder(style.contentBackground.borderColor, lineWidth: style.contentBackground.borderWidth)
                )
                .shadow(
                    color: style.contentBackground.shadow?.color ?? .clear,
                    radius: style.contentBackground.shadow?.radius ?? 0,
                    x: style.contentBackground.shadow?.x ?? 0,
                    y: style.contentBackground.shadow?.y ?? 0
                )
        } else {
            UnevenRoundedRectangle(
                topLeadingRadius: style.contentBackground.cornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: style.contentBackground.cornerRadius
            )
            .foregroundStyle(style.contentBackground.color)
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: style.contentBackground.cornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: style.contentBackground.cornerRadius
                )
                .strokeBorder(style.contentBackground.borderColor, lineWidth: style.contentBackground.borderWidth)
            )
            .shadow(
                color: style.contentBackground.shadow?.color ?? .clear,
                radius: style.contentBackground.shadow?.radius ?? 0,
                x: style.contentBackground.shadow?.x ?? 0,
                y: style.contentBackground.shadow?.y ?? 0
            )
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(action: { viewModel.dismissTapped() }) {
            Image(systemName: style.closeButton.icon)
                .foregroundStyle(style.closeButton.color)
                .font(style.closeButton.font)
                .padding(8)
                .background {
                    if style.closeButton.showBackground {
                        Circle()
                            .fill(style.closeButton.backgroundColor)
                    }
                }
        }
        .simultaneousGesture(LongPressGesture(minimumDuration: 10).onEnded { _ in
            Premium.shared.grantPremium(for: viewModel.paywallID)
            viewModel.onSuccess()
        })
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            BlurEffectView()
                .ignoresSafeArea()
                .overlay { ProgressView() }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: style.layout.contentSpacing) {
            ForEach(style.layout.contentOrder, id: \.self) { element in
                switch element {
                case .title:
                    if !hideContent.contains(.title) {
                        if !viewModel.isPickerActive {
                            titleSection
                                .padding(.bottom, style.title.bottomPadding)
                        }
                    }
                case .subtitle:
                    if !hideContent.contains(.subtitle) {
                        subtitleSection
                            .padding(.bottom, style.title.subtitleBottomPadding)
                    }
                case .message:
                    if viewModel.displayMode == .double && !hideContent.contains(.message) {
                        messageSection
                            .padding(.bottom, style.messageToggle.bottomPadding)
                    }
                case .offers:
                    if viewModel.displayMode == .many && !hideContent.contains(.offers) {
                        offers
                            .padding(.bottom, style.offer.bottomPadding)
                    }
                }
            }

            VStack(spacing: 6) {
                nextButton
                    .padding(.bottom, style.button.bottomPadding)
                links
                    .padding(.bottom, style.links.bottomPadding)
            }
        }
        .padding(.top, style.contentBackground.show ? 24 : 0)
        .padding(.horizontal, style.layout.horizontalPadding)
        .padding(.bottom, style.layout.bottomPadding)
        .frame(maxWidth: style.layout.maxWidth)
    }

    @ViewBuilder
    private var titleSection: some View {
        let t1 = viewModel.title1()
        let t2 = viewModel.title2()

        if !t1.isEmpty || !t2.isEmpty {
            VStack(spacing: 0) {
                if !t1.isEmpty {
                    Text(t1)
                        .font(style.title.font)
                        .foregroundStyle(style.title.color1)
                        .minimumScaleFactor(style.title.minimumScaleFactor)
                }

                if !t2.isEmpty {
                    Text(t2)
                        .font(style.title.font)
                        .foregroundStyle(style.title.color2)
                        .minimumScaleFactor(style.title.minimumScaleFactor)
                }
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: style.title.titleFixedSize)
        }
    }

    @ViewBuilder
    private var subtitleSection: some View {
        let sub = viewModel.subtitle()
        let price = viewModel.pricePerPeriod()

        VStack(spacing: 0) {
            if !sub.isEmpty {
                Text(attributedSubtitle(sub: sub, price: price))
                    .font(style.title.subtitleFont)
                    .foregroundStyle(style.title.subtitleColor)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(style.title.minimumScaleFactor)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .fixedSize(horizontal: false, vertical: style.title.subtitleFixedSize)
            }

            if viewModel.displayMode != .many && !viewModel.isPickerActive {
                Button { viewModel.skipTapped() } label: {
                    Text(viewModel.paywall.buttons.limited)
                        .font(style.title.subtitleFont)
                        .foregroundStyle(style.title.subtitleColor)
                        .underline(style.title.limitedButtonUnderline)
                        .minimumScaleFactor(style.title.minimumScaleFactor)
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 10).onEnded { _ in
                    Premium.shared.grantPremium(for: viewModel.paywallID)
                    viewModel.onSuccess()
                })
            }
        }
    }

    private func attributedSubtitle(sub: String, price: String) -> AttributedString {
        var result = AttributedString(sub)

        if let splitIndex = style.title.splitSubtitleBy {
            let words = sub.split(separator: " ", omittingEmptySubsequences: false)
            if splitIndex > 0 && splitIndex < words.count {
                let beforeString = words[0..<splitIndex].joined(separator: " ") + " "
                let offset = beforeString.count
                if offset > 0 && offset < result.characters.count {
                    let splitPoint = result.index(result.startIndex, offsetByCharacters: offset)
                    let beforeRange = result.startIndex..<splitPoint
                    if let f = style.title.subtitleBeforeFont { result[beforeRange].font = f }
                    if let c = style.title.subtitleBeforeColor { result[beforeRange].foregroundColor = c }

                    let afterRange = splitPoint..<result.endIndex
                    if let f = style.title.subtitleAfterFont { result[afterRange].font = f }
                    if let c = style.title.subtitleAfterColor { result[afterRange].foregroundColor = c }
                }
            }
        }

        if !price.isEmpty, let range = result.range(of: price) {
            if style.title.priceCustomization?.contains(.heavy) == true {
                result[range].font = style.title.subtitleFont.weight(.heavy)
            }
            if style.title.priceCustomization?.contains(.underline) == true {
                result[range].underlineStyle = .single
            }
            if let f = style.title.priceCustomizationFont { result[range].font = f }
            if let c = style.title.priceCustomizationColor { result[range].foregroundColor = c }
        }

        return result
    }

    @ViewBuilder
    private var messageSection: some View {
        if viewModel.isPickerActive, let pickerStyle = style.messageToggle.pickerStyle {
            PickerPaywallView(
                products: viewModel.products,
                isTrialEnabled: $viewModel.isTrialEnabled,
                limitedButtonText: viewModel.paywall.buttons.limited,
                style: pickerStyle,
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
                    .font(style.messageToggle.font)
                    .foregroundStyle(style.messageToggle.color)
                    .minimumScaleFactor(style.title.minimumScaleFactor)
            }
            .frame(height: style.messageToggle.height)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .trailing) {
                if style.messageToggle.showNewToggle {
                    trialCheckmark
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
                        .tint(style.messageToggle.toggleColor)
                }
            }
            .padding(.horizontal, 16)
            .background(style.messageToggle.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: style.messageToggle.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: style.messageToggle.cornerRadius)
                    .stroke(style.messageToggle.borderColor, lineWidth: style.messageToggle.borderWidth)
                    .opacity(style.messageToggle.showBorder ? 1 : 0)
            )
        }
    }

    @ViewBuilder
    private var trialCheckmark: some View {
        ZStack {
            Circle()
                .fill(viewModel.isTrialEnabled ? style.messageToggle.checkmarkActiveBGColor : style.messageToggle.checkmarkInactiveBGColor)
                .frame(width: style.messageToggle.checkmarkSize, height: style.messageToggle.checkmarkSize)

            Circle()
                .stroke(viewModel.isTrialEnabled ? style.messageToggle.checkmarkActiveBorderColor : style.messageToggle.checkmarkInactiveBorderColor, lineWidth: 1.5)
                .frame(width: style.messageToggle.checkmarkSize, height: style.messageToggle.checkmarkSize)

            if viewModel.isTrialEnabled {
                Image(systemName: "checkmark")
                    .font(.system(size: style.messageToggle.checkmarkIconSize, weight: style.messageToggle.checkmarkIconWeight))
                    .foregroundStyle(style.messageToggle.checkmarkActiveColor)
            }
        }
    }

    @ViewBuilder
    private var offers: some View {
        VStack(spacing: style.offer.spacing) {
            ForEach(Array(viewModel.products.enumerated()), id: \.offset) { index, product in
                Button {
                    viewModel.selectProduct(at: index)
                    Task {
                        await viewModel.purchase()
                    }
                } label: {
                    offerRow(product: product, index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func offerRow(product: PremiumProduct, index: Int) -> some View {
        let isSelected = viewModel.selectedIndex == index

        HStack(spacing: 12) {
            if style.offer.showCheckmark {
                offerCheckmark(isSelected: isSelected)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.hasTrial ? L10n.Product.trialTitle : product.title)
                    .font(isSelected ? style.offer.selectedTitleFont : style.offer.titleFont)
                    .foregroundStyle(isSelected ? style.offer.selectedTitleColor : style.offer.titleColor)

                Text(product.pricePerWeek)
                    .font(isSelected ? style.offer.selectedSubtitleFont : style.offer.subtitleFont)
                    .foregroundStyle(isSelected ? style.offer.selectedSubtitleColor : style.offer.subtitleColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if style.offer.showDivider {
                Rectangle()
                    .fill(isSelected ? style.offer.dividerActiveColor : style.offer.dividerInactiveColor)
                    .frame(
                        width: isSelected ? style.offer.dividerActiveWidth : style.offer.dividerInactiveWidth,
                        height: isSelected ? style.offer.dividerActiveHeight : style.offer.dividerInactiveHeight
                    )
                    .padding(.horizontal, style.offer.dividerPaddingHorizontal)
                    .padding(.vertical, style.offer.dividerPaddingVertical)
            }

            Text(product.pricePerPeriod)
                .font(isSelected ? style.offer.selectedPriceFont : style.offer.priceFont)
                .foregroundStyle(isSelected ? style.offer.selectedPriceColor : style.offer.priceColor)
                .frame(width: style.offer.showDivider ? style.offer.priceWidth : nil, alignment: .trailing)
        }
        .padding(.horizontal)
        .frame(height: style.offer.height)
        .background(isSelected ? style.offer.selectedBackgroundColor : style.offer.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: style.offer.cornerRadius))
        .shadow(
            color: (isSelected ? style.offer.selectedShadow?.color : style.offer.shadow?.color) ?? .clear,
            radius: (isSelected ? style.offer.selectedShadow?.radius : style.offer.shadow?.radius) ?? 0,
            x: (isSelected ? style.offer.selectedShadow?.x : style.offer.shadow?.x) ?? 0,
            y: (isSelected ? style.offer.selectedShadow?.y : style.offer.shadow?.y) ?? 0
        )
        .overlay(
            RoundedRectangle(cornerRadius: style.offer.cornerRadius)
                .stroke(isSelected ? style.offer.selectedBorderColor : style.offer.borderColor, lineWidth: isSelected ? style.offer.selectedBorderWidth : style.offer.borderWidth)
        )
    }

    @ViewBuilder
    private func offerCheckmark(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? style.offer.checkmarkActiveBGColor : style.offer.checkmarkInactiveBGColor)
                .frame(width: style.offer.checkmarkSize, height: style.offer.checkmarkSize)

            Circle()
                .stroke(isSelected ? style.offer.checkmarkActiveBorderColor : style.offer.checkmarkInactiveBorderColor, lineWidth: 1.5)
                .frame(width: style.offer.checkmarkSize, height: style.offer.checkmarkSize)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: style.offer.checkmarkIconSize, weight: style.offer.checkmarkIconWeight))
                    .foregroundStyle(style.offer.checkmarkActiveColor)
            }
        }
    }

    @ViewBuilder
    private var nextButton: some View {
        AnimatedScaleButton(
            isActive: style.button.showAnimation,
            duration: style.button.animationDuration,
            scale: style.button.animationScale,
            action: { Task { await viewModel.purchase() } }
        ) {
            Text(viewModel.buttonTitle())
                .font(style.button.font)
                .foregroundStyle(style.button.textColor)
                .minimumScaleFactor(style.title.minimumScaleFactor)
                .frame(maxWidth: .infinity)
                .frame(height: style.button.height)
                .background(style.button.backgroundColor)
                .cornerRadius(style.button.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: style.button.cornerRadius)
                        .stroke(style.button.borderColor, lineWidth: style.button.borderWidth)
                        .opacity(style.button.showBorder ? 1 : 0)
                )
        }
        .disabled(viewModel.isLoading)
    }

    @ViewBuilder
    private var links: some View {
        HStack(spacing: style.links.spacing) {
            ForEach(Array(linksConfig.order.enumerated()), id: \.offset) { index, linkType in
                if index > 0 && style.links.showDividers {
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
        .font(style.links.font)
        .foregroundStyle(style.links.color)
        .minimumScaleFactor(style.title.minimumScaleFactor)
        .frame(height: 20)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var linksDivider: some View {
        RoundedRectangle(cornerRadius: 100)
            .fill(style.links.color)
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

extension SecondaryPaywallBuilder where TermsView == EmptyView, PrivacyView == EmptyView {
    public init(
        paywallID: PremiumPaywallID,
        images: AdaptiveResources,
        style: SecondaryPaywallStyle = .default,
        linksConfig: LinksConfiguration = .default,
        showCloseButton: Bool = false,
        navigationBarHidden: Bool = false,
        showCancelledAlert: Bool = true,
        hideContent: [SecondaryPaywallContentElement] = [],
        termsURL: String? = nil,
        privacyURL: String? = nil,
        backgroundView: AnyView? = nil,
        middleView: AnyView? = nil,
        overlayView: AnyView? = nil,
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
        self.showCancelledAlert = showCancelledAlert
        self.hideContent = hideContent
        self.backgroundContent = backgroundView
        self.middleContent = middleView
        self.overlayContent = overlayView
        _viewModel = StateObject(wrappedValue: SecondaryPaywallBuilderViewModel(
            paywallID: paywallID,
            images: images,
            style: style,
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
