import ApphudSDK

struct ApphudPaywallResponse: Codable {
    let title: String?
    let tryFreeButton: String?
    let continueButton: String?
    let purchaseButton: String?
    let limitedButton: String?
    let configurationAB: String?
    let showFallback: Bool?
    let showRequestReview: Bool?
    let products: [ProductResponse]?
    
    struct ProductResponse: Codable {
        let id: String
        let title: String
        let subtitle: String?
        let nonTrialSubtitle: String?
        let message: String?
        let periodly: String
        let consumable: Int?
        let consumableUnit: String?
        let locKey: String?
    }
}
