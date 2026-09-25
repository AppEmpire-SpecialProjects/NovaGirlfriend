import SwiftUI
import Combine

@MainActor
public final class Premium: ObservableObject {
    public static let shared = Premium()

    private init() {
        let noiseb19707594884b0db = PremiumKitNoised462352987a04d8b(seed: 8293991271274984672)
        _ = noiseb19707594884b0db.digest()
        bind()
    }

    // MARK: - Published public state (read-only)

    @Published public private(set) var paywalls: [PremiumPaywallID: PremiumPaywall] = [:]

    @Published public private(set) var isPremium: Bool = false

    @Published public private(set) var activeProductIds: Set<String> = []

    @Published public private(set) var availableProducts: PremiumAvailableProducts = .withTrial

    @Published public private(set) var isShowingSplash: Bool = true
    
    public var isTrialExpired: Bool {
        manager.isTrialExpired
    }
    
    @Published public var isShowingPaywall: Bool = false
    
    @Published public var isShowingConsumablePaywall: Bool = false
    
    @Published public var isShowingBannerPaywall: Bool = false
    
    public var tokens: Int {
        TokenStorage.shared.tokens
    }
    
    public func hasActiveProduct(_ productId: String) -> Bool {
        activeProductIds.contains(productId)
    }

    public func hasActiveProduct(fromPaywall paywallID: PremiumPaywallID) -> Bool {
        guard let products = paywalls[paywallID]?.products else { return false }
        return products.contains { activeProductIds.contains($0.id) }
    }

    // MARK: - Convenience accessors (backward compat)
    
    public var availablePaywall: PremiumPaywall {
        paywalls[currentAvailablePaywallID] ?? PaywallModel.mockMain.toPublic()
    }
    
    public var consumablePaywall: PremiumPaywall {
        paywalls[.consumable] ?? PaywallModel(id: .consumable).toPublic()
    }
    
    public var bannerPaywall: PremiumPaywall {
        paywalls[.banner] ?? PaywallModel(id: .banner).toPublic()
    }
    
    public func paywall(for id: PremiumPaywallID) -> PremiumPaywall? {
        paywalls[id]
    }
    
    // MARK: - Dependencies (internal)

    private let manager = PaymentManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var configuration: PremiumConfiguration?
    private var internalPaywalls: [PremiumPaywallID: PaywallModel] = [:]
    private var currentAvailablePaywallID: PremiumPaywallID = .main

    // MARK: - Configuration
    public func configure(_ configuration: PremiumConfiguration) {
        self.configuration = configuration
        L10n.supportedLanguages = configuration.supportedLanguages
        L10n.defaultLanguage = configuration.defaultLanguage
        if configuration.shouldLogout {
            manager.logout()
        }
    }

    // MARK: - AppDelegate funcs
    internal func startIfNeeded() {
        guard let config = configuration else {
            return
        }

        manager.start(
            apiKey: config.apiKey,
            userID: config.userID,
            forceFallback: config.forceFallback,
            fallbackFileName: config.fallbackFileName
        )
    }

    internal func submitPushToken(_ token: Data) {
        manager.submitPushToken(token)
    }

    // MARK: - Paywall
    public func loadPaywall(_ id: PremiumPaywallID) async {
        if id.isAvailablePaywall {
            currentAvailablePaywallID = id
        }
        await manager.fetchPaywall(id)
    }

    public func paywallShown(_ id: PremiumPaywallID? = nil) {
        let resolvedID = id ?? currentAvailablePaywallID
        manager.paywallShownEvent(resolvedID)
    }

    // MARK: - Purchase
    
    public func grantPremium() {
        manager.grantPremium()
    }

    public func grantPremium(for paywallID: PremiumPaywallID) {
        manager.grantPremium(for: paywallID)
    }
    
    public func logout() {
        manager.logout()
    }
    
    public func purchase(_ product: PremiumProduct, from paywallID: PremiumPaywallID? = nil) async -> Result<Void, PremiumError> {
        let resolvedID = paywallID ?? currentAvailablePaywallID
        guard let internalProduct = internalPaywalls[resolvedID]?.products
            .first(where: { $0.id == product.id }) else {
            return .failure(.productNotAvailable)
        }

        let result = await manager.purchase(internalProduct, from: resolvedID)

        switch result {
        case .success:
            objectWillChange.send()
            return .success(())

        case .failure(let error):
            return .failure(error.toPublic())
        }
    }

    // MARK: - Restore
    public func restore() async -> Result<Void, PremiumError> {
        let result = await manager.restorePurchase()

        switch result {
        case .success:
            return .success(())

        case .failure(let error):
            return .failure(error.toPublic())
        }
    }
    
    // MARK: - Tokens
    
    @discardableResult
    public func spendTokens(_ amount: Int = 1) -> Bool {
        let success = TokenStorage.shared.spend(amount)
        if success {
            objectWillChange.send()
        }
        return success
    }

    public func addTokens(_ amount: Int = 1) {
        guard amount > 0 else { return }
        TokenStorage.shared.addPurchased(amount)
        objectWillChange.send()
    }

    private func bind() {
        manager.$loadedPaywalls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loaded in
                guard let self else { return }
                
                self.internalPaywalls = loaded
                self.paywalls = loaded.reduce(into: [:]) { result, pair in
                    result[pair.key] = pair.value.toPublic()
                }
            }
            .store(in: &cancellables)

        manager.$availableProducts
            .map { $0.toPublic() }
            .receive(on: DispatchQueue.main)
            .assign(to: &$availableProducts)

        manager.$isPremium
            .assign(to: &$isPremium)

        manager.$activeProductIds
            .assign(to: &$activeProductIds)

        manager.$isShowingSplash
            .removeDuplicates()
            .sink { [weak self] showing in
                self?.isShowingSplash = showing
                if !showing {
                    ReviewRequestScheduler.notifySplashHidden()
                }
            }
            .store(in: &cancellables)
    }
}
