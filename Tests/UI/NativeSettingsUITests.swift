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

  func testPreferencesPersistAcrossRelaunch() {
    openSettings()
    XCTAssertFalse(app.staticTexts["Your Nova"].exists)
    open("Experience")
    let haptics = app.switches["Haptics"]
    let motion = app.switches["Reduce motion"]
    XCTAssertTrue(haptics.waitForExistence(timeout: 5))
    let oldHaptics = haptics.value as? String
    let oldMotion = motion.value as? String
    haptics.tap()
    motion.tap()
    let newHaptics = haptics.value as? String
    let newMotion = motion.value as? String
    XCTAssertNotEqual(newHaptics, oldHaptics)
    XCTAssertNotEqual(newMotion, oldMotion)

    app.terminate()
    openSettings()
    open("Experience")
    XCTAssertTrue(haptics.waitForExistence(timeout: 5))
    XCTAssertEqual(haptics.value as? String, newHaptics)
    XCTAssertEqual(motion.value as? String, newMotion)
    haptics.tap()
    motion.tap()
    XCTAssertEqual(haptics.value as? String, oldHaptics)
    XCTAssertEqual(motion.value as? String, oldMotion)
    app.navigationBars.buttons.firstMatch.tap()

    open("Voice Settings")
    let playback = app.switches["Read responses aloud"]
    XCTAssertTrue(playback.waitForExistence(timeout: 5))
    let oldPlayback = playback.value as? String
    playback.tap()
    let newPlayback = playback.value as? String
    XCTAssertNotEqual(newPlayback, oldPlayback)
    app.terminate()
    openSettings()
    open("Voice Settings")
    XCTAssertTrue(playback.waitForExistence(timeout: 5))
    XCTAssertEqual(playback.value as? String, newPlayback)
    playback.tap()
    XCTAssertEqual(playback.value as? String, oldPlayback)
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
      ("About Nova", "About"),
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
