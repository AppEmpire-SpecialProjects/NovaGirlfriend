import UIKit
import XCTest

final class NativeSettingsUITests: XCTestCase {
  private let app = XCUIApplication()

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  private func openSettings(largeText: Bool = false) {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    if largeText {
      app.launchArguments += [
        "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL",
      ]
    }
    app.launch()
    app.tabBars.buttons["Settings"].tap()
    XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
    let title = app.navigationBars["Settings"].staticTexts["nova.navigationTitle"]
    XCTAssertTrue(title.waitForExistence(timeout: 5))
    XCTAssertEqual(title.label, "Settings")
    XCTAssertTrue(title.isHittable)
  }

  private func open(_ label: String) {
    let row = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", label)).firstMatch
    for _ in 0..<6 where !row.isHittable { app.swipeUp() }
    XCTAssertTrue(row.isHittable)
    row.tap()
  }

  /// Taps a switch and waits for its accessibility value to flip. Form
  /// toggles on iOS 26 expose a row-level element whose center tap does not
  /// actuate the control, so the tap targets the trailing edge where the
  /// switch renders. The value updates asynchronously once the toggle
  /// animation finishes, so the changed value is polled instead of read once.
  @discardableResult
  private func flip(_ toggle: XCUIElement) -> String {
    let before = toggle.value as? String ?? ""
    toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
    let deadline = Date().addingTimeInterval(5)
    var after = toggle.value as? String ?? ""
    while after == before && Date() < deadline {
      Thread.sleep(forTimeInterval: 0.1)
      after = toggle.value as? String ?? ""
    }
    XCTAssertNotEqual(after, before, "Switch value should change after tap")
    return after
  }

  func testPaywallBannerOpensAndReturnsToSettings() {
    XCUIDevice.shared.orientation = .portrait
    defer { XCUIDevice.shared.orientation = .portrait }
    app.launchArguments = [
      "-preferences.hasCompletedOnboarding", "YES",
      "-preferences.hasSeenPaywall", "YES",
    ]
    app.launch()
    let settings = app.buttons.matching(NSPredicate(format: "label == %@", "Settings")).firstMatch
    XCTAssertTrue(settings.waitForExistence(timeout: 10))
    settings.tap()
    let banner = app.buttons["settings.paywallBanner"]
    XCTAssertTrue(banner.waitForExistence(timeout: 5))
    let isPad = app.frame.width >= 768
    let orientations: [UIDeviceOrientation] = isPad ? [.portrait, .landscapeLeft] : [.portrait]
    for orientation in orientations {
      XCUIDevice.shared.orientation = orientation
      XCTAssertTrue(banner.isHittable)
      XCTAssertTrue(app.frame.contains(banner.frame))
      XCTAssertGreaterThan(banner.frame.height, 90)
      let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
      shot.name = "settings-banner-\(orientation.rawValue)"
      shot.lifetime = .keepAlways
      add(shot)
      banner.tap()
      let close = app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch
      XCTAssertTrue(close.waitForExistence(timeout: 5))
      XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Weekly")).firstMatch.exists)
      XCTAssertTrue(app.buttons["Continue"].isHittable)
      close.tap()
      XCTAssertTrue(banner.waitForExistence(timeout: 5))
      XCTAssertTrue(banner.isHittable)
      XCTAssertTrue(app.navigationBars["Settings"].exists)
    }
  }

  func testPreferencesPersistAcrossRelaunch() {
    openSettings()
    open("Experience")
    let haptics = app.switches["Haptics"]
    let motion = app.switches["Reduce motion"]
    XCTAssertTrue(haptics.waitForExistence(timeout: 5))
    let oldHaptics = haptics.value as? String ?? ""
    let oldMotion = motion.value as? String ?? ""
    let newHaptics = flip(haptics)
    let newMotion = flip(motion)

    app.terminate()
    openSettings()
    open("Experience")
    XCTAssertTrue(haptics.waitForExistence(timeout: 5))
    XCTAssertEqual(haptics.value as? String, newHaptics)
    XCTAssertEqual(motion.value as? String, newMotion)
    XCTAssertEqual(flip(haptics), oldHaptics)
    XCTAssertEqual(flip(motion), oldMotion)
    app.navigationBars.buttons.firstMatch.tap()

    open("Voice Settings")
    let playback = app.switches["Read responses aloud"]
    XCTAssertTrue(playback.waitForExistence(timeout: 5))
    let oldPlayback = playback.value as? String ?? ""
    let newPlayback = flip(playback)
    app.terminate()
    openSettings()
    open("Voice Settings")
    XCTAssertTrue(playback.waitForExistence(timeout: 5))
    XCTAssertEqual(playback.value as? String, newPlayback)
    XCTAssertEqual(flip(playback), oldPlayback)
    open("System voice")
    XCTAssertTrue(app.buttons["Default"].waitForExistence(timeout: 5))
    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Voice Settings"].exists)
  }

  func testNativeSettingsDestinationsAtLargeText() {
    openSettings(largeText: true)
    for (label, title) in [
      ("My Companions", "My Companions"),
      ("Conversation History", "Conversations"),
      ("Export Data", "Export Data"),
      ("Voice Settings", "Voice Settings"),
      ("Experience", "Experience"),
    ] {
      open(label)
      XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5))
      let heading = app.navigationBars[title].staticTexts["nova.navigationTitle"]
      XCTAssertTrue(heading.waitForExistence(timeout: 5))
      XCTAssertEqual(heading.label, title)
      XCTAssertTrue(heading.isHittable)
      XCTAssertFalse(app.tabBars.buttons["Settings"].isHittable)
      if label == "Export Data" {
        XCTAssertTrue(app.buttons["Share JSON Export"].exists)
      }
      let screenshot = XCTAttachment(screenshot: app.screenshot())
      screenshot.name = "native-settings-\(title)"
      screenshot.lifetime = .keepAlways
      add(screenshot)
      app.navigationBars.buttons.firstMatch.tap()
      XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
    }
    for title in ["Privacy Policy", "Terms of Use"] {
      open(title)
      XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5))
      app.buttons["Done"].tap()
      XCTAssertTrue(app.navigationBars[title].waitForNonExistence(timeout: 5))
    }
    app.tabBars.buttons["Discover"].tap()
    XCTAssertTrue(app.navigationBars["Discover"].exists)
    app.tabBars.buttons["Settings"].tap()
    XCTAssertTrue(app.navigationBars["Settings"].exists)
  }
}
