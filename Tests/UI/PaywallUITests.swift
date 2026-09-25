import StoreKitTest
import UIKit
import XCTest

final class PremiumPurchaseUITests: XCTestCase {
  private let app = XCUIApplication()
  private var storeKit: SKTestSession!

  override func setUpWithError() throws {
    continueAfterFailure = false
    storeKit = try SKTestSession(configurationFileNamed: "Configuration")
    storeKit.resetToDefaultState()
    storeKit.clearTransactions()
    storeKit.disableDialogs = true
    XCUIDevice.shared.orientation = .portrait
    openOnboarding(forceFallback: true)
  }

  private func openOnboarding(forceFallback: Bool) {
    app.launchArguments = ["--uitest-reset-onboarding"]
    if forceFallback { app.launchArguments.append("--premium-force-fallback") }
    app.launch()
    XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 15))
    for number in 1...5 {
      let titles = ["Gets You", "Companion", "Your Feedback", "Special Moments", "Unlimited"]
      XCTAssertTrue(app.staticTexts[titles[number - 1]].waitForExistence(timeout: 5))
      if number < 5 { app.buttons["Continue"].tap() }
    }
    XCTAssertTrue(app.buttons["Continue"].isHittable)
    XCTAssertTrue(app.buttons["Or proceed with limited version"].isHittable)
  }

  override func tearDownWithError() throws {
    if testRun?.hasSucceeded == false {
      let hierarchy = XCTAttachment(string: app.debugDescription)
      hierarchy.lifetime = .keepAlways
      add(hierarchy)
    }
    app.terminate()
    storeKit?.clearTransactions()
    storeKit?.resetToDefaultState()
  }

  private func assertAccess(_ expected: String) {
    let banner = app.buttons["settings.paywallBanner"]
    if expected == "Premium active" {
      // The banner is only shown while there is no active subscription.
      let gone = NSPredicate(format: "exists == false")
      expectation(for: gone, evaluatedWith: banner)
    } else {
      let value = NSPredicate(format: "value == %@", expected)
      expectation(for: value, evaluatedWith: banner)
    }
    waitForExpectations(timeout: 15)
  }

  private func buy(trial: Bool) {
    if trial { app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "trial")).firstMatch.tap() }
    app.buttons["Continue"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 45))
    XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.exists)
    app.tabBars.buttons["Settings"].tap()
    assertAccess("Premium active")
  }

  func testOnboardingTrialPurchaseAndRelaunch() throws {
    buy(trial: true)
    XCTAssertEqual(
      storeKit.allTransactions().last?.productIdentifier, "Nova.Girlfriend.app.WeekTrial")
    app.terminate()
    app.launchArguments = []
    app.launch()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 15))
    app.tabBars.buttons["Settings"].tap()
    assertAccess("Premium active")
  }

  func testOnboardingRegularPurchaseAndExpiration() throws {
    buy(trial: false)
    XCTAssertEqual(storeKit.allTransactions().last?.productIdentifier, "Nova.Girlfriend.app.Week")
    try storeKit.expireSubscription(productIdentifier: "Nova.Girlfriend.app.Week")
    assertAccess("Free access")
  }

  func testPublishedOnboardingRegularPurchase() {
    app.terminate()
    openOnboarding(forceFallback: false)
    buy(trial: false)
    XCTAssertEqual(storeKit.allTransactions().last?.productIdentifier, "Nova.Girlfriend.app.Week")
  }

  func testPublishedOnboardingTrialPurchase() {
    app.terminate()
    openOnboarding(forceFallback: false)
    buy(trial: true)
    XCTAssertEqual(
      storeKit.allTransactions().last?.productIdentifier, "Nova.Girlfriend.app.WeekTrial")
  }

  func testPublishedMainWeeklyPurchase() {
    app.terminate()
    openOnboarding(forceFallback: false)
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 15))
    app.tabBars.buttons["Settings"].tap()
    assertAccess("Free access")
    app.buttons["settings.paywallBanner"].tap()
    let week = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch
    XCTAssertTrue(week.waitForExistence(timeout: 30))
    week.tap()
    XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 45))
    XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.exists)
    assertAccess("Premium active")
    XCTAssertEqual(
      storeKit.allTransactions().last?.productIdentifier, "Nova.Girlfriend.app.WeekTrial")
  }

  func testRestoreActiveStoreKitPurchase() {
    buy(trial: false)
    app.buttons["settings.paywallBanner"].tap()
    XCTAssertTrue(app.buttons["Restore"].waitForExistence(timeout: 15))
    app.buttons["Restore"].tap()
    XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 30))
    XCTAssertFalse(app.buttons["Restore"].exists)
    XCTAssertFalse(app.alerts["Purchases"].exists)
    assertAccess("Premium active")
  }

  func testRefundRemovesAccess() throws {
    buy(trial: false)
    let transaction = try XCTUnwrap(storeKit.allTransactions().last)
    try storeKit.refundTransaction(identifier: transaction.identifier)
    assertAccess("Free access")
  }

  func testMainPaywallOffersRemainSelectable() {
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 15))
    app.tabBars.buttons["Settings"].tap()
    app.buttons["settings.paywallBanner"].tap()
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch.waitForExistence(timeout: 30))
    let trialAvailable = app.staticTexts.matching(
      NSPredicate(format: "label CONTAINS %@", "Try 3 days free")
    ).firstMatch.exists
    XCTAssertTrue(app.buttons[trialAvailable ? "Try free & subscribe" : "Continue"].isEnabled)
    XCTAssertTrue(app.buttons["Terms of Use"].exists)
    XCTAssertTrue(app.buttons["Privacy Policy"].exists)
    XCTAssertTrue(app.buttons["Restore"].exists)
  }

  func testMainCardDoesNotPromiseUsedTrial() {
    buy(trial: true)
    app.buttons["settings.paywallBanner"].tap()
    let week = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch
    XCTAssertTrue(week.waitForExistence(timeout: 30))
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.isEnabled)
    XCTAssertTrue(week.label.hasPrefix("Weekly,"), week.label)
    XCTAssertFalse(week.label.contains("free trial"))
  }

  @MainActor
  func testCancellationKeepsFreeAccess() async throws {
    try await storeKit.setSimulatedError(.generic(.userCancelled), forAPI: .purchase)
    app.buttons["Continue"].tap()
    let cancelled = XCTNSPredicateExpectation(
      predicate: NSPredicate { [self] _, _ in
        storeKit.allTransactions().contains { $0.state == .failed }
      }, object: nil)
    await fulfillment(of: [cancelled], timeout: 45)
    let ready = NSPredicate(format: "enabled == true")
    let finished = XCTNSPredicateExpectation(
      predicate: ready, object: app.buttons["Continue"])
    await fulfillment(of: [finished], timeout: 45)
    XCTAssertFalse(app.alerts["Purchases"].exists)
    XCTAssertFalse(app.tabBars.buttons["Settings"].exists)
    XCTAssertTrue(storeKit.allTransactions().allSatisfy { $0.state == .failed })
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 10))
    app.tabBars.buttons["Settings"].tap()
    assertAccess("Free access")
  }

  @MainActor
  func testUnavailablePurchaseNeverUnlocksPremium() async throws {
    try await storeKit.setSimulatedError(.generic(.unknown), forAPI: .purchase)
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 15))
    app.tabBars.buttons["Settings"].tap()
    assertAccess("Free access")
    app.buttons["settings.paywallBanner"].tap()
    let year = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Yearly")).firstMatch
    XCTAssertTrue(year.waitForExistence(timeout: 30))
    year.tap()
    let alert = app.alerts["Purchases"]
    XCTAssertTrue(alert.waitForExistence(timeout: 45))
    alert.buttons["OK"].tap()
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.isEnabled)
    XCTAssertTrue(year.isSelected)
    XCTAssertTrue(storeKit.allTransactions().allSatisfy { $0.state == .failed })
    app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch.tap()
    assertAccess("Free access")
  }

  func testRestoreWithoutPurchasesDoesNotGrantAccess() {
    app.buttons["Restore"].tap()
    let alert = app.alerts.firstMatch
    XCTAssertTrue(alert.waitForExistence(timeout: 30))
    alert.buttons["OK"].tap()
    XCTAssertFalse(app.tabBars.buttons["Settings"].exists)
    XCTAssertTrue(storeKit.allTransactions().isEmpty)
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 10))
    app.tabBars.buttons["Settings"].tap()
    assertAccess("Free access")
  }

  @MainActor
  func testCatalogFailureRecoversWithRetry() async throws {
    try await storeKit.setSimulatedError(
      .generic(.networkError(URLError(.notConnectedToInternet))), forAPI: .loadProducts)
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 15))
    app.tabBars.buttons["Settings"].tap()
    assertAccess("Free access")
    app.buttons["settings.paywallBanner"].tap()
    let alert = app.alerts["Purchases"]
    XCTAssertTrue(alert.waitForExistence(timeout: 20))
    alert.buttons["OK"].tap()
    XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.isEnabled)
    XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch.exists)
    XCTAssertTrue(app.buttons["Retry"].isHittable)
    XCTAssertTrue(storeKit.allTransactions().isEmpty)

    try await storeKit.setSimulatedError(nil, forAPI: .loadProducts)
    app.buttons["Retry"].tap()
    let week = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch
    XCTAssertTrue(week.waitForExistence(timeout: 20))
    let trial = NSPredicate(format: "label BEGINSWITH %@", "3 days free trial,")
    await fulfillment(of: [XCTNSPredicateExpectation(predicate: trial, object: week)], timeout: 10)
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.isEnabled)
    XCTAssertTrue(week.isSelected)
    XCTAssertFalse(app.buttons["Retry"].exists)
    app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch.tap()
    assertAccess("Free access")
  }

  func testClosingLoadingPaywallCanReopen() {
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 15))
    app.tabBars.buttons["Settings"].tap()
    app.buttons["settings.paywallBanner"].tap()
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch.waitForExistence(timeout: 5))
    app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch.tap()
    app.buttons["settings.paywallBanner"].tap()
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch.waitForExistence(timeout: 20))
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.isEnabled)
    app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch.tap()
    assertAccess("Free access")
  }

  func testAppleConfirmationCanBeCancelled() {
    storeKit.disableDialogs = false
    app.buttons["Continue"].tap()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let sheet = springboard.otherElements["payment-sheet"]
    let appeared = sheet.waitForExistence(timeout: 30)
    for (name, attachment) in [
      ("apple-confirmation", XCTAttachment(screenshot: XCUIScreen.main.screenshot())),
      ("apple-confirmation-system", XCTAttachment(string: springboard.debugDescription)),
      ("apple-confirmation-app", XCTAttachment(string: app.debugDescription)),
    ] {
      attachment.name = name
      attachment.lifetime = .keepAlways
      add(attachment)
    }
    XCTAssertTrue(appeared)
    XCTAssertTrue(sheet.buttons["footer"].isHittable)
    XCTAssertTrue(sheet.buttons["dismiss"].isHittable)
    for key in ["continue", "trial", "limited"] {
      XCTAssertFalse(app.buttons["Continue"].isEnabled)
    }
    XCTAssertFalse(app.tabBars.buttons["Settings"].exists)
    sheet.buttons["dismiss"].tap()
    let ready = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "enabled == true"),
      object: app.buttons["Continue"])
    wait(for: [ready], timeout: 10)
    XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 10))
    for key in ["continue", "trial", "limited"] {
      XCTAssertTrue(app.buttons["Continue"].isEnabled)
    }
    XCTAssertFalse(app.tabBars.buttons["Settings"].exists)
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 10))
    app.tabBars.buttons["Settings"].tap()
    assertAccess("Free access")
  }

  func testPendingDoesNotCompleteOnboardingUntilApproved() throws {
    storeKit.askToBuyEnabled = true
    app.buttons["Continue"].tap()
    let alert = app.alerts["Purchases"]
    XCTAssertTrue(alert.waitForExistence(timeout: 45))
    XCTAssertFalse(app.tabBars.buttons["Settings"].exists)
    XCTAssertTrue(app.buttons["Continue"].exists)
    let transaction = try XCTUnwrap(storeKit.allTransactions().last)
    alert.buttons["OK"].tap()
    try storeKit.approveAskToBuyTransaction(identifier: transaction.identifier)
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 15))
    app.tabBars.buttons["Settings"].tap()
    assertAccess("Premium active")
  }
}

