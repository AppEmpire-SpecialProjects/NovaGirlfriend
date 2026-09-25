import Foundation
import ApphudSDK

struct PaywallModel {
    var id: PremiumPaywallID
    var title: String
    var tryFreeButton: String
    var continueButton: String
    var purchaseButton: String
    var limitedButton: String
    var configuration: PaywallConfiguration
    var products: [ProductModel]
    /// Показывать запрос оценки (SKStoreReviewController); выключается флагом
    /// `showRequestReview: false` в JSON пейволла, по умолчанию — true
    var showRequestReview: Bool = true
}

struct ProductModel: Identifiable, Codable, Hashable, Sendable {
    var id: String
    var title: String
    var subtitle: String?
    var nonTrialSubtitle: String?
    var message: String?
    var periodly: String
    var pricePerPeriod: String
    var pricePerWeek: String
    var isTrial: Bool
    var isLifetime: Bool
    var consumable: Int?
    var consumableUnit: String?
    var trialDuration: String?
    var subscriptionDuration: String?
    
    init(
        id: String,
        title: String,
        subtitle: String? = nil,
        nonTrialSubtitle: String? = nil,
        message: String? = nil,
        periodly: String,
        pricePerPeriod: String,
        pricePerWeek: String,
        isTrial: Bool,
        isLifetime: Bool = false,
        consumable: Int? = nil,
        consumableUnit: String? = nil,
        trialDuration: String? = nil,
        subscriptionDuration: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.nonTrialSubtitle = nonTrialSubtitle
        self.message = message
        self.periodly = periodly
        self.pricePerPeriod = pricePerPeriod
        self.pricePerWeek = pricePerWeek
        self.isTrial = isTrial
        self.isLifetime = isLifetime
        self.consumable = consumable
        self.consumableUnit = consumableUnit
        self.trialDuration = trialDuration
        self.subscriptionDuration = subscriptionDuration
    }
    
    var paywallSubtitle: String {
        let base = isTrial ? subtitle ?? "" : nonTrialSubtitle ?? ""
        if base.isEmpty {
            return pricePerPeriod
        }
        return "\(base) \(pricePerPeriod)"
    }
}

extension ProductModel {
    func toPublic() -> PremiumProduct {
        PremiumProduct(
            id: id,
            title: title,
            subtitle: subtitle,
            nonTrialSubtitle: nonTrialSubtitle,
            message: message,
            period: periodly,
            pricePerPeriod: pricePerPeriod,
            pricePerWeek: pricePerWeek,
            hasTrial: isTrial,
            isLifetime: isLifetime,
            consumable: consumable,
            consumableUnit: consumableUnit,
            trialDuration: trialDuration,
            subscriptionDuration: subscriptionDuration
        )
    }
}

extension PremiumProduct {

    func toInternal(using paywall: PaywallModel) -> ProductModel? {
        paywall.products.first { $0.id == id }
    }
}

extension ProductModel {
    init(
        response: ApphudPaywallResponse.ProductResponse,
        product: ApphudProduct,
        isTrial: Bool,
        isLifetime: Bool = false
    ) {
        id = response.id
        title = L10n.resolve(response.title)
        subtitle = L10n.resolveOptional(response.subtitle)
        nonTrialSubtitle = L10n.resolveOptional(response.nonTrialSubtitle)
        message = L10n.resolveOptional(response.message)
        periodly = L10n.resolve(response.periodly)
        
        pricePerWeek = product.pricePerWeek
        pricePerPeriod = product.pricePerPeriod
        self.isTrial = isTrial
        self.isLifetime = isLifetime
        self.consumable = response.consumable
        self.consumableUnit = response.consumableUnit
    }
}

extension PaywallModel {
    
    static let mockMain = PaywallModel(
        id: .main,
        title: "Unlimited access!",
        tryFreeButton: "Try free & subscribe",
        continueButton: "Continue & subscribe",
        purchaseButton: "Purchase & continue",
        limitedButton: "or procceed with limited version",
        configuration: .variant1,
        products: [
            ProductModel(
                id: "w",
                title: "Optimal",
                subtitle: "Try 3 days free then",
                nonTrialSubtitle: "Get full access for just",
                message: "",
                periodly: "Weekly",
                pricePerPeriod: "$4.99/week",
                pricePerWeek: "Total $4.99 per week",
                isTrial: true
            ),
            ProductModel(
                id: "m",
                title: "Popular",
                subtitle: "",
                message: "",
                periodly: "Monthly",
                pricePerPeriod: "$12.99/month",
                pricePerWeek: "Total $3.24 per week",
                isTrial: false
            ),
            ProductModel(
                id: "y",
                title: "Best Deal",
                subtitle: "",
                message: "",
                periodly: "Yearly",
                pricePerPeriod: "$39.99/year",
                pricePerWeek: "Total $0.83 per week",
                isTrial: false
            ),
            ProductModel(
                id: "l",
                title: "Lifetime Deal",
                subtitle: "",
                message: "",
                periodly: "This is a limited time offer",
                pricePerPeriod: "$59.99/one time",
                pricePerWeek: "Limited Time Offer",
                isTrial: false,
                isLifetime: true
            )
        ]
    )
    
    static let mockOnboarding = PaywallModel(
        id: .onboarding,
        title: "Unlimited access!",
        tryFreeButton: "Try free & subscribe",
        continueButton: "Continue & subscribe",
        purchaseButton: "Purchase & continue",
        limitedButton: "or procceed with limited version",
        configuration: .variant1,
        products: [
            ProductModel(
                id: "wtrial",
                title: "3 days free trial",
                subtitle: "Try 3 days free then",
                nonTrialSubtitle: "Get full access for just",
                message: "Free trial enabled",
                periodly: "Weekly",
                pricePerPeriod: "$4.99/week",
                pricePerWeek: "Total $4.99/week",
                isTrial: true,
                trialDuration: "3 days",
                subscriptionDuration: "7 days"
            ),
            ProductModel(
                id: "w",
                title: "Optimal",
                subtitle: "Try 3 days free then",
                nonTrialSubtitle: "Get full access for just",
                message: "Enable a 3 days free trial",
                periodly: "Weekly",
                pricePerPeriod: "$4.99/week",
                pricePerWeek: "Total $4.99/week",
                isTrial: false,
                subscriptionDuration: "7 days"
            )
        ]
    )
    
    init(id: PremiumPaywallID) {
        if id == .main { self = .mockMain }
        else if id == .onboarding { self = .mockOnboarding }
        else {
            self.id = id
            self.title = ""
            self.tryFreeButton = ""
            self.continueButton = ""
            self.purchaseButton = ""
            self.limitedButton = ""
            self.configuration = .variant1
            self.products = []
            self.showRequestReview = true
        }
    }
}

extension PaywallModel {
    init(
        id: PremiumPaywallID,
        response: ApphudPaywallResponse,
        products: [ProductModel]
    ) {
        self.id = id
        self.title = L10n.localized(response.title ?? "")
        self.tryFreeButton = L10n.localized(response.tryFreeButton ?? "")
        self.continueButton = L10n.localized(response.continueButton ?? "")
        self.purchaseButton = L10n.localized(response.purchaseButton ?? "")
        self.limitedButton = L10n.localized(response.limitedButton ?? "")
        self.configuration = PaywallConfiguration(response.configurationAB ?? "variant1")
        self.products = products
        self.showRequestReview = response.showRequestReview ?? true
    }
}
