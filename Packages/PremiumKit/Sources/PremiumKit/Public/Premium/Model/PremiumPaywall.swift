// Sources/PremiumKit/Public/Paywall/PremiumPaywall.swift

import Foundation

public struct PremiumPaywall: Identifiable, Sendable {

    public let id: PremiumPaywallID

    public let title: String
    public let configuration: PaywallConfiguration

    public let buttons: Buttons
    public let products: [PremiumProduct]

    /// Показывать запрос оценки после онбординга; выключается флагом
    /// `showRequestReview: false` в JSON пейволла Apphud, по умолчанию — true
    public let showRequestReview: Bool

    public struct Buttons: Sendable {
        public let tryFree: String
        public let `continue`: String
        public let purchase: String
        public let limited: String

        public init(
            tryFree: String,
            continue: String,
            purchase: String,
            limited: String
        ) {
            self.tryFree = tryFree
            self.continue = `continue`
            self.purchase = purchase
            self.limited = limited
        }
    }

    public init(
        id: PremiumPaywallID,
        title: String,
        configuration: PaywallConfiguration,
        buttons: Buttons,
        products: [PremiumProduct],
        showRequestReview: Bool = true
    ) {
        self.id = id
        self.title = title
        self.configuration = configuration
        self.buttons = buttons
        self.products = products
        self.showRequestReview = showRequestReview
    }
    
    public func buttonTitle(for product: PremiumProduct) -> String {
        if product.isLifetime {
            return buttons.purchase
        } else if product.hasTrial {
            return buttons.tryFree
        } else {
            return buttons.continue
        }
    }
}

extension PaywallModel {

    func toPublic() -> PremiumPaywall {
        PremiumPaywall(
            id: id,
            title: title,
            configuration: configuration,
            buttons: .init(
                tryFree: tryFreeButton,
                continue: continueButton,
                purchase: purchaseButton,
                limited: limitedButton
            ),
            products: products.map { $0.toPublic() },
            showRequestReview: showRequestReview
        )
    }
}
