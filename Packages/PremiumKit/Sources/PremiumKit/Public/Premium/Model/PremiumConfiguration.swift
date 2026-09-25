import Foundation

public enum PremiumLanguage: String, CaseIterable {
    case en
    case ru
    case ar
    case nl
    case fr
    case de
    case it
    case ja
    case pt
    case zhHans = "zh-Hans"
    case es
    case vi
    case id
    case pl
    case hr
    case ms
    case he
    case bg
    case uk
    case sl
    case ro
    case sk
    case tr
    case hu
    case sv
    case el
    case ca
    case th
    case cs
    case ko
}

public struct PremiumConfiguration {

    let apiKey: String
    let userID: String?
    let supportedLanguages: [PremiumLanguage]
    let defaultLanguage: PremiumLanguage
    let shouldLogout: Bool
    let forceFallback: Bool
    let fallbackFileName: String

    public init(
        apiKey: String,
        userID: String? = nil,
        supportedLanguages: [PremiumLanguage] = [.en],
        defaultLanguage: PremiumLanguage = .en,
        shouldLogout: Bool = false,
        forceFallback: Bool = false,
        fallbackFileName: String = "apphud_paywalls_fallback"
    ) {
        self.apiKey = apiKey
        self.userID = userID
        self.supportedLanguages = supportedLanguages
        self.defaultLanguage = defaultLanguage
        self.shouldLogout = shouldLogout
        self.forceFallback = forceFallback
        self.fallbackFileName = fallbackFileName
    }
}
