import StoreKit

extension SKProductSubscriptionPeriod {
    var period: String {
        if numberOfUnits == 7 {
            L10n.Period.week
        } else {
            switch unit {
            case .week: L10n.Period.week
            case .month: L10n.Period.month
            case .year: L10n.Period.year
            case .day: L10n.Period.day
            @unknown default: "-4"
            }
        }
    }
    
    func pricePerWeek(_ price: NSDecimalNumber) -> NSDecimalNumber {
        if numberOfUnits == 7 {
            price
        } else {
            switch unit {
            case .week: price
            case .day: price.multiplying(by: NSDecimalNumber(value: 7))
            case .month: price.dividing(by: NSDecimalNumber(value: 4))
            case .year: price.dividing(by: NSDecimalNumber(value: 52))
            @unknown default: price
            }
        }
    }
}
