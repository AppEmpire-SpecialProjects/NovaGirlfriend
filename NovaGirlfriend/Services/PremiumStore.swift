import Combine
import PremiumKit
import StoreKit

@MainActor
final class PremiumStore: ObservableObject {
  static let shared = PremiumStore()

  @Published private(set) var isPremium = false
  @Published private(set) var hasVerifiedEntitlement = false
  private var sessionPremiumEnabled = false
  @Published private(set) var products: [Product] = []
  @Published private(set) var isLoading = false
  @Published private(set) var isPurchasing = false
  @Published var errorMessage: String?

  private var updatesTask: Task<Void, Never>?
  private var expiryTask: Task<Void, Never>?
  private var loadTask: Task<Void, Never>?
  private var loadGeneration = UUID()
  private var paywallID: PremiumPaywallID = .main
  private let allowedIDs = PurchaseConfiguration.productIDs

  private init() {
    updatesTask = Task { [weak self] in
      for await result in Transaction.updates {
        guard let self else { return }
        if case .verified(let transaction) = result {
          await self.refreshEntitlements()
          await transaction.finish()
        }
      }
    }
  }

  deinit {
    updatesTask?.cancel()
    expiryTask?.cancel()
    loadTask?.cancel()
  }

  func load(_ id: PremiumPaywallID) async {
    guard !isPurchasing else { return }
    if paywallID == id, let loadTask {
      await loadTask.value
      return
    }
    loadTask?.cancel()
    let generation = UUID()
    loadGeneration = generation
    isLoading = true
    errorMessage = nil
    paywallID = id
    products = []
    let task = Task { await self.loadCatalog(id, generation: generation) }
    loadTask = task
    await task.value
  }

  private func loadCatalog(_ id: PremiumPaywallID, generation: UUID) async {
    defer {
      if loadGeneration == generation {
        isLoading = false
        loadTask = nil
      }
    }
    await Premium.shared.loadPaywall(id)
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async { continuation.resume() }
    }
    guard loadGeneration == generation, !Task.isCancelled else { return }
    let configured = (Premium.shared.paywall(for: id)?.products ?? [])
      .filter { allowedIDs.contains($0.id) }
    do {
      let fetched = try await PurchaseDeadline.run(seconds: 10) {
        try await Product.products(for: configured.map(\.id))
      }
      guard loadGeneration == generation, !Task.isCancelled else { return }
      products = configured.compactMap { item in fetched.first { $0.id == item.id } }
      if products.isEmpty {
        errorMessage = "Plans are unavailable. Check your connection and try again."
      }
    } catch {
      guard loadGeneration == generation, !Task.isCancelled else { return }
      errorMessage = error.localizedDescription
    }
    Premium.shared.paywallShown(id)
  }

  func refreshEntitlements() async {
    var active = false
    var nextExpiry: Date?
    for await result in Transaction.currentEntitlements {
      guard case .verified(let transaction) = result,
        transaction.revocationDate == nil,
        !transaction.isUpgraded,
        transaction.expirationDate.map({ $0 > Date() }) ?? true,
        transaction.productType == .autoRenewable || transaction.productType == .nonConsumable,
        allowedIDs.contains(transaction.productID)
      else { continue }
      active = true
      if let expiry = transaction.expirationDate {
        nextExpiry = min(nextExpiry ?? expiry, expiry)
      }
    }
    hasVerifiedEntitlement = active
    isPremium = active || sessionPremiumEnabled
    expiryTask?.cancel()
    if let nextExpiry {
      expiryTask = Task { [weak self] in
        do {
          try await Task.sleep(for: .seconds(max(0, nextExpiry.timeIntervalSinceNow)))
          await self?.refreshEntitlements()
        } catch {
          // A newer entitlement snapshot replaces this scheduled refresh.
        }
      }
    }
  }

  func enableSessionPremium() {
    #if DEBUG
      sessionPremiumEnabled = true
      isPremium = true
    #endif
  }

  func purchaseOnboarding(trialEnabled: Bool) async -> Bool {
    guard !isLoading, !isPurchasing else { return false }
    await load(.onboarding)
    let models = (Premium.shared.paywall(for: .onboarding)?.products ?? [])
      .filter { allowedIDs.contains($0.id) }
    let trial = models.first { $0.hasTrial }
    let regular = models.first { !$0.hasTrial }
    let selected: PremiumProduct?
    if let trial, let regular {
      selected = trialEnabled ? trial : regular
    } else {
      selected = trialEnabled && models.count > 1 ? models[1] : models.first
    }
    guard let selected, let product = products.first(where: { $0.id == selected.id }) else {
      errorMessage = "The selected plan is unavailable. Please try again."
      return false
    }
    if trialEnabled {
      guard let subscription = product.subscription,
        subscription.introductoryOffer?.paymentMode == .freeTrial,
        await subscription.isEligibleForIntroOffer
      else {
        errorMessage =
          "A free trial is not available for this account. Turn off the trial to continue with a paid subscription."
        return false
      }
    }
    return await purchase(product)
  }

  func purchase(_ product: Product) async -> Bool {
    guard !isPurchasing, !isLoading,
      let model = Premium.shared.paywall(for: paywallID)?.products.first(where: {
        $0.id == product.id
      })
    else { return false }
    isPurchasing = true
    errorMessage = nil
    defer { isPurchasing = false }
    let result = await Premium.shared.purchase(model, from: paywallID)
    switch result {
    case .success:
      await refreshEntitlements()
      if !hasVerifiedEntitlement {
        errorMessage = "Your purchase is processing. Access will update when Apple verifies it."
      }
      return hasVerifiedEntitlement
    case .failure(.cancelled):
      return false
    case .failure(let error):
      errorMessage = error.localizedDescription
      return false
    }
  }

  func restore() async {
    guard !isPurchasing else { return }
    isPurchasing = true
    errorMessage = nil
    defer { isPurchasing = false }
    do {
      try await AppStore.sync()
      let result = await Premium.shared.restore()
      await refreshEntitlements()
      if !hasVerifiedEntitlement {
        if case .failure(let error) = result {
          errorMessage = error.localizedDescription
        } else {
          errorMessage = "No active purchases to restore."
        }
      }
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
