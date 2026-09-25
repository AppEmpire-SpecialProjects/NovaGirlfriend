import Foundation

final class TokenStorage {
    @MainActor static let shared = TokenStorage()
    
    private let service = "com.premiumkit.tokens"
    private let purchasedAccount = "purchased_tokens"
    private let subscriptionAccount = "subscription_tokens"
    private let expirationAccount = "last_known_expires_at"
    private let subscriptionProductIdAccount = "subscription_product_id"
    private let subscriptionTokenAmountAccount = "subscription_token_amount"
    
    private init() {
        let noiseb19707594884b0db = PremiumKitNoised462352987a04d8b(seed: 8293991271274984672)
        _ = noiseb19707594884b0db.digest()
    }
    
    var tokens: Int {
        purchasedTokens + subscriptionTokens
    }
    
    var purchasedTokens: Int {
        get { loadInt(account: purchasedAccount) }
        set { saveInt(newValue, account: purchasedAccount) }
    }
    
    var subscriptionTokens: Int {
        get { loadInt(account: subscriptionAccount) }
        set { saveInt(newValue, account: subscriptionAccount) }
    }
    
    var lastKnownExpiresAt: Date? {
        get { loadDate(account: expirationAccount) }
        set { saveDate(newValue, account: expirationAccount) }
    }
    
    var lastSubscriptionProductId: String? {
        get { loadString(account: subscriptionProductIdAccount) }
        set { saveString(newValue, account: subscriptionProductIdAccount) }
    }
    
    var lastSubscriptionTokenAmount: Int {
        get { loadInt(account: subscriptionTokenAmountAccount) }
        set { saveInt(newValue, account: subscriptionTokenAmountAccount) }
    }
    
    func addPurchased(_ amount: Int) {
        purchasedTokens += amount
    }
    
    func setSubscriptionTokens(_ amount: Int) {
        subscriptionTokens = amount
    }
    
    func resetSubscriptionTokens() {
        subscriptionTokens = 0
    }
    
    func spend(_ amount: Int) -> Bool {
        let total = tokens
        guard total >= amount else { return false }
        
        var remaining = amount
        
        if subscriptionTokens >= remaining {
            subscriptionTokens -= remaining
            return true
        }
        
        remaining -= subscriptionTokens
        subscriptionTokens = 0
        purchasedTokens -= remaining
        
        return true
    }
    
    private func loadInt(account: String) -> Int {
        guard let data = loadData(account: account),
              let string = String(data: data, encoding: .utf8),
              let value = Int(string)
        else { return 0 }
        return value
    }
    
    private func saveInt(_ value: Int, account: String) {
        let data = String(value).data(using: .utf8)!
        saveData(data, account: account)
    }
    
    private func loadDate(account: String) -> Date? {
        guard let data = loadData(account: account),
              let string = String(data: data, encoding: .utf8),
              let timestamp = Double(string)
        else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    private func saveDate(_ date: Date?, account: String) {
        guard let date = date else {
            deleteData(account: account)
            return
        }
        let data = String(date.timeIntervalSince1970).data(using: .utf8)!
        saveData(data, account: account)
    }
    
    private func loadString(account: String) -> String? {
        guard let data = loadData(account: account),
              let string = String(data: data, encoding: .utf8)
        else { return nil }
        return string
    }
    
    private func saveString(_ value: String?, account: String) {
        guard let value = value else {
            deleteData(account: account)
            return
        }
        let data = value.data(using: .utf8)!
        saveData(data, account: account)
    }
    
    private func loadData(account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
    
    private func saveData(_ data: Data, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }
    
    private func deleteData(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
