// Sources/PremiumKit/Public/Models/PremiumProduct.swift

import Foundation

public struct PremiumProduct: Identifiable, Hashable, Sendable {

    public let id: String
    public let title: String
    public let subtitle: String?
    public let nonTrialSubtitle: String?
    public let message: String?
    public let period: String
    public let pricePerPeriod: String
    public let pricePerWeek: String
    public let hasTrial: Bool
    public let isLifetime: Bool
    public let consumable: Int?
    public let consumableUnit: String?
    public let trialDuration: String?
    public let subscriptionDuration: String?

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        nonTrialSubtitle: String? = nil,
        message: String? = nil,
        period: String,
        pricePerPeriod: String,
        pricePerWeek: String,
        hasTrial: Bool,
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
        self.period = period
        self.pricePerPeriod = pricePerPeriod
        self.pricePerWeek = pricePerWeek
        self.hasTrial = hasTrial
        self.isLifetime = isLifetime
        self.consumable = consumable
        self.consumableUnit = consumableUnit
        self.trialDuration = trialDuration
        self.subscriptionDuration = subscriptionDuration
    }
    
    public var paywallSubtitle: String {
        let base = hasTrial ? subtitle ?? "" : nonTrialSubtitle ?? ""
        if base.isEmpty {
            return pricePerPeriod
        }
        if base.contains("%@") {
            ///Для триала вторым аргументом идёт длительность триала, а не период подписки
            let second = hasTrial ? (trialDuration ?? period) : period
            return String(format: base, pricePerPeriod, second)
        }
        return "\(base) \(pricePerPeriod)"
    }
    
    public var pickerDuration: String {
        if hasTrial {
            return trialDuration ?? period
        }
        return subscriptionDuration ?? period
    }
    
    public var consumableSubtitle: String? {
        guard let consumable, let consumableUnit else { return nil }
        let msg = (message ?? "").isEmpty ? "" : "\(message!) + "
        return "\(msg)\(consumable) \(consumableUnit)/\(period.lowercased())"
    }
}
