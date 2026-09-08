import UIKit
import XCTest

final class GalleryUITests: XCTestCase {
  private let app = XCUIApplication()

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {
    if let run = testRun, run.failureCount > 0 {
      capture("gallery-failure")
      let hierarchy = XCTAttachment(string: app.debugDescription)
      hierarchy.lifetime = .keepAlways
      add(hierarchy)
    }
  }

  private func capture(_ name: String) {
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private func launchGallery(largeText: Bool = false) {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    if largeText {
      app.launchArguments += [
        "-preferences.reduceMotion", "YES",
        "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL",
      ]
    }
    app.launch()
    app.tabBars.buttons["Gallery"].tap()
    XCTAssertTrue(app.navigationBars["Gallery"].waitForExistence(timeout: 8))
  }

  private func moment(_ character: Int = 1, _ number: Int = 1) -> XCUIElement {
    app.buttons["gallery.moment.D1000000-0000-0000-000\(character)-00000000000\(number)"]
  }

  private func reveal(_ element: XCUIElement) {
    for _ in 0..<6 where !element.isHittable { app.swipeUp() }
    XCTAssertTrue(element.isHittable)
  }

  private func chooseFilter(_ title: String) {
    let chip = app.buttons["gallery.filter.\(title)"]
    let filters = app.scrollViews["gallery.filters"]
    for _ in 0..<4 where !filters.isHittable { app.swipeDown() }
    for _ in 0..<4 where !filters.frame.contains(chip.frame) {
      if chip.frame.minX < filters.frame.minX {
        filters.swipeRight()
      } else {
        filters.swipeLeft()
      }
    }
    XCTAssertTrue(chip.isHittable)
    chip.tap()
  }

  private func chooseCompanion(_ index: Int) {
    let companion = app.buttons["gallery.companion.A1000000-0000-0000-0000-00000000000\(index)"]
    let selector = app.scrollViews["gallery.companions"]
    for _ in 0..<4 where !selector.isHittable { app.swipeDown() }
    for _ in 0..<8 where !selector.frame.contains(companion.frame) {
      selector.swipeLeft()
    }
    XCTAssertTrue(companion.isHittable)
    companion.tap()
  }

  func testCollectionViewerSavingAndReturn() {
    launchGallery()
    XCTAssertTrue(app.staticTexts["Choose Companion"].exists)
    XCTAssertFalse(app.staticTexts["No Saved Moments"].exists)
    XCTAssertFalse(app.staticTexts["No saved moments yet"].exists)
    XCTAssertTrue(moment().waitForExistence(timeout: 5))
    XCTAssertTrue(moment(1, 2).exists)
    XCTAssertLessThan(moment().frame.minX, moment(1, 2).frame.minX)
    capture("gallery-collection")
    moment().tap()
    XCTAssertTrue(app.images["gallery.viewer.image"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.tabBars.buttons["Gallery"].isHittable)
    let save = app.buttons["gallery.viewer.save"]
    if save.label == "Unsave Moment" { save.tap() }
    XCTAssertEqual(save.label, "Save Moment")
    save.tap()
    XCTAssertEqual(save.label, "Unsave Moment")
    capture("gallery-viewer-saved")
    app.buttons["gallery.viewer.share"].tap()
    XCTAssertTrue(app.cells["Copy"].waitForExistence(timeout: 8))
    capture("gallery-image-share")
    app.cells["Copy"].tap()
    XCTAssertTrue(app.buttons["gallery.viewer.close"].waitForExistence(timeout: 5))
    app.buttons["gallery.viewer.close"].tap()
    chooseFilter("Saved")
    XCTAssertTrue(moment().waitForExistence(timeout: 5))
    app.terminate()
    launchGallery()
    chooseFilter("Saved")
    XCTAssertTrue(moment().waitForExistence(timeout: 5))
    moment().tap()
    XCTAssertEqual(app.buttons["gallery.viewer.save"].label, "Unsave Moment")
    app.buttons["gallery.viewer.save"].tap()
    app.buttons["gallery.viewer.close"].tap()
    XCTAssertTrue(app.staticTexts["No Saved Moments"].waitForExistence(timeout: 5))
    XCTAssertTrue(
      app.staticTexts["Save your favorite companion moments and they’ll appear here."].isHittable)
    XCTAssertFalse(app.staticTexts["Save your favorite moments to find them here."].exists)
    capture("gallery-saved-empty")
    chooseFilter("All")
    chooseCompanion(2)
    XCTAssertEqual(app.staticTexts["gallery.collectionTitle"].label, "Zephyra’s Moments")
    moment(2).tap()
    XCTAssertTrue(app.staticTexts["Zephyra"].waitForExistence(timeout: 5))
    app.images["gallery.viewer.image"].swipeDown()
    XCTAssertTrue(app.staticTexts["gallery.collectionTitle"].waitForExistence(timeout: 5))
    XCTAssertEqual(app.staticTexts["gallery.collectionTitle"].label, "Zephyra’s Moments")
    app.tabBars.buttons["Settings"].tap()
    app.tabBars.buttons["Gallery"].tap()
    XCTAssertEqual(app.staticTexts["gallery.collectionTitle"].label, "Zephyra’s Moments")
    chooseFilter("Unlocked")
    XCTAssertTrue(moment(2).exists)
    XCTAssertFalse(moment(2, 2).exists)
    chooseFilter("Locked")
    XCTAssertFalse(moment(2).exists)
    moment(2, 2).tap()
    XCTAssertTrue(app.staticTexts["Locked Moment"].waitForExistence(timeout: 5))
    XCTAssertEqual(app.staticTexts["gallery.lockedProgress"].label, "0 of 5 exchanges completed")
    capture("gallery-locked-sheet")
    app.buttons["Not Now"].tap()
    XCTAssertTrue(moment(2, 2).waitForExistence(timeout: 5))
    XCTAssertEqual(moment(2, 2).value as? String, "Locked. 5 chat exchanges")
    moment(2, 2).tap()
    app.buttons["gallery.chat"].tap()
    XCTAssertTrue(app.navigationBars["Zephyra"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["Send message"].exists)
    XCTAssertFalse(app.buttons["Send message"].isEnabled)
    app.navigationBars.buttons.firstMatch.tap()
    app.tabBars.buttons["Gallery"].tap()
    XCTAssertEqual(app.staticTexts["gallery.collectionTitle"].label, "Zephyra’s Moments")
    XCTAssertTrue(moment(2, 2).exists)
  }

  func testCustomCompanionHasNoBorrowedArtwork() {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.buttons["discover.createCharacter"].tap()
    let name = "Gallery " + String(UUID().uuidString.prefix(5))
    app.textFields["Name"].tap()
    app.textFields["Name"].typeText(name)
    for title in ["Appearance", "Personality", "Voice", "Preview"] {
      app.buttons["creator.primary"].tap()
      let expectation = XCTNSPredicateExpectation(
        predicate: NSPredicate(format: "label == %@", title),
        object: app.staticTexts["creator.step"])
      XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }
    app.buttons["creator.primary"].tap()
    XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 8))
    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    app.tabBars.buttons["Gallery"].tap()
    let custom = app.buttons.matching(NSPredicate(format: "label == %@", name)).firstMatch
    for _ in 0..<10 where !app.frame.contains(custom.frame) {
      app.scrollViews["gallery.companions"].swipeLeft()
    }
    XCTAssertTrue(custom.isHittable)
    custom.tap()
    XCTAssertEqual(app.staticTexts["gallery.collectionTitle"].label, "\(name)’s Moments")
    XCTAssertTrue(app.staticTexts["No Moments Yet"].waitForExistence(timeout: 5))
    XCTAssertTrue(
      app.staticTexts["There aren’t any gallery moments available for this companion yet."]
        .isHittable)
    XCTAssertFalse(
      app.staticTexts["New moments for this companion will appear here when they become available."]
        .exists)
    XCTAssertFalse(app.staticTexts["gallery.progress"].exists)
    XCTAssertFalse(moment().exists)
    XCTAssertFalse(moment(2).exists)
    capture("gallery-custom-empty")
    chooseFilter("Unlocked")
    XCTAssertTrue(app.staticTexts["No Moments Unlocked"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.staticTexts["No Moments Yet"].exists)
    chooseFilter("Locked")
    XCTAssertTrue(app.staticTexts["Everything Unlocked"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.staticTexts["No Moments Yet"].exists)
    chooseFilter("Saved")
    XCTAssertTrue(app.staticTexts["No Saved Moments"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.staticTexts["No Moments Yet"].exists)
    XCTAssertTrue(
      app.staticTexts["Save your favorite companion moments and they’ll appear here."].isHittable)
    XCTAssertFalse(app.staticTexts["Save your favorite moments to find them here."].exists)
    XCTAssertFalse(
      app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "gallery.moment."))
        .firstMatch.exists)
    capture("gallery-custom-saved-empty")
    chooseFilter("All")
    XCTAssertTrue(app.staticTexts["No Moments Yet"].waitForExistence(timeout: 5))
    XCTAssertTrue(
      app.staticTexts["There aren’t any gallery moments available for this companion yet."]
        .isHittable)
    XCTAssertFalse(
      app.staticTexts["New moments for this companion will appear here when they become available."]
        .exists)
    XCTAssertFalse(app.staticTexts["No Saved Moments"].exists)
  }

  func testLastCompanionRemainsSelectedAfterViewer() {
    launchGallery()
    chooseCompanion(8)
    XCTAssertEqual(app.staticTexts["gallery.collectionTitle"].label, "Miyuki’s Moments")
    moment(8).tap()
    XCTAssertTrue(app.images["gallery.viewer.image"].waitForExistence(timeout: 5))
    app.buttons["gallery.viewer.close"].tap()
    XCTAssertTrue(app.staticTexts["gallery.collectionTitle"].waitForExistence(timeout: 5))
    XCTAssertEqual(app.staticTexts["gallery.collectionTitle"].label, "Miyuki’s Moments")
    let selected = app.buttons["gallery.companion.A1000000-0000-0000-0000-000000000008"]
    XCTAssertEqual(selected.value as? String, "Selected")
    XCTAssertTrue(selected.isHittable)
    XCTAssertTrue(app.scrollViews["gallery.companions"].frame.contains(selected.frame))
  }

  func testGalleryLargeTextAndReducedMotion() {
    launchGallery(largeText: true)
    reveal(moment())
    capture("gallery-large-text-grid")
    moment().tap()
    XCTAssertTrue(app.buttons["gallery.viewer.close"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["gallery.viewer.close"].isHittable)
    XCTAssertTrue(app.buttons["gallery.viewer.save"].isHittable)
    XCTAssertTrue(app.buttons["gallery.viewer.share"].isHittable)
    capture("gallery-large-text-viewer")
    app.buttons["gallery.viewer.close"].tap()
    chooseFilter("Locked")
    reveal(moment(1, 2))
    moment(1, 2).tap()
    XCTAssertTrue(app.buttons["gallery.chat"].waitForExistence(timeout: 5))
    reveal(app.buttons["gallery.chat"])
    capture("gallery-large-text-sheet")
    app.buttons["Not Now"].tap()
    XCTAssertTrue(app.navigationBars["Gallery"].waitForExistence(timeout: 5))
    chooseFilter("Saved")
    XCTAssertTrue(app.buttons["gallery.filter.Saved"].isSelected)
    XCTAssertTrue(app.buttons["gallery.filter.Saved"].isHittable)
    let message = app.staticTexts["Save your favorite companion moments and they’ll appear here."]
    XCTAssertTrue(message.exists)
    for _ in 0..<4 where message.frame.maxY > app.tabBars.firstMatch.frame.minY {
      app.swipeUp()
    }
    XCTAssertTrue(message.isHittable)
    XCTAssertGreaterThanOrEqual(message.frame.minY, app.navigationBars["Gallery"].frame.maxY)
    XCTAssertLessThanOrEqual(message.frame.maxY, app.tabBars.firstMatch.frame.minY)
    XCTAssertFalse(app.staticTexts["Save your favorite moments to find them here."].exists)
    capture("gallery-large-text-saved")
    chooseFilter("Unlocked")
    for _ in 0..<4 where moment().frame.maxY > app.tabBars.firstMatch.frame.minY {
      app.swipeUp()
    }
    XCTAssertTrue(moment().isHittable)
    XCTAssertLessThanOrEqual(moment().frame.maxY, app.tabBars.firstMatch.frame.minY)
    XCTAssertGreaterThanOrEqual(moment().frame.minY, app.navigationBars["Gallery"].frame.maxY)
    capture("gallery-large-text-scrolled-card")
  }

  func testSystemReduceMotionGalleryFlow() {
    let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
    settings.launch()
    let accessibility = settings.staticTexts["Accessibility"].firstMatch
    for _ in 0..<6 where !accessibility.isHittable { settings.swipeUp() }
    XCTAssertTrue(accessibility.isHittable)
    accessibility.tap()
    settings.staticTexts["Motion"].tap()
    let toggle = settings.switches["Reduce Motion"]
    XCTAssertTrue(toggle.waitForExistence(timeout: 5))
    if toggle.value as? String == "0" { toggle.tap() }
    XCTAssertEqual(toggle.value as? String, "1")
    XCTAssertTrue(UIAccessibility.isReduceMotionEnabled)
    defer {
      settings.activate()
      if toggle.value as? String == "1" { toggle.tap() }
      settings.terminate()
    }
    launchGallery()
    chooseCompanion(2)
    chooseFilter("Unlocked")
    moment(2).tap()
    XCTAssertTrue(app.images["gallery.viewer.image"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.tabBars.buttons["Gallery"].isHittable)
    let save = app.buttons["gallery.viewer.save"]
    let original = save.label
    save.tap()
    XCTAssertNotEqual(save.label, original)
    save.tap()
    XCTAssertEqual(save.label, original)
    capture("gallery-system-reduce-motion-viewer")
    app.buttons["gallery.viewer.close"].tap()
    XCTAssertTrue(app.staticTexts["gallery.collectionTitle"].waitForExistence(timeout: 5))
    XCTAssertEqual(app.staticTexts["gallery.collectionTitle"].label, "Zephyra’s Moments")
    chooseFilter("Locked")
    moment(2, 2).tap()
    XCTAssertTrue(app.buttons["gallery.chat"].waitForExistence(timeout: 5))
    capture("gallery-system-reduce-motion-sheet")
    app.buttons["Not Now"].tap()
    XCTAssertTrue(moment(2, 2).waitForExistence(timeout: 5))
  }

  // Run only with the test build's HTTPS fixture endpoint and preconfigured fixture Keychain token.
  func testPersistedChatAutomaticallyUnlocksMoment() throws {
    guard ProcessInfo.processInfo.environment["GALLERY_FIXTURE_ENDPOINT"] == "1" else {
      throw XCTSkip("Requires the isolated Gallery HTTPS fixture build")
    }
    launchGallery()
    XCTAssertEqual(app.staticTexts["gallery.progress"].label, "1 of 2 unlocked")
    moment(1, 2).tap()
    app.buttons["gallery.chat"].tap()
    XCTAssertTrue(app.navigationBars["Astraea"].waitForExistence(timeout: 5))
    for number in 1...4 { sendFixtureExchange(number) }
    app.navigationBars.buttons.firstMatch.tap()
    app.tabBars.buttons["Gallery"].tap()
    XCTAssertEqual(app.staticTexts["gallery.progress"].label, "1 of 2 unlocked")
    moment(1, 2).tap()
    XCTAssertEqual(app.staticTexts["gallery.lockedProgress"].label, "4 of 5 exchanges completed")
    capture("gallery-real-threshold-four")
    app.buttons["gallery.chat"].tap()
    XCTAssertTrue(app.navigationBars["Astraea"].waitForExistence(timeout: 5))
    sendFixtureExchange(5)
    app.navigationBars.buttons.firstMatch.tap()
    app.tabBars.buttons["Gallery"].tap()
    let progress = app.staticTexts["gallery.progress"]
    let unlocked = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "label == %@", "2 of 2 unlocked"), object: progress)
    XCTAssertEqual(XCTWaiter.wait(for: [unlocked], timeout: 8), .completed)
    XCTAssertEqual(moment(1, 2).value as? String, "Unlocked")
    capture("gallery-automatic-unlock")
    moment(1, 2).tap()
    XCTAssertTrue(app.images["gallery.viewer.image"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.staticTexts["Locked Moment"].exists)
    app.buttons["gallery.viewer.save"].tap()
    capture("gallery-unlocked-illustration")
    app.buttons["gallery.viewer.close"].tap()
    chooseFilter("Locked")
    XCTAssertTrue(app.staticTexts["Everything Unlocked"].waitForExistence(timeout: 5))
    capture("gallery-everything-unlocked")
    app.terminate()
    launchGallery()
    XCTAssertEqual(app.staticTexts["gallery.progress"].label, "2 of 2 unlocked")
    chooseFilter("Saved")
    XCTAssertTrue(moment(1, 2).exists)
    chooseFilter("All")
    chooseCompanion(2)
    XCTAssertEqual(app.staticTexts["gallery.progress"].label, "1 of 2 unlocked")
  }

  private func sendFixtureExchange(_ number: Int) {
    let composer =
      app.textViews.firstMatch.exists ? app.textViews.firstMatch : app.textFields.firstMatch
    XCTAssertTrue(composer.waitForExistence(timeout: 5))
    composer.tap()
    composer.typeText("Gallery exchange \(number)")
    app.buttons["Send message"].tap()
    XCTAssertTrue(app.staticTexts["Gallery fixture reply \(number)"].waitForExistence(timeout: 12))
    XCTAssertFalse(app.buttons["Retry"].exists)
  }
}