final class OnboardingUITests: XCTestCase {
  private let app = XCUIApplication()

  override func setUpWithError() throws {
    continueAfterFailure = false
    XCUIDevice.shared.orientation = .portrait
    app.launchArguments = ["--uitest-reset-onboarding"]
    app.launch()
    XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 15))
  }

  override func tearDownWithError() throws {
    XCUIDevice.shared.orientation = .portrait
  }

  private func capture(_ name: String) {
    let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private func assertPage(_ number: Int) {
    let titles = ["Gets You", "Companion", "Your Feedback", "Special Moments", "Unlimited"]
    XCTAssertTrue(app.staticTexts[titles[number - 1]].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["Continue"].isHittable)
    XCTAssertTrue(app.buttons["Terms of Use"].isHittable)
    XCTAssertTrue(app.buttons["Privacy Policy"].isHittable)
  }

  func testPagesPortraitLandscapeAndTrial() {
    let isPad = app.frame.width >= 768
    for number in 1...5 {
      assertPage(number)
      capture("onboarding-\(number)-portrait")
      XCUIDevice.shared.orientation = .landscapeLeft
      assertPage(number)
      if isPad {
        XCTAssertGreaterThan(app.frame.width, app.frame.height)
        capture("onboarding-\(number)-landscape")
      } else {
        XCTAssertLessThan(app.frame.width, app.frame.height)
      }
      XCUIDevice.shared.orientation = .portrait
      if number < 5 {
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "trial")).firstMatch.exists)
        app.buttons["Continue"].tap()
      }
    }
    let trial = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "trial")).firstMatch
    XCTAssertEqual(trial.value as? String, "Off")
    trial.tap()
    XCTAssertEqual(trial.value as? String, "On")
    XCTAssertEqual(app.buttons["Continue"].label, "Try free & subscribe")
    XCTAssertTrue(app.staticTexts["Try 3 days free then $4.99/week"].exists)
    capture("onboarding-trial-enabled")
    app.swipeRight()
    assertPage(4)
    app.swipeLeft()
    assertPage(5)
    XCTAssertEqual(trial.value as? String, "On")
    trial.tap()
    XCTAssertEqual(trial.value as? String, "Off")
    XCTAssertEqual(app.buttons["Continue"].label, "Continue")
  }

  func testLegalAndCompletionPersistence() {
    for identifier in ["terms", "privacy"] {
      app.buttons[identifier == "terms" ? "Terms of Use" : identifier == "privacy" ? "Privacy Policy" : "Restore"].tap()
      XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
      capture("onboarding-legal-\(identifier)")
      app.buttons["Done"].tap()
      assertPage(1)
    }
    for number in 1...4 {
      assertPage(number)
      app.buttons["Continue"].tap()
    }
    assertPage(5)
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 10))
    XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch.exists)
    app.terminate()
    app.launchArguments = []
    app.launch()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 10))
    XCTAssertFalse(app.buttons["Continue"].exists)
  }

  private func assertSameFrame(
    _ actual: CGRect, _ expected: CGRect, file: StaticString = #filePath, line: UInt = #line
  ) {
    XCTAssertEqual(actual.minX, expected.minX, accuracy: 1, file: file, line: line)
    XCTAssertEqual(actual.minY, expected.minY, accuracy: 1, file: file, line: line)
    XCTAssertEqual(actual.width, expected.width, accuracy: 1, file: file, line: line)
    XCTAssertEqual(actual.height, expected.height, accuracy: 1, file: file, line: line)
  }
}

