import Foundation

public enum SecondaryPaywallAvailableProducts {
    case single
    case double
    case many

    public init(products: [PremiumProduct]) {
        switch products.count {
        case 0, 1:
            self = .single
        case 2:
            self = .double
        default:
            self = .many
        }
    }
}
