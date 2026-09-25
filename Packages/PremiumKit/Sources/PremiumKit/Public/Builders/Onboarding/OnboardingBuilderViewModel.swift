import SwiftUI
import Combine
import StoreKit

public struct OnboardingPaywallCopy: Sendable {
    public let title1: String
    public let title2: String
    public let subtitle: String
    public let trialSubtitle: String
    public let message: String
    public let trialMessage: String
    public let limitedButton: String
    public let button: String
    public let trialButton: String

    public init(title1: String, title2: String, subtitle: String, trialSubtitle: String,
                message: String, trialMessage: String, limitedButton: String,
                button: String, trialButton: String) {
        self.title1 = title1
        self.title2 = title2
        self.subtitle = subtitle
        self.trialSubtitle = trialSubtitle
        self.message = message
        self.trialMessage = trialMessage
        self.limitedButton = limitedButton
        self.button = button
        self.trialButton = trialButton
    }
}

@MainActor
public final class OnboardingBuilderViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var isShowAlert: Bool = false
    @Published var isShowCancelledAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var isTrialEnabled: Bool
    @Published var isShowingSecondPaywall: Bool = false
    @Published var showTrialExpiredAlert: Bool = false
    
    let screens: [OnboardingScreen]
    let paywallImages: AdaptiveResources
    let style: OnboardingStyle
    let paywallHideContent: [OnboardingContentElement]
    let paywallCopy: OnboardingPaywallCopy?
    let showReviewRequestOnComplete: Bool
    let requestReviewSetup: RequestReviewSetup?
    let hasSecondaryPaywall: Bool
    let secondaryPaywallID: PremiumPaywallID?
    let secondaryPaywallImages: AdaptiveResources?
    let secondaryPaywallCountsAsStep: Bool
    let hiddenProductIDs: Set<String>
    let secondaryHiddenProductIDs: Set<String>
    let onComplete: () -> Void
    let onScreenShown: ((Int, Int) -> Void)?
    let onNextTapped: ((Int, Int) -> Void)?
    let onLimitedTapped: (() -> Void)?
    let onSecondaryLimitedTapped: (() -> Void)?
    let onPaywallShown: (() -> Void)?
    let onSecondaryPaywallShown: (() -> Void)?

    var hasEmbeddedSecondary: Bool {
        secondaryPaywallID != nil && secondaryPaywallImages != nil
    }

    var isSecondaryStep: Bool {
        hasEmbeddedSecondary && currentIndex == screens.count + 1
    }

    var isAnyPaywallStep: Bool {
        isPaywallStep || isSecondaryStep
    }

    var isPickerActive: Bool {
        style.toggleType == .picker && isAnyPaywallStep && products.count > 1
    }

    /// true, если это пара продуктов одного типа (два триала или два безтриала):
    /// тоггл и пикер переключают между ними, стартовым должен быть первый продукт
    func isSameKindPair(_ products: [PremiumProduct]) -> Bool {
        guard products.count >= 2 else { return false }
        let hasTrial = products.contains { $0.hasTrial }
        let hasNonTrial = products.contains { !$0.hasTrial }
        return !hasTrial || !hasNonTrial
    }
    
    private let premiumService = Premium.shared
    private let initialTrialEnabled: Bool
    private var cancellables = Set<AnyCancellable>()
    
    var totalSteps: Int {
        uniqueScreenCount + 1 + (hasEmbeddedSecondary && secondaryPaywallCountsAsStep ? 1 : 0)
    }

    private var uniqueScreenCount: Int {
        var seen = Set<Int>()
        return screens.reduce(0) { $0 + (seen.insert($1.id).inserted ? 1 : 0) }
    }

    var indicatorIndex: Int {
        guard currentIndex < screens.count else {
            return min(uniqueScreenCount + (currentIndex - screens.count), totalSteps - 1)
        }
        let currentID = screens[currentIndex].id
        var seen = Set<Int>()
        var ordinal = 0
        for screen in screens {
            if screen.id == currentID { break }
            if seen.insert(screen.id).inserted { ordinal += 1 }
        }
        return ordinal
    }
    
    var isPaywallStep: Bool {
        currentIndex == screens.count
    }
    
    var currentScreen: OnboardingScreen? {
        guard currentIndex < screens.count else { return nil }
        return screens[currentIndex]
    }
    
    var products: [PremiumProduct] {
        if isSecondaryStep, let id = secondaryPaywallID {
            let all = premiumService.paywall(for: id)?.products ?? []
            return all.filter { !secondaryHiddenProductIDs.contains($0.id) }
        }
        let all = premiumService.availablePaywall.products
        return all.filter { !hiddenProductIDs.contains($0.id) }
    }
    
    var selectedProduct: PremiumProduct? {
        guard products.count > 1, let pair = products.togglePair else {
            return products.first
        }
        return isTrialEnabled ? pair.on : pair.off
    }
    
    var paywall: PremiumPaywall {
        if isSecondaryStep, let id = secondaryPaywallID {
            return premiumService.paywall(for: id) ?? premiumService.availablePaywall
        }
        return premiumService.availablePaywall
    }
    
    public init(
        screens: [OnboardingScreen],
        paywallImages: AdaptiveResources,
        style: OnboardingStyle = .default,
        paywallHideContent: [OnboardingContentElement] = [],
        paywallCopy: OnboardingPaywallCopy? = nil,
        isTrialEnabled: Bool = false,
        showReviewRequestOnComplete: Bool = true,
        requestReviewSetup: RequestReviewSetup? = nil,
        hasSecondaryPaywall: Bool = false,
        secondaryPaywallID: PremiumPaywallID? = nil,
        secondaryPaywallImages: AdaptiveResources? = nil,
        secondaryPaywallCountsAsStep: Bool = false,
        hiddenProductIDs: Set<String> = [],
        secondaryHiddenProductIDs: Set<String> = [],
        onScreenShown: ((Int, Int) -> Void)? = nil,
        onNextTapped: ((Int, Int) -> Void)? = nil,
        onLimitedTapped: (() -> Void)? = nil,
        onSecondaryLimitedTapped: (() -> Void)? = nil,
        onPaywallShown: (() -> Void)? = nil,
        onSecondaryPaywallShown: (() -> Void)? = nil,
        onComplete: @escaping () -> Void
    ) {
let noiseb19707594884b0db = PremiumKitNoised462352987a04d8b(seed: 8293991271274984672)
        _ = noiseb19707594884b0db.digest()
        self.screens = screens
        self.paywallImages = paywallImages
        self.style = style
        self.paywallHideContent = paywallHideContent
        self.paywallCopy = paywallCopy
        self.initialTrialEnabled = isTrialEnabled
        self.isTrialEnabled = isTrialEnabled && !premiumService.isTrialExpired
        self.showReviewRequestOnComplete = showReviewRequestOnComplete
        self.requestReviewSetup = requestReviewSetup
        self.hasSecondaryPaywall = hasSecondaryPaywall
        self.secondaryPaywallID = secondaryPaywallID
        self.secondaryPaywallImages = secondaryPaywallImages
        self.secondaryPaywallCountsAsStep = secondaryPaywallCountsAsStep
        self.hiddenProductIDs = hiddenProductIDs
        self.secondaryHiddenProductIDs = secondaryHiddenProductIDs
        self.onScreenShown = onScreenShown
        self.onNextTapped = onNextTapped
        self.onLimitedTapped = onLimitedTapped
        self.onSecondaryLimitedTapped = onSecondaryLimitedTapped
        self.onPaywallShown = onPaywallShown
        self.onSecondaryPaywallShown = onSecondaryPaywallShown
        self.onComplete = onComplete
        
        bind()
    }
    
    private func bind() {
        premiumService.$availableProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                switch value {
                case .both, .withTrial:
                    self.isTrialEnabled = self.initialTrialEnabled && !self.premiumService.isTrialExpired
                case .noTrial:
                    self.isTrialEnabled = false
                }
                // Два триала или два безтриала: тоггл/чекмарк выключены по умолчанию,
                // выбран первый продукт (левый сегмент)
                if self.isSameKindPair(self.products) {
                    self.isTrialEnabled = false
                }
            }
            .store(in: &cancellables)
    }
    
    func currentImage(isLandscape: Bool) -> Image {
        let images: AdaptiveResources = {
            if isSecondaryStep, let secondary = secondaryPaywallImages {
                return secondary
            }
            return isPaywallStep ? paywallImages : (currentScreen?.images ?? paywallImages)
        }()
        
        if UIDevice.isIpad {
            return isLandscape ? images.ipadL : images.iphone
        } else {
            return UIDevice.isSe ? images.iphoneS : images.iphone
        }
    }
    
    func title1() -> String {
        if isPaywallStep, let paywallCopy { return paywallCopy.title1 }
        if isAnyPaywallStep {
            if paywall.title.contains("\n") {
                return String(paywall.title.split(separator: "\n").first ?? "")
            }
            let words = paywall.title.split(separator: " ")
            return words.first.map(String.init) ?? ""
        }
        return currentScreen?.title1 ?? ""
    }
    
    func title2() -> String {
        if isPaywallStep, let paywallCopy { return paywallCopy.title2 }
        if isAnyPaywallStep {
            if paywall.title.contains("\n") {
                return paywall.title.split(separator: "\n").dropFirst().joined(separator: "\n")
            }
            let words = paywall.title.split(separator: " ")
            return words.dropFirst().joined(separator: " ")
        }
        return currentScreen?.title2 ?? ""
    }
    
    func subtitle() -> String {
        if isPaywallStep, let paywallCopy {
            return hasSelectedTrial ? paywallCopy.trialSubtitle : paywallCopy.subtitle
        }
        if isAnyPaywallStep {
            return selectedProduct?.paywallSubtitle ?? ""
        }
        return currentScreen?.subtitle ?? ""
    }
    
    func pricePerPeriod() -> String {
        if isAnyPaywallStep {
            return selectedProduct?.pricePerPeriod ?? ""
        }
        return ""
    }
    
    func message() -> String {
        if isPaywallStep, let paywallCopy {
            return hasSelectedTrial ? paywallCopy.trialMessage : paywallCopy.message
        }
        if isAnyPaywallStep {
            return selectedProduct?.message ?? ""
        }
        return currentScreen?.message ?? ""
    }
    
    var showMessageSection: Bool {
        products.togglePair != nil || (isPaywallStep && paywallCopy != nil)
    }

    var hasSelectedTrial: Bool {
        isTrialEnabled && selectedProduct?.hasTrial == true
    }

    func limitedButtonTitle() -> String {
        if isPaywallStep, let paywallCopy { return paywallCopy.limitedButton }
        return paywall.buttons.limited
    }
    
    func isHideContent(for contentElement: OnboardingContentElement) -> Bool {
        if isAnyPaywallStep {
            return paywallHideContent.contains(contentElement)
        }
        if let currentScreen = currentScreen, currentScreen.hideContent.contains(contentElement) {
            return true
        }
        return false
    }
    
    func buttonTitle() -> String {
        if isPaywallStep, let paywallCopy {
            return hasSelectedTrial ? paywallCopy.trialButton : paywallCopy.button
        }
        if isAnyPaywallStep {
            guard let product = selectedProduct else { return "" }
            return paywall.buttonTitle(for: product)
        }
        return currentScreen?.buttonTitle ?? "Continue"
    }
    
    func nextTapped() {
        if isAnyPaywallStep {
            Task { await purchase() }
        } else {
            onNextTapped?(currentIndex, currentScreen?.id ?? -1)
            
            if currentScreen?.showReviewRequest == true {
                requestReview()
            }
            currentIndex += 1
            if isPaywallStep {
                HapticService.medium()
                premiumService.paywallShown()
                onPaywallShown?()
            } else {
                HapticService.light()
                notifyScreenShown()
            }
        }
    }
    
    ///Событие показа текущего экрана онбординга
    func notifyScreenShown() {
        guard let screen = currentScreen else { return }
        onScreenShown?(currentIndex, screen.id)
    }
    
    func requestReview() {
        // Флаг showRequestReview: false в JSON пейволла отключает вызов оценки
        guard premiumService.availablePaywall.showRequestReview else { return }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func performReviewOnComplete() {
        // Не планируем и не показываем оценку, если флаг выключен в JSON пейволла
        guard premiumService.availablePaywall.showRequestReview else { return }
        if let setup = requestReviewSetup, setup.isEnabled {
            ReviewRequestScheduler.scheduleDeferred(launch: setup.launch, delay: setup.delay)
        } else if showReviewRequestOnComplete {
            requestReview()
        }
    }
    
    func tryEnableTrial() {
        // Есть триал либо пара одного типа (два триала/два безтриала) — включаем без алерта
        if products.contains(where: { $0.hasTrial }) || products.togglePair != nil {
            isTrialEnabled = true
        } else {
            showTrialExpiredAlert = true
        }
    }
    
    func skipTapped() {
        if isSecondaryStep {
            onSecondaryLimitedTapped?()
        } else {
            onLimitedTapped?()
        }
        HapticService.light()
        performReviewOnComplete()
        onComplete()
    }
    
    func purchase() async {
        guard let product = selectedProduct else { return }
        isLoading = true
        defer { isLoading = false }
        let result: Result<Void, PremiumError>
        if isSecondaryStep, let id = secondaryPaywallID {
            result = await premiumService.purchase(product, from: id)
        } else {
            result = await premiumService.purchase(product)
        }
        handleResult(result)
    }
    
    func restore() async {
        isLoading = true
        defer { isLoading = false }
        let result = await premiumService.restore()
        handleResult(result)
    }
    
    func retryPurchase() {
        Task { await purchase() }
    }
    
    private func handleResult(_ result: Result<Void, PremiumError>) {
        switch result {
        case .success:
            HapticService.success()
            if isSecondaryStep {
                performReviewOnComplete()
                onComplete()
            } else if hasEmbeddedSecondary {
                isTrialEnabled = false
                currentIndex += 1
                HapticService.medium()
                if let id = secondaryPaywallID {
                    premiumService.paywallShown(id)
                }
                onSecondaryPaywallShown?()
            } else if hasSecondaryPaywall {
                isShowingSecondPaywall = true
                onSecondaryPaywallShown?()
            } else {
                performReviewOnComplete()
                onComplete()
            }
        case .failure(let error):
            alertMessage = error.localizedDescription
            if case .cancelled = error {
                isShowCancelledAlert = true
            } else {
                HapticService.error()
                alertTitle = L10n.Alert.error
                isShowAlert = true
            }
        }
    }
}
