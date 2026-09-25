public struct PremiumPaywallID: Hashable, Sendable {
    public let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }
    
    public static let onboarding = PremiumPaywallID(PremiumKitTableb526942dc56d98e0.placement(0))
    public static let main = PremiumPaywallID(PremiumKitTableb526942dc56d98e0.placement(1))
    public static let consumable = PremiumPaywallID(PremiumKitTableb526942dc56d98e0.placement(2))
    public static let banner = PremiumPaywallID(PremiumKitTableb526942dc56d98e0.placement(3))
    
    public var isAvailablePaywall: Bool {
        self == .main || self == .onboarding
    }
}
