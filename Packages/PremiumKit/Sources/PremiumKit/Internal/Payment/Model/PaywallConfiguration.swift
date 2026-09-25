public struct PaywallConfiguration: Hashable, Sendable {
    public let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }
    
    public static let variant1 = PaywallConfiguration("variant1")
    public static let variant2 = PaywallConfiguration("variant2")
    public static let variant3 = PaywallConfiguration("variant3")
    public static let variant4 = PaywallConfiguration("variant4")
}
