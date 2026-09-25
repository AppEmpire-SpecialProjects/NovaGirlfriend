import Foundation

struct SKConfig: Decodable {
    let nonRenewingSubscriptions: [SKProduct]?
    let nonConsumableProducts: [SKProduct]?
    let subscriptionGroups: [SubscriptionGroup]?

    enum CodingKeys: String, CodingKey {
        case nonRenewingSubscriptions
        case nonConsumableProducts = "products"
        case subscriptionGroups
    }

    static let shared: SKConfig? = {
        guard let url = Bundle.main.url(forResource: nil, withExtension: "storekit"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(SKConfig.self, from: data)
    }()

    struct SubscriptionGroup: Decodable {
        let subscriptions: [SKProduct]
    }

    struct SKProduct: Decodable {
        let productID: String
        let displayPrice: String
        let recurringSubscriptionPeriod: Period?
        let introductoryOffer: IntroductoryOffer?

        struct IntroductoryOffer: Decodable {
            enum PaymentMode: String, Decodable {
                case free
                case payAsYouGo
                case payUpFront
            }

            let paymentMode: PaymentMode
            let subscriptionPeriod: Period
            let numberOfPeriods: Int?
            let displayPrice: String?
        }

        struct Period: Decodable {
            let unit: NSCalendar.Unit
            let numberOfUnits: Int

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let rawValue = try container.decode(String.self)

                guard rawValue.first == "P" else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 period")
                }

                let body = String(rawValue.dropFirst())
                let regex = try NSRegularExpression(pattern: #"^(\d+)([YMWD])$"#)

                guard
                    let match = regex.firstMatch(in: body, range: NSRange(location: 0, length: body.utf16.count)),
                    let numberRange = Range(match.range(at: 1), in: body),
                    let unitRange = Range(match.range(at: 2), in: body),
                    let count = Int(body[numberRange])
                else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid period body: \(body)")
                }

                switch body[unitRange] {
                case "Y": unit = .year
                case "M": unit = .month
                case "W": unit = .weekOfMonth
                case "D": unit = .day
                default: throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported period unit")
                }

                numberOfUnits = count
            }

            var localizedOne: String {
                if unit == .day && numberOfUnits == 7 { return L10n.Period.week }
                switch unit {
                case .weekOfMonth: return L10n.Period.week
                case .month:       return L10n.Period.month
                case .year:        return L10n.Period.year
                case .day:         return L10n.Period.day
                default:           return "period"
                }
            }
        }
    }
}
