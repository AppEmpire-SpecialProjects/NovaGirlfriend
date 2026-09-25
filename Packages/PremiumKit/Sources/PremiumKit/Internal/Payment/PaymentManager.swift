@preconcurrency import ApphudSDK
import StoreKit
import AdServices
import Combine

fileprivate enum Constants {
    static let trialUserDefaultsKey = "TRIAL"
}

@MainActor
internal final class PaymentManager: ObservableObject {
    
    static let shared = PaymentManager()
    
    @Published private(set) var loadedPaywalls: [PremiumPaywallID: PaywallModel] = [:]
    @Published private(set) var isPremium = false
    @Published private(set) var activeProductIds: Set<String> = []
    @Published private(set) var availableProducts: AvailableProducts = .withTrial
    @Published private(set) var isShowingSplash = true
    private var isPremiumChecked = false
    
    var isTrialExpired: Bool {
        isPremiumChecked && UserDefaults.standard.object(forKey: Constants.trialUserDefaultsKey) != nil && !isPremium
    }
    
    private let networkMonitor: NetworMonitoring = NetworMonitoringImpl()
    private let fallbackHelper = FallbackHelper()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var loadStates: [PremiumPaywallID: ProductLoadState] = [:]
    private let loadTasks = LatestLoadTasks<PremiumPaywallID>()
    
    private var forceFallback = false
    private var fallbackFileName = "apphud_paywalls_fallback"
    
    private var paywallsApphud: [PremiumPaywallID: ApphudPaywall] = [:]
    
    private init() {
        let noiseb19707594884b0db = PremiumKitNoised462352987a04d8b(seed: 8293991271274984672)
        _ = noiseb19707594884b0db.digest()
        bind()
    }
    
    //MARK: - public methods
    
    func grantPremium() {
        isPremium = true
    }

    func grantPremium(for id: PremiumPaywallID) {
        let ids = loadedPaywalls[id]?.products.map { $0.id } ?? []
        activeProductIds.formUnion(ids)
    }
    
    ///Вызывается при старте приложения didFinishLaunchingWithOptions
    func start(
        apiKey: String,
        userID: String? = nil,
        forceFallback: Bool = false,
        fallbackFileName: String = "apphud_paywalls_fallback"
    ) {
        self.forceFallback = forceFallback
        self.fallbackFileName = fallbackFileName
        Apphud.start(apiKey: apiKey, userID: userID) { [weak self] _ in
            _Concurrency.Task {
                self?.checkPremiumSubscription()
                self?.trackASA()
                Apphud.setPaywallsCacheTimeout(60 * 60)
            }
        }
    }
    
    ///Загружает токек пушей в апхуд
    func submitPushToken(_ token: Data) {
        Apphud.submitPushNotificationsToken(token: token, callback: nil)
    }
    
    func logout() {
        Task { await Apphud.logout() }
        isPremium = false
        activeProductIds = []
    }
    
    private func setPaywall(_ model: PaywallModel, for id: PremiumPaywallID) {
        loadedPaywalls[id] = model
    }
    
    private func paywall(for id: PremiumPaywallID) -> PaywallModel? {
        loadedPaywalls[id]
    }
    
    ///Вызывается для загрузки пейвола только при старте флоу
    func fetchPaywall(_ id: PremiumPaywallID) async {
        await loadTasks.run(for: id) {
            if self.loadedPaywalls[id] == nil {
                self.setPaywall(.init(id: id), for: id)
            }
            self.loadStates[id] = .loading
            do {
                if self.forceFallback {
                    let model = await self.fallbackHelper.fallbackToPaywallModel(
                        for: id, fileName: self.fallbackFileName
                    )
                    try Task.checkCancellation()
                    return PaywallLoad(model: model, apphud: nil, source: "Fallback", failed: false)
                }
                let result = try await BoundedOperation.run(seconds: 5) {
                    try await self.loadRealPaywall(id)
                }
                try Task.checkCancellation()
                return result
            } catch is CancellationError {
                return nil
            } catch {
                let model = await self.fallbackHelper.fallbackToPaywallModel(
                    for: id, fileName: self.fallbackFileName
                )
                guard !Task.isCancelled else { return nil }
                return PaywallLoad(model: model, apphud: nil, source: "Fallback", failed: true)
            }
        } apply: { (result: PaywallLoad?) in
            guard let result else { return }
            self.paywallsApphud[id] = result.apphud
            self.setPaywall(result.model, for: id)
            if id.isAvailablePaywall { self.setAvailableProducts() }
            self.loadStates[id] = result.failed ? .failed : .loaded
            self.isShowingSplash = false
            self.logPaywallLoaded(id: id, source: result.source)
        }
    }

