import StoreKit

enum PaymentError: Error {
    case productNotAvailable
    case network
    case cancelled
    case pending
    case verificationFailed
    case purchaseFailed(String)
    case restoreNothingToRestore
    case restoreFailed(String)
    case paymentNotAllowed
    case paymentInvalid
    case billingIssue
    case notEntitled
    case unknown
}

extension PaymentError {

    func toPublic() -> PremiumError {
        switch self {
        case .productNotAvailable:
            return .productNotAvailable
        case .network:
            return .network
        case .cancelled:
            return .cancelled
        case .pending:
            return .pending
        case .verificationFailed:
            return .verificationFailed
        case .purchaseFailed(let message):
            return .purchaseFailed(message: message)
        case .restoreNothingToRestore:
            return .restoreNothingToRestore
        case .restoreFailed(let message):
            return .restoreFailed(message: message)
        case .paymentNotAllowed:
            return .paymentNotAllowed
        case .paymentInvalid:
            return .paymentInvalid
        case .billingIssue:
            return .billingIssue
        case .notEntitled:
            return .notEntitled
        case .unknown:
            return .unknown
        }
    }
    
    static func from(_ error: Error) -> PaymentError {
        if let skError = error as? SKError {
            return fromSKError(skError)
        }
        
        if let storeKitError = error as? StoreKitError {
            return fromStoreKitError(storeKitError)
        }
        
        if let purchaseError = error as? Product.PurchaseError {
            return fromPurchaseError(purchaseError)
        }
        
        let nsError = error as NSError
        
        if nsError.domain == SKErrorDomain,
           let code = SKError.Code(rawValue: nsError.code) {
            return fromSKErrorCode(code)
        }
        
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
            return from(underlying)
        }
        
        return .purchaseFailed(error.localizedDescription)
    }
    
    private static func fromSKError(_ error: SKError) -> PaymentError {
        fromSKErrorCode(error.code)
    }
    
    private static func fromSKErrorCode(_ code: SKError.Code) -> PaymentError {
        switch code {
        case .paymentCancelled:
            return .cancelled
        case .paymentNotAllowed:
            return .paymentNotAllowed
        case .paymentInvalid:
            return .paymentInvalid
        case .storeProductNotAvailable:
            return .productNotAvailable
        case .cloudServiceNetworkConnectionFailed, .cloudServiceRevoked:
            return .network
        case .clientInvalid:
            return .notEntitled
        default:
            return .unknown
        }
    }
    
    private static func fromStoreKitError(_ error: StoreKitError) -> PaymentError {
        switch error {
        case .networkError:
            return .network
        case .userCancelled:
            return .cancelled
        case .notAvailableInStorefront, .notEntitled:
            return .notEntitled
        default:
            return .unknown
        }
    }
    
    private static func fromPurchaseError(_ error: Product.PurchaseError) -> PaymentError {
        switch error {
        case .productUnavailable:
            return .productNotAvailable
        case .purchaseNotAllowed:
            return .paymentNotAllowed
        case .ineligibleForOffer:
            return .notEntitled
        case .invalidOfferIdentifier, .invalidOfferSignature, .invalidOfferPrice:
            return .paymentInvalid
        default:
            return .unknown
        }
    }
}