final class PaywallUITests: XCTestCase {
  let app = XCUIApplication()

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {
    if let run = testRun, run.failureCount > 0 {
      let hierarchy = XCTAttachment(string: app.debugDescription)
      hierarchy.name = "failure-hierarchy"
      hierarchy.lifetime = .keepAlways
      add(hierarchy)
    }
  }

  private func completeOnboarding() {
    app.launchArguments = ["--uitest-reset-onboarding"]
    app.launch()
    let continueButton = app.buttons["Continue"]
    XCTAssertTrue(continueButton.waitForExistence(timeout: 10))
    for number in 1...4 {
      let titles = ["Gets You", "Companion", "Your Feedback", "Special Moments"]
      XCTAssertTrue(app.staticTexts[titles[number - 1]].waitForExistence(timeout: 5))
      continueButton.tap()
    }
    XCTAssertTrue(
      app.staticTexts
        .matching(NSPredicate(format: "label CONTAINS %@", "Unlimited"))
        .firstMatch.waitForExistence(timeout: 3))
    app.buttons["Or proceed with limited version"].tap()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 10))
    app.tabBars.buttons["Settings"].tap()
    app.buttons["settings.paywallBanner"].tap()
  }

  func testPaywallLayoutsAndLegal() {
    assertPaywallLayoutsAndLegal(forceFallback: false)
  }

  func testLongPressCloseUnlocksOnlyThisSession() {
    completeOnboarding()
    let close = app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch
    XCTAssertTrue(close.waitForExistence(timeout: 10))
    close.press(forDuration: 10.5)
    XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.buttons["settings.paywallBanner"].exists)

    app.terminate()
    app.launchArguments = []
    app.launch()
    XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 15))
    app.tabBars.buttons["Settings"].tap()
    XCTAssertTrue(app.buttons["settings.paywallBanner"].waitForExistence(timeout: 5))
  }

  func testForcedFallbackLayoutsAndLegal() {
    assertPaywallLayoutsAndLegal(forceFallback: true)
  }

  func testForcedFallbackMainPlacement() {
    XCUIDevice.shared.orientation = .portrait
    app.launchArguments = [
      "--premium-force-fallback", "--uitest-show-paywall",
      "--uitest-reset-onboarding",
    ]
    app.launch()
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch.waitForExistence(timeout: 30))
    for key in ["Weekly", "Popular", "Best deal", "Lifetime deal"] {
      let card = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", key)).firstMatch
      XCTAssertTrue(card.waitForExistence(timeout: 5))
      XCTAssertTrue(card.isHittable)
      XCTAssertEqual(card.frame.width, app.frame.width - 32, accuracy: 2)
      XCTAssertEqual(card.frame.height, app.frame.height <= 667 ? 48 : 54, accuracy: 2)
      XCTAssertTrue(app.frame.contains(card.frame))
    }
    let trialAvailable = app.staticTexts.matching(
      NSPredicate(format: "label CONTAINS %@", "Try 3 days free")
    ).firstMatch.exists
    let action = app.buttons[trialAvailable ? "Try free & subscribe" : "Continue"]
    XCTAssertTrue(action.isHittable)
    XCTAssertTrue(app.frame.contains(action.frame))
    XCTAssertTrue(app.buttons["Restore"].isHittable)
    XCTAssertTrue(app.frame.contains(app.buttons["Restore"].frame))
    XCTAssertTrue(app.staticTexts["$4.99/week"].exists)
    let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
    attachment.name = "forced-fallback-main"
    attachment.lifetime = .keepAlways
    add(attachment)
    app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
  }

  private func assertPaywallLayoutsAndLegal(forceFallback: Bool) {
    XCUIDevice.shared.orientation = .portrait
    app.launchArguments = [
      "--uitest-reset-onboarding", "--uitest-show-paywall", "--uitest-paywall-select-only",
    ]
    if forceFallback { app.launchArguments.append("--premium-force-fallback") }
    app.launch()
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.waitForExistence(timeout: 15))
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch.waitForExistence(timeout: 30))
    let isPad = app.frame.width >= 768
    for orientation in [UIDeviceOrientation.portrait, .landscapeLeft] {
      XCUIDevice.shared.orientation = orientation
      XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch.isHittable)
      for key in ["week", "month", "year", "lifetime"] {
        let card = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", key)).firstMatch
        XCTAssertTrue(card.isHittable)
        card.tap()
        XCTAssertTrue(card.isSelected)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.isHittable)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "main-paywall-\(orientation.rawValue)-\(key)"
        shot.lifetime = .keepAlways
        add(shot)
      }
      if isPad && orientation == .landscapeLeft {
        XCTAssertGreaterThan(app.frame.width, app.frame.height)
      } else {
        XCTAssertLessThan(app.frame.width, app.frame.height)
      }
    }
    for key in ["terms", "privacy"] {
      app.buttons["paywall.\(key)"].tap()
      XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
      app.buttons["Done"].tap()
      XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Lifetime")).firstMatch.isSelected)
    }
    XCUIDevice.shared.orientation = .portrait
  }

  func testLandscapeDisclosureRemainsReadable() throws {
    XCUIDevice.shared.orientation = .landscapeLeft
    defer { XCUIDevice.shared.orientation = .portrait }
    app.launchArguments = [
      "--uitest-show-paywall", "--uitest-paywall-select-only", "-preferences.hasSeenPaywall", "NO",
    ]
    app.launch()
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.waitForExistence(timeout: 10))
    try XCTSkipUnless(app.frame.width >= 768, "Landscape paywall is supported on iPad only.")
    XCTAssertGreaterThan(app.frame.width, app.frame.height)
    for key in ["week", "lifetime"] {
      app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", key)).firstMatch.tap()
      let disclosure = app.staticTexts["paywall.disclosure"]
      let title = app.staticTexts["Unlimited access!"]
      XCTAssertTrue(app.frame.contains(disclosure.frame))
      XCTAssertLessThan(disclosure.frame.maxY, title.frame.minY)
      let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
      shot.name = "landscape-disclosure-\(key)"
      shot.lifetime = .keepAlways
      add(shot)
    }
  }

  func testPaywallMatchesDesignAndCloses() {
    completeOnboarding()
    XCTAssertTrue(app.staticTexts["Unlimited access!"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch.waitForExistence(timeout: 30))
    let disclosure = app.staticTexts["paywall.disclosure"]
    let trialText = NSPredicate(format: "label == %@", "Try 3 days free then $4.99/week")
    expectation(for: trialText, evaluatedWith: disclosure)
    waitForExpectations(timeout: 10)
    XCTAssertFalse(disclosure.label.isEmpty)
    XCTAssertTrue(app.buttons["Try free & subscribe"].isHittable)

    for key in ["week", "month", "year", "lifetime"] {
      XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", key)).firstMatch.exists, "Missing card \(key)")
    }
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch.isSelected)
    XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Yearly")).firstMatch.isSelected)
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Subscribe")).firstMatch.isHittable)

    let close = app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch
    XCTAssertTrue(close.waitForExistence(timeout: 5))
    XCTAssertTrue(close.isHittable)
    close.tap()
    XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
  }

}