    private struct PaywallLoad {
        let model: PaywallModel
        let apphud: ApphudPaywall?
        let source: String
        let failed: Bool
    }

    ///Ивент аналитики показа пейвола
    func paywallShownEvent(_ id: PremiumPaywallID = .main) {
        guard let apphudPaywall = paywallsApphud[id] else {
            print("⚠️ [PremiumKit] Paywall shown skipped — no Apphud paywall for: \(id.rawValue)")
            return
        }
        
        print("👁️ [PremiumKit] Paywall shown — \(id.rawValue)")
        Apphud.paywallShown(apphudPaywall)
    }
    
    ///Востановление покупок
    func restorePurchase() async -> Result<Void, PaymentError> {
        
#if targetEnvironment(simulator)
        return .failure(.restoreNothingToRestore)
#else
        let result = await Apphud.restorePurchases()
        if let error = result?.error {
            return .failure(PaymentError.from(error))
        }
        
        let has = Apphud.hasPremiumAccess() || (Apphud.nonRenewingPurchases()?.isEmpty == false)
        
        if has {
            self.isPremium = true
            
            let subscriptionIds = Apphud.subscriptions()?.filter { $0.isActive() }.map { $0.productId } ?? []
            let nonRenewingIds = Apphud.nonRenewingPurchases()?.filter { $0.isActive() }.map { $0.productId } ?? []
            
            self.activeProductIds = Set(subscriptionIds + nonRenewingIds)
            return .success(())
        } else {
            return .failure(.restoreNothingToRestore)
        }
#endif
    }
    
    func purchase(_ product: ProductModel, from id: PremiumPaywallID) async -> Result<String, PaymentError> {
        guard
            let apphudPaywall = paywallsApphud[id],
            let ahProduct = apphudPaywall.products.first(where: { $0.productId == product.id })
        else {
#if DEBUG
            return await purchaseViaSK2(product, ahProduct: nil, paywallID: id)
#else
            print("⚠️ [PremiumKit] No Apphud paywall for \(id.rawValue) — purchasing by product id: \(product.id)")
            return await purchaseByID(product, paywallID: id)
#endif
        }
        
        print("🛒 [PremiumKit] Purchase started — \(product.id) from paywall: \(id.rawValue)")
        
#if DEBUG
        return await purchaseViaSK2(product, ahProduct: ahProduct, paywallID: id)
#else
        
        let result = await Apphud.purchase(ahProduct)
        
        if result.success {
            let isTrial = product.isTrial || result.subscription?.status == .trial
            
            applyPurchaseSuccess(product: product, paywallID: id, isTrial: isTrial)
            
            return .success(product.id)
        }
        
        if let error = result.error {
            return .failure(PaymentError.from(error))
        }
        
        return .failure(paymentError(from: result))
#endif
    }
    
    /// Ошибка покупки, когда Apphud не вернул error: отложенная транзакция (Ask to Buy) — это .pending
    private func paymentError(from result: ApphudPurchaseResult) -> PaymentError {
        if result.transaction?.transactionState == .deferred {
            return .pending
        }
        
        return .unknown
    }
    
    /// Общая обработка успешной покупки для всех способов оплаты
    private func applyPurchaseSuccess(product: ProductModel, paywallID: PremiumPaywallID, isTrial: Bool) {
        isPremium = true
        activeProductIds.insert(product.id)
        
        if isTrial {
            saveTrialStartDate()
        }
        
        addConsumableTokens(from: product, paywallID: paywallID)
    }
    
    /// Фоллбэк-покупка по product id из фолбэк-модели, когда пейвол Apphud не загрузился
    private func purchaseByID(_ product: ProductModel, paywallID: PremiumPaywallID) async -> Result<String, PaymentError> {
        let result: ApphudPurchaseResult = await withCheckedContinuation { continuation in
            Apphud.purchase(product.id) { result in
                continuation.resume(returning: result)
            }
        }
        
        if result.success {
            ///В фолбэке ProductModel.isTrial недостоверен — берём статус из ответа Apphud
            let isTrial = product.isTrial || result.subscription?.status == .trial
            
            applyPurchaseSuccess(product: product, paywallID: paywallID, isTrial: isTrial)
            
            print("🛒 [PremiumKit] Purchased by product id — \(product.id)")
            return .success(product.id)
        }
        
        if let error = result.error {
            return .failure(PaymentError.from(error))
        }
        
        return .failure(paymentError(from: result))
    }
    
