import ApphudSDK
import Foundation

extension ApphudPaywall {
    var shouldShowFallback: Bool {
        guard let json,
              let data = try? JSONSerialization.data(withJSONObject: json),
              let directive = try? JSONDecoder().decode(FallbackDirective.self, from: data)
        else { return false }
        return directive.showFallback == true
    }

    var paywallResponse: ApphudPaywallResponse? {
        guard let json else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
        guard let response = try? JSONDecoder().decode(ApphudPaywallResponse.self, from: data) else { return nil }
        return response
    }
}

private struct FallbackDirective: Decodable {
    let showFallback: Bool?
}
