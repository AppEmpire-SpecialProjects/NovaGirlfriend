import Foundation
import StoreKit

@MainActor
class FallbackHelper {
    /// Decode first without Apphud or StoreKit I/O. StoreKit enrichment has its
    /// own small budget; unavailable stores cannot hold the fallback hostage.
    func fallbackToPaywallModel(for id: PremiumPaywallID, fileName: String) async -> PaywallModel {
        let local = localPaywallModel(for: id, fileName: fileName)
        guard !local.products.isEmpty, !Task.isCancelled else { return local }
        return (try? await BoundedOperation.run(seconds: 1) {
            try await self.enrichWithStoreKit(local)
        }) ?? local
    }

    func localPaywallModel(
        for id: PremiumPaywallID,
        fileName: String,
        bundle: Bundle = .main
    ) -> PaywallModel {
        guard let paywallFallback = loadFallbackPaywall(id, fileName: fileName, bundle: bundle) else {
            var model = PaywallModel(id: id)
            // Keep the existing layout/copy, but never expose mock purchase IDs
            // when the configured fallback is absent or malformed.
            model.products = []
            return model
        }
        
        var products: [ProductModel] = []
        
        for fallbackProduct in paywallFallback.products {
            
            let storekitProduct = skFind(productId: fallbackProduct.id)
            let storekitPrice = storekitProduct?.displayPrice
            let subscriptionPeriod = storekitProduct?.recurringSubscriptionPeriod

            let isLifetime = (subscriptionPeriod == nil)

            let configPeriodly = L10n.resolve(fallbackProduct.periodly)
            ///Период ищем и в сыром ключе, и в локализованном значении — periodly может быть ключом локализации
            let periodSource = "\(fallbackProduct.periodly) \(configPeriodly)".lowercased()

            let pricePerPeriod: String = {
                if let price = storekitPrice {
                    return perPeriodString(price: price, period: subscriptionPeriod)
                } else {
                    switch periodSource {
                    case let period where period.contains("week"):  return "$4.99/\(L10n.Period.week)"
                    case let period where period.contains("month"): return "$12.99/\(L10n.Period.month)"
                    case let period where period.contains("year"):  return "$39.99/\(L10n.Period.year)"
                    default:                                        return "$59.99/\(L10n.Period.oneTime)"
                    }
                }
            }()

            let pricePerWeek: String = {
                let lifetimeText = configPeriodly.isEmpty ? L10n.Price.limitedOffer : configPeriodly

                if let price = storekitPrice {
                    guard subscriptionPeriod != nil else { return lifetimeText }
                    return perWeekString(price: price, period: subscriptionPeriod)
                } else {
                    switch periodSource {
                    case let period where period.contains("week"):  return L10n.Price.perWeek("$4.99")
                    case let period where period.contains("month"): return L10n.Price.perWeek("$3.24")
                    case let period where period.contains("year"):  return L10n.Price.perWeek("$0.83")
                    default:                                        return lifetimeText
                    }
                }
            }()

            // A bundled offer is not proof of this user's eligibility. Only
            // StoreKit enrichment below may enable a trial.
            let isTrial = false
            let trialDuration: String? = nil
            let subscriptionDuration = subscriptionPeriod.map { duration($0) }

            let product: ProductModel
            product = ProductModel(
                id: fallbackProduct.id,
                title: L10n.resolve(fallbackProduct.title),
                subtitle: L10n.resolveOptional(fallbackProduct.subtitle),
                nonTrialSubtitle: L10n.resolveOptional(fallbackProduct.nonTrialSubtitle),
                message: L10n.resolveOptional(fallbackProduct.message),
                periodly: L10n.resolve(fallbackProduct.periodly),
                pricePerPeriod: pricePerPeriod,
                pricePerWeek: pricePerWeek,
                isTrial: isTrial,
                isLifetime: isLifetime,
                consumable: fallbackProduct.consumable,
                consumableUnit: fallbackProduct.consumableUnit,
                trialDuration: trialDuration,
                subscriptionDuration: subscriptionDuration
            )
            products.append(product)
        }
        
        let paywall = PaywallModel(id: id,
                                   title: L10n.localized(paywallFallback.title),
                                   tryFreeButton: L10n.localized(paywallFallback.tryFreeButton ?? "button.try_free"),
                                   continueButton: L10n.localized(paywallFallback.continueButton ?? "button.continue"),
                                   purchaseButton: L10n.localized(paywallFallback.purchaseButton ?? "button.purchase"),
                                   limitedButton: L10n.localized(paywallFallback.limitedButton ?? "button.limited"),
                                   configuration: PaywallConfiguration(paywallFallback.configurationAB ?? "variant1"),
                                   products: products,
                                   showRequestReview: paywallFallback.showRequestReview ?? true)
        
        return paywall
    }
    
