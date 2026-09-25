// Sources/PremiumKit/PremiumAppDelegate.swift

import UIKit

open class PremiumAppDelegate: NSObject, UIApplicationDelegate {

    public override init() {
        super.init()
    }

    open func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Premium.shared.startIfNeeded()
        ReviewRequestScheduler.registerLaunch()
        Task {
            await WebBannerViewModel.shared.load()
        }
        return true
    }

    open func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Premium.shared.submitPushToken(deviceToken)
    }
}
