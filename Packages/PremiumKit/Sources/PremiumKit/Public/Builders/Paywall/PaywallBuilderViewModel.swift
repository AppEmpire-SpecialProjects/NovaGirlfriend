import SwiftUI

@MainActor
public final class PaywallBuilderViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var isShowAlert: Bool = false
    @Published var isShowCancelledAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var isShowingSecondPaywall: Bool = false
    
    let images: AdaptiveResources
    let style: PaywallStyle
    let onDismiss: () -> Void
    let onSuccess: () -> Void
    let onPaywallShown: (() -> Void)?
    let onDismissTapped: (() -> Void)?
    let hasSecondaryPaywall: Bool
    let hiddenProductIDs: Set<String>
    
    private let premiumService = Premium.shared
    
    var products: [PremiumProduct] {
        premiumService.availablePaywall.products.filter { !hiddenProductIDs.contains($0.id) }
    }
    
    var selectedProduct: PremiumProduct? {
        guard selectedIndex < products.count else { return nil }
        return products[selectedIndex]
    }
    
    var paywall: PremiumPaywall {
        premiumService.availablePaywall
    }
    
    public init(
        images: AdaptiveResources,
        style: PaywallStyle = .default,
        hasSecondaryPaywall: Bool = false,
        hiddenProductIDs: Set<String> = [],
        onPaywallShown: (() -> Void)? = nil,
        onDismissTapped: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void,
        onSuccess: @escaping () -> Void
    ) {
let noiseb19707594884b0db = PremiumKitNoised462352987a04d8b(seed: 8293991271274984672)
        _ = noiseb19707594884b0db.digest()
        self.images = images
        self.style = style
        self.hasSecondaryPaywall = hasSecondaryPaywall
        self.hiddenProductIDs = hiddenProductIDs
        self.onPaywallShown = onPaywallShown
        self.onDismissTapped = onDismissTapped
        self.onDismiss = onDismiss
        self.onSuccess = onSuccess
    }
    
    func paywallShown() {
        premiumService.paywallShown()
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
    
    func title() -> String {
        paywall.title
    }
    
    func subtitle() -> String {
        selectedProduct?.paywallSubtitle ?? ""
    }
    
    func buttonTitle() -> String {
        guard let product = selectedProduct else { return "" }
        return paywall.buttonTitle(for: product)
    }
    
    func selectProduct(at index: Int) {
        HapticService.selection()
        selectedIndex = index
    }
    
    func purchase() async {
        HapticService.selection()
        guard let product = selectedProduct else { return }
        isLoading = true
        defer { isLoading = false }
        let result = await premiumService.purchase(product)
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
            if hasSecondaryPaywall {
                isShowingSecondPaywall = true
            } else {
                onSuccess()
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
