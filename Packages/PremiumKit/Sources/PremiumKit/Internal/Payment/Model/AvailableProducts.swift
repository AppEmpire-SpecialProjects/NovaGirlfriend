enum AvailableProducts: String {
    case withTrial
    case noTrial
    case bothProducts
}

extension AvailableProducts {
    func toPublic() -> PremiumAvailableProducts {
        switch self {
        case .withTrial:
            return .withTrial
        case .noTrial:
            return .noTrial
        case .bothProducts:
            return .both
        }
    }
}
