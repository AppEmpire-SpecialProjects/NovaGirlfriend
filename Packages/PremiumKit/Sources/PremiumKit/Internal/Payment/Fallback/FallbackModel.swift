struct FallbackFile: Decodable {
    struct Result: Decodable {
        let name: String
        let json: String
    }
    struct DataBlock: Decodable {
        let results: [Result]
    }
    let data: DataBlock
}

struct FallbackPaywall: Decodable {
    let title: String
    let limitedButton: String?
    let tryFreeButton: String?
    let continueButton: String?
    let purchaseButton: String?
    let configurationAB: String?
    let showRequestReview: Bool?
    let products: [FallbackProduct]
}

struct FallbackProduct: Decodable {
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
