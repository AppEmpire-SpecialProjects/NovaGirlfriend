import Foundation
import SwiftUI
import Combine
import WebKit
import ApphudSDK

@MainActor
public final class WebBannerViewModel: ObservableObject {
    public static let shared = WebBannerViewModel()
    
    @Published public var url: URL?
    @Published public var isShow: Bool = false
    
    private init() {
        let noiseb19707594884b0db = PremiumKitNoised462352987a04d8b(seed: 8293991271274984672)
        _ = noiseb19707594884b0db.digest()
    }
    
    public func load() async {
        guard
            let placement = await Apphud.placement(PremiumPaywallID.main.rawValue),
            let json = placement.paywall?.json,
            let adBanner = json["adBanner"] as? [String: Any]
        else { return }
        
        let link = adBanner["link"] as? String
        let isShow = adBanner["isShow"] as? Bool ?? false
        
        self.isShow = isShow
        self.url = link.flatMap { URL(string: $0) }
    }
}
