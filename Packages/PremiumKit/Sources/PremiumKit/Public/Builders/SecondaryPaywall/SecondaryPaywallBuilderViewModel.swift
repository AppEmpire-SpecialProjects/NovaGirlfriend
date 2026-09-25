import SwiftUI
import Combine

@MainActor
public final class SecondaryPaywallBuilderViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var isShowAlert: Bool = false
    @Published var isShowCancelledAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var isTrialEnabled: Bool = false
    @Published var showTrialExpiredAlert: Bool = false

    let paywallID: PremiumPaywallID
    let images: AdaptiveResources
    let style: SecondaryPaywallStyle
    let hiddenProductIDs: Set<String>
    let onDismiss: () -> Void
    let onSuccess: () -> Void
    let onPaywallShown: (() -> Void)?
    let onDismissTapped: (() -> Void)?

    private let premiumService = Premium.shared
    private var cancellables = Set<AnyCancellable>()

    var products: [PremiumProduct] {
        (premiumService.paywall(for: paywallID)?.products ?? [])
            .filter { !hiddenProductIDs.contains($0.id) }
    }

    var displayMode: SecondaryPaywallAvailableProducts {
        SecondaryPaywallAvailableProducts(products: products)
    }

    var isPickerActive: Bool {
        style.messageToggle.toggleType == .picker && displayMode == .double
    }

    var paywall: PremiumPaywall {
        premiumService.paywall(for: paywallID) ?? PremiumPaywall(
            id: paywallID,
            title: "",
            configuration: .variant1,
            buttons: .init(tryFree: "", continue: "", purchase: "", limited: ""),
            products: []
        )
    }

    var selectedProduct: PremiumProduct? {
        switch displayMode {
        case .single:
            return products.first
        case .double:
            guard let pair = products.togglePair else { return products.first }
            return isTrialEnabled ? pair.on : pair.off
        case .many:
            guard selectedIndex < products.count else { return nil }
            return products[selectedIndex]
        }
    }

    public init(
        paywallID: PremiumPaywallID,
        images: AdaptiveResources,
        style: SecondaryPaywallStyle = .default,
        hiddenProductIDs: Set<String> = [],
        onPaywallShown: (() -> Void)? = nil,
        onDismissTapped: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void,
        onSuccess: @escaping () -> Void
    ) {
let noiseb19707594884b0db = PremiumKitNoised462352987a04d8b(seed: 8293991271274984672)
        _ = noiseb19707594884b0db.digest()
        self.paywallID = paywallID
        self.images = images
        self.style = style
        self.hiddenProductIDs = hiddenProductIDs
        self.onPaywallShown = onPaywallShown
        self.onDismissTapped = onDismissTapped
        self.onDismiss = onDismiss
        self.onSuccess = onSuccess

        bind()
    }

    private func bind() {
        premiumService.$paywalls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] paywalls in
                guard let self else { return }
                setupTrialState(products: paywalls[paywallID]?.products ?? [])
            }
            .store(in: &cancellables)
    }

    private func setupTrialState(products: [PremiumProduct]) {
        let hasTrial = products.contains { $0.hasTrial }
        let hasNonTrial = products.contains { !$0.hasTrial }
        if hasTrial && hasNonTrial {
            isTrialEnabled = false
        } else if products.count >= 2 {
            // Два триала или два безтриала: тоггл выключен по умолчанию,
            // выбран первый продукт (левый сегмент)
            isTrialEnabled = false
        } else {
            isTrialEnabled = hasTrial
        }
    }

    func paywallShown() {
        premiumService.paywallShown(paywallID)
        onPaywallShown?()
    }

    func dismissTapped() {
        onDismissTapped?()
        onDismiss()
    }

    func currentImage(isLandscape: Bool) -> Image {
        if UIDevice.isIpad {
            return isLandscape ? images.ipadL : images.iphone
        } else {
            return UIDevice.isSe ? images.iphoneS : images.iphone
        }
    }

    func title1() -> String {
        if paywall.title.contains("\n") {
            return String(paywall.title.split(separator: "\n").first ?? "")
        }
        let words = paywall.title.split(separator: " ")
        return words.first.map(String.init) ?? ""
    }

    func title2() -> String {
        if paywall.title.contains("\n") {
            return paywall.title.split(separator: "\n").dropFirst().joined(separator: "\n")
        }
        let words = paywall.title.split(separator: " ")
        return words.dropFirst().joined(separator: " ")
    }

    func subtitle() -> String {
        selectedProduct?.paywallSubtitle ?? ""
    }

    func pricePerPeriod() -> String {
        selectedProduct?.pricePerPeriod ?? ""
    }

    func message() -> String {
        selectedProduct?.message ?? ""
    }

    func buttonTitle() -> String {
        guard let product = selectedProduct else { return "" }
        return paywall.buttonTitle(for: product)
    }

    func selectProduct(at index: Int) {
        HapticService.selection()
        selectedIndex = index
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
        HapticService.light()
        dismissTapped()
    }

    func purchase() async {
        HapticService.selection()
        guard let product = selectedProduct else { return }
        isLoading = true
        defer { isLoading = false }
        let result = await premiumService.purchase(product, from: paywallID)
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
            onSuccess()
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
