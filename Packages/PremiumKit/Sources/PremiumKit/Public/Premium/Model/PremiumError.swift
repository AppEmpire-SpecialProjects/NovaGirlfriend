// Sources/PremiumKit/Public/Errors/PremiumError.swift

import Foundation

public enum PremiumError: Error, LocalizedError {
    case productNotAvailable
    case network
    case cancelled
    case pending
    case verificationFailed
    case purchaseFailed(message: String)
    case restoreNothingToRestore
    case restoreFailed(message: String)
    case paymentNotAllowed
    case paymentInvalid
    case billingIssue
    case notEntitled
    case unknown

    public var errorDescription: String? {
        switch self {
        case .productNotAvailable:
            return L10n.Error.productUnavailable

        case .network:
            return L10n.Error.network

        case .cancelled:
            return L10n.Error.cancelled
            
        case .pending:
            return L10n.Error.pending
            
        case .verificationFailed:
            return L10n.Error.verificationFailed

        case .purchaseFailed(let message):
            return message
            
        case .restoreNothingToRestore:
            return L10n.Error.nothingToRestore
            
        case .restoreFailed(let message):
            return message
            
        case .paymentNotAllowed:
            return L10n.Error.paymentNotAllowed
            
        case .paymentInvalid:
            return L10n.Error.paymentInvalid
            
        case .billingIssue:
            return L10n.Error.billingIssue
            
        case .notEntitled:
            return L10n.Error.notEntitled
            
        case .unknown:
            return L10n.Error.unknown
        }
    }
}