    private func loadFallbackPaywall(_ paywallType: PremiumPaywallID, fileName: String, bundle: Bundle) -> FallbackPaywall? {
        guard
            let url = bundle.url(forResource: fileName, withExtension: "json"),
            let encryptedData = try? Data(contentsOf: url),
            let data = PremiumKitFallbackDecoder287361f89baa0147.decrypt(encryptedData),
            let file = try? JSONDecoder().decode(FallbackFile.self, from: data),
            let entry = file.data.results.first(where: { $0.name == paywallType.rawValue }),
            let innerData = entry.json.data(using: .utf8),
            let paywall = try? JSONDecoder().decode(FallbackPaywall.self, from: innerData)
        else {
            print("Load Fallback Paywall: failed for \(paywallType) in \(fileName).json")
            return nil
        }
        return paywall
    }

    private func enrichWithStoreKit(_ local: PaywallModel) async throws -> PaywallModel {
        let products = try await Product.products(for: local.products.map(\.id))
        try Task.checkCancellation()
        var model = local
        for index in model.products.indices {
            guard let product = products.first(where: { $0.id == model.products[index].id }) else { continue }
            model.products[index].isLifetime = product.type == .nonConsumable
            if let subscription = product.subscription {
                let eligible = await subscription.isEligibleForIntroOffer
                try Task.checkCancellation()
                let offer = subscription.introductoryOffer
                model.products[index].isTrial = eligible && offer != nil
                model.products[index].trialDuration = offer?.paymentMode == .freeTrial
                    ? offer.map { duration($0.period) } : nil
                model.products[index].subscriptionDuration = duration(subscription.subscriptionPeriod)
                model.products[index].pricePerPeriod = product.displayPrice + "/" + period(subscription.subscriptionPeriod)
            } else {
                model.products[index].pricePerPeriod = product.displayPrice + "/" + L10n.Period.oneTime
            }
        }
        return model
    }

    private func period(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day: return period.value == 7 ? L10n.Period.week : L10n.Period.day
        case .week: return L10n.Period.week
        case .month: return L10n.Period.month
        case .year: return L10n.Period.year
        @unknown default: return "period"
        }
    }

    private func duration(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return period.value == 7
                ? L10n.localized("duration.weeks", 1)
                : L10n.localized("duration.days", period.value)
        case .week: return L10n.localized("duration.weeks", period.value)
        case .month: return L10n.localized("duration.months", period.value)
        case .year: return L10n.localized("duration.years", period.value)
        @unknown default: return "\(period.value)"
        }
    }

    private func duration(_ period: SKConfig.SKProduct.Period) -> String {
        switch period.unit {
        case .day:
            return period.numberOfUnits == 7
                ? L10n.localized("duration.weeks", 1)
                : L10n.localized("duration.days", period.numberOfUnits)
        case .weekOfMonth: return L10n.localized("duration.weeks", period.numberOfUnits)
        case .month: return L10n.localized("duration.months", period.numberOfUnits)
        case .year: return L10n.localized("duration.years", period.numberOfUnits)
        default: return "\(period.numberOfUnits)"
        }
    }

    private func skFind(productId: String) -> SKConfig.SKProduct? {
        guard let config = SKConfig.shared else { return nil }

        if let product = config.subscriptionGroups?.flatMap(\.subscriptions).first(where: { $0.productID == productId }) {
            return product
        }
        if let product = config.nonRenewingSubscriptions?.first(where: { $0.productID == productId }) {
            return product
        }
        if let product = config.nonConsumableProducts?.first(where: { $0.productID == productId }) {
            return product
        }
        return nil
    }
    
    private func perPeriodString(price: String, period: SKConfig.SKProduct.Period?) -> String {
            guard let period else { return "$\(price)/\(L10n.Period.oneTime)" }
            return "$\(price)/\(period.localizedOne)"
        }

    private func moneyToDecimal(_ s: String) -> Decimal? {
        let filtered = s.filter { "0123456789.,".contains($0) }
        let normalized = filtered.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }

    private func weeks(in period: SKConfig.SKProduct.Period) -> Decimal {
        switch period.unit {
        case .day:        return Decimal(period.numberOfUnits) / 7
        case .weekOfMonth:return Decimal(period.numberOfUnits)
        case .month:      return Decimal(period.numberOfUnits * 4)
        case .year:       return Decimal(period.numberOfUnits * 52)
        default:          return 1
        }
    }

    private func truncate(_ value: Decimal, scale: Int) -> Decimal {
        var v = value, r = Decimal()
        NSDecimalRound(&r, &v, scale, .down)
        return r
    }

    private func currencySymbol(from price: String) -> String {
        for ch in price {
            if !ch.isNumber && ch != "." && ch != "," && !ch.isWhitespace { return String(ch) }
        }
        return "$"
    }

    private func perWeekString(price: String, period: SKConfig.SKProduct.Period?) -> String {
        guard let period, let priceDec = moneyToDecimal(price) else {
            return L10n.Price.limitedOffer
        }

        let isWeekly = (period.unit == .weekOfMonth && period.numberOfUnits == 1)
                    || (period.unit == .day && period.numberOfUnits == 7)

        let weekly = isWeekly ? priceDec : (priceDec / weeks(in: period))
        let truncated = truncate(weekly, scale: 2)

        let sym = currencySymbol(from: price)
        return L10n.Price.perWeek("\(sym)\(truncated)")
    }
}
