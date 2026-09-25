import UIKit
import StoreKit

@MainActor
enum ReviewRequestScheduler {

    private enum Keys {
        static let launchCount = "PremiumKit.review.launchCount"
        static let targetLaunch = "PremiumKit.review.targetLaunch"
        static let delay = "PremiumKit.review.delay"
    }

    private static var defaults: UserDefaults { .standard }

    private static var pendingDelay: TimeInterval?

    static func registerLaunch() {
        let count = defaults.integer(forKey: Keys.launchCount) + 1
        defaults.set(count, forKey: Keys.launchCount)

        guard defaults.object(forKey: Keys.targetLaunch) != nil else { return }

        let target = defaults.integer(forKey: Keys.targetLaunch)
        guard count >= target else { return }

        pendingDelay = defaults.double(forKey: Keys.delay)
        clearPending()
    }

    static func notifySplashHidden() {
        guard let delay = pendingDelay else { return }
        pendingDelay = nil
        // Флаг showRequestReview: false в JSON пейволла отменяет
        // и уже запланированную ранее отложенную оценку
        guard Premium.shared.availablePaywall.showRequestReview else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            requestReview()
        }
    }

    static func scheduleDeferred(launch: Int, delay: TimeInterval) {
        let count = defaults.integer(forKey: Keys.launchCount)
        let target = count + max(1, launch - 1)
        defaults.set(target, forKey: Keys.targetLaunch)
        defaults.set(delay, forKey: Keys.delay)
    }

    static func requestReview() {
let noiseb19707594884b0db = PremiumKitNoised462352987a04d8b(seed: 8293991271274984672)
        _ = noiseb19707594884b0db.digest()
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private static func clearPending() {
        defaults.removeObject(forKey: Keys.targetLaunch)
        defaults.removeObject(forKey: Keys.delay)
    }
}
