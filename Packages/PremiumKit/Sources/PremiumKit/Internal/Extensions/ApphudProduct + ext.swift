import ApphudSDK
import StoreKit
import Foundation

extension ApphudProduct {
    var nonConsumable: Bool {
        get async {
            guard let product = try? await product() else { return false }
            return product.type == .nonConsumable
        }
    }
}

extension ApphudProduct {
    
    // MARK: - Async with SK2 fallback
    
    func getPricePerWeek() async -> String {
        let sk1Price = pricePerWeekSK1
        if sk1Price != "unowned" {
            return sk1Price
        }
        
        let productId = self.productId
        guard let sk2Product = try? await Product.products(for: [productId]).first else {
            return "unowned"
        }
        return Self.pricePerWeekFromSK2Product(sk2Product)
    }
    
    func getPricePerPeriod() async -> String {
        let sk1Price = pricePerPeriodSK1
        if sk1Price != "unowned" {
            return sk1Price
        }
        
        let productId = self.productId
        guard let sk2Product = try? await Product.products(for: [productId]).first else {
            return "unowned"
        }
        return Self.pricePerPeriodFromSK2Product(sk2Product)
    }
    
    // MARK: - SK1
    
    private var pricePerWeekSK1: String {
        guard let locale = self.skProduct?.priceLocale else { return "unowned" }
        guard let price = self.skProduct?.price else { return "unowned" }
        guard let perWeek = self.skProduct?.subscriptionPeriod?.pricePerWeek(price) else {
            return L10n.Price.limitedOffer
        }
        return L10n.Price.perWeek(formatPrice(locale: locale, price: perWeek))
    }
    
    private var pricePerPeriodSK1: String {
        guard let locale = self.skProduct?.priceLocale else { return "unowned" }
        guard let price = self.skProduct?.price else { return "unowned" }
        guard let period = self.skProduct?.subscriptionPeriod?.period else {
            return formatPrice(locale: locale, price: price) + "/\(L10n.Period.oneTime)"
        }
        return formatPrice(locale: locale, price: price) + "/" + period
    }
    
    // MARK: - SK2 helpers
    
    private static func pricePerWeekFromSK2Product(_ product: Product) -> String {
        guard let subscription = product.subscription else {
            return L10n.Price.limitedOffer
        }
        let perWeek = pricePerWeekFromSK2(price: product.price, period: subscription.subscriptionPeriod)
        return L10n.Price.perWeek(formatPriceSK2(perWeek, product: product))
    }
    
    private static func pricePerPeriodFromSK2Product(_ product: Product) -> String {
        guard let subscription = product.subscription else {
            return product.displayPrice + "/\(L10n.Period.oneTime)"
        }
        let periodString = periodFromSK2(subscription.subscriptionPeriod)
        return product.displayPrice + "/" + periodString
    }
    
    private static func pricePerWeekFromSK2(price: Decimal, period: Product.SubscriptionPeriod) -> Decimal {
        switch period.unit {
        case .day:
            return price * 7 / Decimal(period.value)
        case .week:
            return price / Decimal(period.value)
        case .month:
            return price / Decimal(period.value * 4)
        case .year:
            return price / Decimal(period.value * 52)
        @unknown default:
            return price
        }
    }
    
    private static func periodFromSK2(_ period: Product.SubscriptionPeriod) -> String {
        if period.unit == .day && period.value == 7 {
            return L10n.Period.week
        }
        switch period.unit {
        case .day: return L10n.Period.day
        case .week: return L10n.Period.week
        case .month: return L10n.Period.month
        case .year: return L10n.Period.year
        @unknown default: return "-"
        }
    }
    
    private static func formatPriceSK2(_ price: Decimal, product: Product) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceFormatStyle.locale
        return formatter.string(from: price as NSDecimalNumber) ?? product.displayPrice
    }
    
    // MARK: - Legacy sync (for compatibility)
    
    var pricePerWeek: String {
        pricePerWeekSK1
    }
    
    var pricePerPeriod: String {
        pricePerPeriodSK1
    }
    
    func formatPrice(locale: Locale, price: NSDecimalNumber) -> String {
        let decimal = price.decimalValue
        guard let currencyCode = locale.currency?.identifier else { return "unowned" }

        var currencyStyle = Decimal.FormatStyle.Currency(code: currencyCode, locale: locale)
        currencyStyle = currencyStyle.precision(.fractionLength(0...2))

        return decimal.formatted(currencyStyle)
    }
    
    func isTrail() async -> Bool {
        guard let product = try? await product() else { return false }
        guard let isEligible = await product.subscription?.isEligibleForIntroOffer else { return false }
        return isEligible && (product.subscription?.introductoryOffer != nil)
    }
    
    func getTrialDuration() async -> String? {
        if let sk1Offer = self.skProduct?.introductoryPrice,
           sk1Offer.paymentMode == .freeTrial {
            return Self.humanReadablePeriod(unit: sk1Offer.subscriptionPeriod.unit, value: sk1Offer.subscriptionPeriod.numberOfUnits)
        }
        
        guard let sk2Product = try? await product(),
              let offer = sk2Product.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else { return nil }
        return Self.humanReadablePeriodSK2(offer.period)
    }
    
    func getSubscriptionDuration() async -> String? {
        if let sk1Period = self.skProduct?.subscriptionPeriod {
            return Self.humanReadablePeriod(unit: sk1Period.unit, value: sk1Period.numberOfUnits)
        }
        
        guard let sk2Product = try? await product(),
              let subscription = sk2Product.subscription else { return nil }
        return Self.humanReadablePeriodSK2(subscription.subscriptionPeriod)
    }
    
    private static func humanReadablePeriod(unit: SKProduct.PeriodUnit, value: Int) -> String {
        switch unit {
        case .day:
            if value == 7 { return L10n.localized("duration.weeks", 1) }
            return L10n.localized("duration.days", value)
        case .week:
            return L10n.localized("duration.weeks", value)
        case .month:
            return L10n.localized("duration.months", value)
        case .year:
            return L10n.localized("duration.years", value)
        @unknown default:
            return "\(value)"
        }
    }
    
    private static func humanReadablePeriodSK2(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            if period.value == 7 { return L10n.localized("duration.weeks", 1) }
            return L10n.localized("duration.days", period.value)
        case .week:
            return L10n.localized("duration.weeks", period.value)
        case .month:
            return L10n.localized("duration.months", period.value)
        case .year:
            return L10n.localized("duration.years", period.value)
        @unknown default:
            return "\(period.value)"
        }
    }
}
