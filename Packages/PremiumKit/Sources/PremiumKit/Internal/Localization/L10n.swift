import Foundation

public enum L10n {
    static var supportedLanguages: [PremiumLanguage] = [.en]
    static var defaultLanguage: PremiumLanguage = .en
    
    private static var preferredLanguage: String {
        let supported = supportedLanguages.map { $0.rawValue }
        
        for lang in Locale.preferredLanguages {
            let code = Locale(identifier: lang).language.languageCode?.identifier ?? lang
            if supported.contains(code) {
                return code
            }
            let short = String(lang.prefix(2))
            if supported.contains(short) {
                return short
            }
        }
        return defaultLanguage.rawValue
    }
    
    private static var localizedBundle: Bundle {
        guard let path = Bundle.module.path(forResource: preferredLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.module
        }
        return bundle
    }
    
    public static func localized(_ key: String) -> String {
        let result = NSLocalizedString(key, tableName: "Localizable", bundle: localizedBundle, value: key, comment: "")
        
        ///Ключ не найден в бандле PremiumKit — ищем в бандле приложения
        if result == key {
            return NSLocalizedString(key, bundle: .main, value: key, comment: "")
        }
        
        return result
    }
    
    public static func localized(_ key: String, _ args: CVarArg...) -> String {
        String(format: localized(key), arguments: args)
    }
    
    public static func localizedOrNil(_ key: String?) -> String? {
        guard let key else { return nil }
        let result = localized(key)
        return result == key ? nil : result
    }
    
    public static func resolve(_ value: String) -> String {
        value.isEmpty ? "" : localized(value)
    }
    
    public static func resolveOptional(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return localized(value)
    }
    
    public enum Period {
        public static var week: String { localized("period.week") }
        public static var month: String { localized("period.month") }
        public static var year: String { localized("period.year") }
        public static var day: String { localized("period.day") }
        public static var oneTime: String { localized("period.one_time") }
    }
    
    public enum Price {
        public static func perWeek(_ price: String) -> String {
            localized("price.per_week_format", price)
        }
        public static var limitedOffer: String { localized("main.lifetime.periodly") }
    }
    
    public enum Button {
        public static var tryFree: String { localized("button.try_free") }
        public static var `continue`: String { localized("button.continue") }
        public static var purchase: String { localized("button.purchase") }
        public static var limited: String { localized("button.limited") }
        public static var next: String { localized("button.next") }
    }
    
    public enum Error {
        public static var productUnavailable: String { localized("error.product_unavailable") }
        public static var network: String { localized("error.network") }
        public static var cancelled: String { localized("error.cancelled") }
        public static var pending: String { localized("error.pending") }
        public static var verificationFailed: String { localized("error.verification_failed") }
        public static var nothingToRestore: String { localized("error.nothing_to_restore") }
        public static var paymentNotAllowed: String { localized("error.payment_not_allowed") }
        public static var paymentInvalid: String { localized("error.payment_invalid") }
        public static var billingIssue: String { localized("error.billing_issue") }
        public static var notEntitled: String { localized("error.not_entitled") }
        public static var unknown: String { localized("error.unknown") }
    }
    
    public enum Alert {
        public static var cancel: String { localized("alert.cancel") }
        public static var retry: String { localized("alert.retry") }
        public static var retryMessage: String { localized("alert.retry_message") }
        public static var error: String { localized("alert.error") }
        public static var trialExpiredTitle: String { localized("alert.trial_expired.title") }
        public static var trialExpiredMessage: String { localized("alert.trial_expired.message") }
    }
    
    public enum Product {
        public static var trialTitle: String { localized("product.trial_title") }
        public static var nonTrialSubtitle: String { localized("product.non_trial_subtitle") }
        
        public static func title(for locKey: String) -> String {
            localized("\(locKey).title")
        }
        
        public static func subtitle(for locKey: String) -> String {
            localized("\(locKey).subtitle")
        }
        
        public static func message(for locKey: String) -> String {
            localized("\(locKey).message")
        }
        
        public static func periodly(for locKey: String) -> String {
            localized("\(locKey).periodly")
        }
    }
    
    public enum Links {
        public static var terms: String { localized("links.terms") }
        public static var privacy: String { localized("links.privacy") }
        public static var restore: String { localized("links.restore") }
    }
}
