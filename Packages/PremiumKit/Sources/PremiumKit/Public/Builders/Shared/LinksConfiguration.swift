import SwiftUI

public enum LinkType: Sendable, Equatable {
    case terms
    case privacy
    case restore
}

public struct LinksConfiguration: Sendable {
    public let termsTitle: String
    public let privacyTitle: String
    public let restoreTitle: String
    public let order: [LinkType]
    
    public init(
        termsTitle: String,
        privacyTitle: String,
        restoreTitle: String,
        order: [LinkType] = [.terms, .privacy, .restore]
    ) {
        self.termsTitle = termsTitle
        self.privacyTitle = privacyTitle
        self.restoreTitle = restoreTitle
        self.order = order
    }
    
    public static var `default`: LinksConfiguration {
        LinksConfiguration(
            termsTitle: L10n.Links.terms,
            privacyTitle: L10n.Links.privacy,
            restoreTitle: L10n.Links.restore
        )
    }
}