    private func purchaseViaSK2(_ product: ProductModel, ahProduct: ApphudProduct?, paywallID: PremiumPaywallID) async -> Result<String, PaymentError> {
        let sk2Product: Product?
        if let ahProduct {
            sk2Product = try? await ahProduct.product()
        } else {
            sk2Product = try? await Product.products(for: [product.id]).first
        }
        guard let sk2Product else { return .failure(.productNotAvailable) }

        do {
            let result = try await sk2Product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    let isTrial = transaction.offerType == .introductory
                        && sk2Product.subscription?.introductoryOffer?.paymentMode == .freeTrial
                    applyPurchaseSuccess(product: product, paywallID: paywallID, isTrial: isTrial)
                    await transaction.finish()
                    print("🛒 [PremiumKit] Debug: purchased via SK2 — \(product.id)")
                    return .success(product.id)
                case .unverified:
                    return .failure(.verificationFailed)
                }
            case .userCancelled:
                return .failure(.cancelled)
            case .pending:
                return .failure(.pending)
            @unknown default:
                return .failure(.unknown)
            }
        } catch {
            return .failure(PaymentError.from(error))
        }
    }

    
    //MARK: - private methods
    private func loadRealPaywall(_ id: PremiumPaywallID) async throws -> PaywallLoad {

        guard let placement = await Apphud.placement(id.rawValue),
              let paywall = placement.paywall
        else {
            throw PaymentError.productNotAvailable
        }

        try Task.checkCancellation()

        if paywall.shouldShowFallback {
            print("🧪 [PremiumKit] \(forceFallback ? "forceFallback" : "showFallback")=true — using fallback model for: \(id.rawValue)")
            let fallbackModel = await fallbackHelper.fallbackToPaywallModel(
                for: id,
                fileName: fallbackFileName
            )
            try Task.checkCancellation()
            return PaywallLoad(model: fallbackModel, apphud: paywall, source: "Fallback", failed: false)
        }

        for ahProduct in paywall.products {
            try Task.checkCancellation()
            guard let _ = try? await ahProduct.product() else {
                throw PaymentError.productNotAvailable
            }
        }

        let model: PaywallModel
        if let response = paywall.paywallResponse,
           let responseProducts = response.products, !responseProducts.isEmpty {
            var productModels: [ProductModel] = []

            for responseProduct in responseProducts {
                try Task.checkCancellation()
                guard let ahProduct = paywall.products.first(
                    where: { $0.productId == responseProduct.id }
                ) else { continue }

                let isTrial = await ahProduct.isTrail()
                let isLifetime = await ahProduct.nonConsumable
                let pricePerPeriod = await ahProduct.getPricePerPeriod()
                var pricePerWeek = await ahProduct.getPricePerWeek()
                let trialDuration = await ahProduct.getTrialDuration()
                let subscriptionDuration = await ahProduct.getSubscriptionDuration()

                if isLifetime {
                    let configPeriodly = L10n.resolve(responseProduct.periodly)
                    if !configPeriodly.isEmpty { pricePerWeek = configPeriodly }
                }

                let productModel = ProductModel(
                    id: responseProduct.id,
                    title: L10n.resolve(responseProduct.title),
                    subtitle: L10n.resolveOptional(responseProduct.subtitle),
                    nonTrialSubtitle: L10n.resolveOptional(responseProduct.nonTrialSubtitle),
                    message: L10n.resolveOptional(responseProduct.message),
                    periodly: L10n.resolve(responseProduct.periodly),
                    pricePerPeriod: pricePerPeriod,
                    pricePerWeek: pricePerWeek,
                    isTrial: isTrial,
                    isLifetime: isLifetime,
                    consumable: responseProduct.consumable,
                    consumableUnit: responseProduct.consumableUnit,
                    trialDuration: trialDuration,
                    subscriptionDuration: subscriptionDuration
                )
                productModels.append(productModel)
            }

            model = PaywallModel(id: id, response: response, products: productModels)
        } else {
            print("⚠️ [PremiumKit] JSON mismatch — using mock model for: \(id.rawValue)")
            var mock = PaywallModel(id: id)
            var productModels: [ProductModel] = []

            for (index, ahProduct) in paywall.products.enumerated() {
                try Task.checkCancellation()
                let isTrial = await ahProduct.isTrail()
                let isLifetime = await ahProduct.nonConsumable
                let pricePerPeriod = await ahProduct.getPricePerPeriod()
                var pricePerWeek = await ahProduct.getPricePerWeek()
                let trialDuration = await ahProduct.getTrialDuration()
                let subscriptionDuration = await ahProduct.getSubscriptionDuration()

                let mockProduct = index < mock.products.count ? mock.products[index] : nil

                if isLifetime, let configPeriodly = mockProduct?.periodly, !configPeriodly.isEmpty {
                    pricePerWeek = L10n.resolve(configPeriodly)
                }

                productModels.append(ProductModel(
                    id: ahProduct.productId,
                    title: mockProduct?.title ?? ahProduct.productId,
                    subtitle: mockProduct?.subtitle,
                    nonTrialSubtitle: mockProduct?.nonTrialSubtitle,
                    message: mockProduct?.message,
                    periodly: mockProduct?.periodly ?? "",
                    pricePerPeriod: pricePerPeriod,
                    pricePerWeek: pricePerWeek,
                    isTrial: isTrial,
                    isLifetime: isLifetime,
                    consumable: mockProduct?.consumable,
                    consumableUnit: mockProduct?.consumableUnit,
                    trialDuration: trialDuration,
                    subscriptionDuration: subscriptionDuration
                ))
            }

            mock.products = productModels
            model = mock
        }

        try Task.checkCancellation()
        return PaywallLoad(model: model, apphud: paywall, source: "Apphud", failed: false)
    }

    
    private func setAvailableProducts() {
        let products = (loadedPaywalls[.main] ?? loadedPaywalls[.onboarding])?.products ?? []

        if products.count > 1 {
            availableProducts = .bothProducts
            return
        }

        if products.first?.isTrial == true {
            availableProducts = .withTrial
        } else {
            availableProducts = .noTrial
        }
    }

    
    private func bind() {
        networkMonitor.isConnectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self, isConnected else { return }

                Task { @MainActor in
                    guard !self.forceFallback else { return }
                    let failedIDs = self.loadStates.compactMap { id, state in
                        state == .failed ? id : nil
                    }
                    for id in failedIDs {
                        Task { await self.fetchPaywall(id) }
                    }
                }
            }
            .store(in: &cancellables)
    }


    
    private func trackASA() {
        _Concurrency.Task {
            if let asaToken = try? AAAttribution.attributionToken() {
                Apphud.setAttribution(data: nil,
                                      from: .appleAdsAttribution,
                                      identifer: asaToken,
                                      callback: nil)
            }
        }
    }
    
    private func checkPremiumSubscription() {
        isPremium = Apphud.hasPremiumAccess() || (Apphud.nonRenewingPurchases()?.isEmpty == false)
        activeProductIds = Set(
            Apphud.subscriptions()?.filter { $0.isActive() }.map { $0.productId } ?? []
        )
        isPremiumChecked = true
        checkAndUpdateSubscriptionTokens()
        
        #if DEBUG
        Task {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    await MainActor.run {
                        self.activeProductIds.insert(transaction.productID)
                    }
                }
            }
        }
        #endif
    }
    
    private func checkAndUpdateSubscriptionTokens() {
        guard let subscription = Apphud.subscriptions()?.first(where: { $0.isActive() }) else {
            TokenStorage.shared.resetSubscriptionTokens()
            TokenStorage.shared.lastKnownExpiresAt = nil
            TokenStorage.shared.lastSubscriptionProductId = nil
            return
        }
        
        let currentExpiresAt = subscription.expiresDate
        let lastExpiresAt = TokenStorage.shared.lastKnownExpiresAt
        let lastProductId = TokenStorage.shared.lastSubscriptionProductId
        
        let isNewPeriod = lastExpiresAt == nil || currentExpiresAt > lastExpiresAt!
        let isProductChanged = lastProductId != subscription.productId
        
        if isNewPeriod || isProductChanged {
            let storedAmount = TokenStorage.shared.lastSubscriptionTokenAmount
            if storedAmount > 0 {
                TokenStorage.shared.setSubscriptionTokens(storedAmount)
            }
            
            TokenStorage.shared.lastKnownExpiresAt = currentExpiresAt
            TokenStorage.shared.lastSubscriptionProductId = subscription.productId
        }
    }
    
    private func logPaywallLoaded(id: PremiumPaywallID, source: String) {
        let config = paywall(for: id)?.configuration
        print("📦 [PremiumKit] Paywall \(id.rawValue) loaded — source: \(source), configuration: \(config?.rawValue ?? "none")")
    }
    
    private func saveTrialStartDate() {
        UserDefaults.standard.set(Date(), forKey: Constants.trialUserDefaultsKey)
    }
    
    private func addConsumableTokens(from product: ProductModel, paywallID: PremiumPaywallID) {
        guard let tokens = product.consumable, tokens > 0 else { return }
        
        if paywallID == .consumable {
            TokenStorage.shared.addPurchased(tokens)
        } else {
            TokenStorage.shared.setSubscriptionTokens(tokens)
            TokenStorage.shared.lastSubscriptionTokenAmount = tokens
            if let subscription = Apphud.subscriptions()?.first(where: { $0.isActive() }) {
                TokenStorage.shared.lastKnownExpiresAt = subscription.expiresDate
                TokenStorage.shared.lastSubscriptionProductId = product.id
            }
        }
    }
}
