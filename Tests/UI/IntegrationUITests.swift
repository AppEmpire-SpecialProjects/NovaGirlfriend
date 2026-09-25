import XCTest

final class IntegrationUITests: XCTestCase {
  let app = XCUIApplication()

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {
    if let run = testRun, run.failureCount > 0 {
      capture("failure-screen")
      let hierarchy = XCTAttachment(string: app.debugDescription)
      hierarchy.name = "failure-hierarchy"
      hierarchy.lifetime = .keepAlways
      add(hierarchy)
    }
  }

  func capture(_ name: String) {
    Thread.sleep(forTimeInterval: 0.8)
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  func button(_ prefix: String) -> XCUIElement {
    app.buttons.matching(NSPredicate(format: "label CONTAINS %@", prefix)).firstMatch
  }

  private func onboardingTitle(_ fragment: String) -> XCUIElement {
    app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", fragment)).firstMatch
  }

  private func discoverCards(named name: String) -> XCUIElementQuery {
    app.buttons.matching(identifier: "discover.characterCard")
      .matching(NSPredicate(format: "label CONTAINS %@", name))
  }

  private func selectScenarioCharacter(named name: String) {
    let choice = app.buttons["scenario.chooseCharacter"]
    reveal(choice)
    choice.tap()
    XCTAssertTrue(app.navigationBars["Choose a character"].waitForExistence(timeout: 5))
    let character = button(name)
    reveal(character)
    character.tap()
    let start = button("Start with " + name)
    XCTAssertTrue(start.waitForExistence(timeout: 5))
    reveal(start)
  }

  private func openNewConversation(named name: String) {
    let add = app.navigationBars["Conversations"].buttons["conversations.newChat"]
    XCTAssertTrue(add.waitForExistence(timeout: 5))
    add.tap()
    XCTAssertTrue(app.navigationBars["Choose a companion"].waitForExistence(timeout: 5))
    let character = app.buttons.matching(identifier: "conversations.chooseCharacter")
      .matching(NSPredicate(format: "label == %@", name)).firstMatch
    reveal(character)
    character.tap()
    XCTAssertTrue(app.navigationBars["Choose a companion"].waitForNonExistence(timeout: 5))
    XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["Send message"].waitForExistence(timeout: 5))
  }

  func advanceCreatorToPreview(captureSteps: Bool = false) {
    for title in ["Appearance", "Personality", "Voice", "Preview"] {
      app.buttons["creator.primary"].tap()
      let expectation = XCTNSPredicateExpectation(
        predicate: NSPredicate(format: "label == %@", title),
        object: app.staticTexts["creator.step"])
      XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
      Thread.sleep(forTimeInterval: 0.4)
      if captureSteps {
        capture("cyan-creator-\(title)")
      }
    }
  }

  private func closeCreator(through previousSteps: [String] = []) {
    let navigation = app.navigationBars["Create Companion"]
    let back = navigation.buttons["creator.back"]
    XCTAssertTrue(back.waitForExistence(timeout: 5))
    // The creator itself must not offer Cancel; a Cancel from the search
    // keyboard of the presenting screen may remain in the element tree.
    XCTAssertFalse(navigation.buttons["Cancel"].exists)
    XCTAssertEqual(app.buttons.matching(identifier: "creator.back").count, 1)
    for step in previousSteps {
      XCTAssertTrue(back.isHittable)
      back.tap()
      let expectation = XCTNSPredicateExpectation(
        predicate: NSPredicate(format: "label == %@", step),
        object: app.staticTexts["creator.step"])
      XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }
    XCTAssertTrue(app.textFields["Name"].exists)
    XCTAssertTrue(back.isHittable)
    back.tap()
    XCTAssertTrue(navigation.waitForNonExistence(timeout: 5))
  }

  func testCompleteExperience() throws {
    app.launchArguments = ["--uitest-reset-onboarding"]
    app.launch()
    XCTAssertTrue(onboardingTitle("Gets You").waitForExistence(timeout: 10))
    capture("01-onboarding")
    app.buttons["Continue"].tap()
    XCTAssertTrue(onboardingTitle("Your Perfect").waitForExistence(timeout: 3))
    capture("cyan-onboarding-companion")
    app.buttons["Continue"].tap()
    XCTAssertTrue(onboardingTitle("We Value").waitForExistence(timeout: 3))
    capture("cyan-onboarding-feedback")
    app.buttons["Continue"].tap()
    XCTAssertTrue(onboardingTitle("Unlock").waitForExistence(timeout: 3))
    capture("cyan-onboarding-unlock")
    app.buttons["Continue"].tap()
    XCTAssertTrue(onboardingTitle("Unlimited").waitForExistence(timeout: 3))
    capture("cyan-onboarding-unlimited")
    app.buttons["Continue"].tap()
    let paywallClose = app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch
    if paywallClose.waitForExistence(timeout: 5) {
      paywallClose.tap()
    }
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    capture("02-discover")
    app.tabBars.buttons["Conversations"].tap()
    XCTAssertTrue(app.navigationBars["Conversations"].exists)
    capture("cyan-conversations")
    app.tabBars.buttons["Gallery"].tap()
    capture("03-gallery")
    app.tabBars.buttons["Settings"].tap()
    XCTAssertTrue(app.navigationBars["Settings"].exists)
    capture("04-profile")
    button("My Companions").tap()
    XCTAssertTrue(app.buttons["Create"].waitForExistence(timeout: 5))
    capture("cyan-custom-companions")
    app.buttons["Create"].tap()
    XCTAssertTrue(app.textFields["Name"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.buttons["Continue"].isEnabled)
    app.textFields["Name"].tap()
    app.textFields["Name"].typeText("Integration Companion")
    XCTAssertTrue(app.buttons["Continue"].isHittable)
    capture("05-creator-keyboard")
    advanceCreatorToPreview(captureSteps: true)
    capture("06-creator-preview")
    app.buttons["creator.primary"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
      .tap()
    XCTAssertTrue(app.navigationBars["Integration Companion"].waitForExistence(timeout: 8))
    capture("07-saved-companion")
    app.terminate()
    app.launchArguments = []
    app.launch()
    app.tabBars.buttons["Settings"].tap()
    button("My Companions").tap()
    XCTAssertTrue(button("Integration Companion").waitForExistence(timeout: 5))
    app.navigationBars.buttons.firstMatch.tap()
    app.tabBars.buttons["Discover"].tap()
    let nova = discoverCards(named: "Astraea").firstMatch
    reveal(nova)
    nova.tap()
    if app.buttons["Remove from favorites"].exists { app.buttons["Remove from favorites"].tap() }
    XCTAssertTrue(app.buttons["Add to favorites"].waitForExistence(timeout: 5))
    app.buttons["Add to favorites"].tap()
    XCTAssertTrue(app.buttons["Remove from favorites"].exists)
    capture("08-character-detail")
    app.navigationBars.buttons.firstMatch.tap()
    app.tabBars.buttons["Conversations"].tap()
    button("Explore scenarios").tap()
    capture("23-scenarios")
    button("Coffee & a Walk").tap()
    capture("24-scenario-detail")
    selectScenarioCharacter(named: "Astraea")
    button("Start with Astraea").tap()
    XCTAssertTrue(app.buttons["Send message"].waitForExistence(timeout: 8))
    XCTAssertTrue(app.staticTexts["Coffee & a Walk"].exists)
    let composer =
      app.textViews.firstMatch.exists ? app.textViews.firstMatch : app.textFields.firstMatch
    composer.tap()
    composer.typeText("Hello from integration verification")
    XCTAssertTrue(app.buttons["Send message"].isHittable)
    XCTAssertFalse(app.tabBars.buttons["Discover"].exists)
    capture("09-chat-keyboard")
    app.buttons["Send message"].tap()
    let aiConsent = app.alerts.buttons["Continue"].firstMatch
    if aiConsent.waitForExistence(timeout: 2) { aiConsent.tap() }
    // The configured live AI endpoint answers with a real reply (SPEC §5),
    // so the "Thinking…" indicator must settle instead of an offline
    // Retry banner appearing.
    XCTAssertTrue(
      app.staticTexts.matching(identifier: "Hello from integration verification").firstMatch
        .waitForExistence(timeout: 10))
    let replySettled = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "exists == 0"), object: app.staticTexts["Thinking…"])
    XCTAssertEqual(XCTWaiter.wait(for: [replySettled], timeout: 120), .completed)
    XCTAssertFalse(app.buttons["Retry"].exists)
    capture("10-ai-reply")
    app.navigationBars.buttons.firstMatch.tap()
    // The list row is titled with the companion name; its preview after a
    // live reply is the assistant's answer, so match on the companion name.
    let storedConversation = app.buttons.matching(identifier: "conversation.open")
      .matching(NSPredicate(format: "label CONTAINS %@", "Astraea")).firstMatch
    XCTAssertTrue(storedConversation.waitForExistence(timeout: 5))
    storedConversation.tap()
    XCTAssertTrue(app.buttons["Send message"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.buttons["Retry"].exists)
    XCTAssertEqual(
      app.staticTexts.matching(identifier: "Hello from integration verification").count, 1)
    capture("18-resumed-chat")
    app.navigationBars.buttons.firstMatch.tap()
    let conversationSearch = app.textFields["conversations.search"]
    conversationSearch.tap()
    // Row previews carry the latest assistant reply, not the user's text, so
    // search and match on the stable conversation title instead.
    conversationSearch.typeText("Astraea")
    let matchingConversations = app.buttons.matching(identifier: "conversation.open").matching(
      NSPredicate(format: "label CONTAINS %@", "Astraea"))
    let matchesBeforeDelete = matchingConversations.count
    XCTAssertGreaterThan(matchesBeforeDelete, 0)
    let doomedRow = matchingConversations.firstMatch
    // The lazy list only materializes visible rows, so a CONTAINS count is
    // unstable across a delete (a new row can scroll into the materialized
    // window); settle on the doomed row's exact label instead.
    let doomedLabel = doomedRow.label
    let exactRows = app.buttons.matching(identifier: "conversation.open").matching(
      NSPredicate(format: "label == %@", doomedLabel))
    let matchesOfDoomedLabel = exactRows.count
    doomedRow.swipeLeft()
    XCTAssertTrue(button("Delete conversation Astraea").waitForExistence(timeout: 3))
    button("Delete conversation Astraea").tap()
    app.buttons["Delete"].tap()
    // SwiftData deletion lands asynchronously; wait for the row to settle.
    let deletionSettled = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "count == %d", matchesOfDoomedLabel - 1),
      object: exactRows)
    XCTAssertEqual(XCTWaiter.wait(for: [deletionSettled], timeout: 20), .completed)
    capture("19-deleted-chat")
  }

  /// Dedicated onboarding regression: the redesigned flow has a static pill
  /// (no toggles anywhere), keeps the trial info button only on the last
  /// page, and links out to legal documents before completing.
  func testOnboardingFlow() {
    app.launchArguments = ["--uitest-reset-onboarding"]
    app.launch()

    let continueButton = app.buttons["Continue"]
    XCTAssertTrue(onboardingTitle("Gets You").waitForExistence(timeout: 10))
    XCTAssertTrue(continueButton.waitForExistence(timeout: 3))
    XCTAssertEqual(app.switches.count, 0, "Onboarding must not contain toggles")
    capture("obr1")

    continueButton.tap()
    XCTAssertTrue(onboardingTitle("Your Perfect").waitForExistence(timeout: 3))
    XCTAssertEqual(app.switches.count, 0)
    capture("obr2")

    continueButton.tap()
    XCTAssertTrue(onboardingTitle("We Value").waitForExistence(timeout: 3))
    XCTAssertEqual(app.switches.count, 0)
    capture("obr3")

    continueButton.tap()
    XCTAssertTrue(onboardingTitle("Unlock").waitForExistence(timeout: 3))
    XCTAssertEqual(app.switches.count, 0)

    // Swipe navigation still works alongside the CTA.
    app.swipeRight()
    XCTAssertTrue(onboardingTitle("We Value").waitForExistence(timeout: 3))
    app.swipeLeft()
    XCTAssertTrue(onboardingTitle("Unlock").waitForExistence(timeout: 3))

    continueButton.tap()
    XCTAssertTrue(onboardingTitle("Unlimited").waitForExistence(timeout: 3))
    XCTAssertEqual(app.switches.count, 0)

    // Last page: static pill copy plus its trial info button.
    XCTAssertTrue(
      app.staticTexts["Not sure yet? Start a free trial"].waitForExistence(timeout: 3))
    let trialInfo = app.buttons["Free trial details"]
    XCTAssertTrue(trialInfo.waitForExistence(timeout: 3))

    // Enabling the trial swaps the pill copy and the CTA title.
    trialInfo.tap()
    XCTAssertTrue(app.staticTexts["Free trial enabled"].waitForExistence(timeout: 3))
    XCTAssertTrue(app.buttons["Try free & subscribe"].waitForExistence(timeout: 3))

    // Disabling it restores the defaults.
    trialInfo.tap()
    XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 3))
    XCTAssertTrue(
      app.staticTexts["Not sure yet? Start a free trial"].waitForExistence(timeout: 3))

    // Legal links open their documents straight from onboarding.
    button("Terms of Use").tap()
    XCTAssertTrue(app.navigationBars["Terms of Use"].waitForExistence(timeout: 5))
    app.buttons["Done"].tap()
    XCTAssertTrue(onboardingTitle("Unlimited").waitForExistence(timeout: 5))

    button("Privacy Policy").tap()
    XCTAssertTrue(app.navigationBars["Privacy Policy"].waitForExistence(timeout: 5))
    app.buttons["Done"].tap()
    XCTAssertTrue(onboardingTitle("Unlimited").waitForExistence(timeout: 5))

    button("Restore").tap()
    XCTAssertTrue(app.alerts["Nothing to restore"].waitForExistence(timeout: 5))
    app.alerts.buttons["OK"].tap()
    XCTAssertTrue(onboardingTitle("Unlimited").waitForExistence(timeout: 5))

    // Completing the flow hands off past onboarding.
    app.buttons["Continue"].tap()
    XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch.waitForExistence(timeout: 5))
  }

  func testChatReturn() throws {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.tabBars.buttons["Conversations"].tap()
    button("Explore scenarios").tap()
    capture("23-scenarios")
    button("Coffee & a Walk").tap()
    capture("24-scenario-detail")
    selectScenarioCharacter(named: "Astraea")
    button("Start with Astraea").tap()
    XCTAssertTrue(app.buttons["Send message"].waitForExistence(timeout: 5))
    let composer =
      app.textViews.firstMatch.exists ? app.textViews.firstMatch : app.textFields.firstMatch
    composer.tap()
    composer.typeText("Keyboard return verification")
    app.buttons["Send message"].tap()
    let aiConsent = app.alerts.buttons["Continue"].firstMatch
    if aiConsent.waitForExistence(timeout: 2) { aiConsent.tap() }
    XCTAssertTrue(
      app.staticTexts.matching(identifier: "Keyboard return verification").firstMatch
        .waitForExistence(timeout: 10))
    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Conversations"].waitForExistence(timeout: 5))
  }

  func testDiscoverAndConversationsSections() throws {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    let create = app.buttons["discover.createCharacter"]
    XCTAssertTrue(create.waitForExistence(timeout: 5))
    XCTAssertTrue(create.isHittable)
    XCTAssertFalse(button("Explore scenarios").exists)
    XCTAssertFalse(app.staticTexts["Current companion"].exists)
    XCTAssertFalse(app.staticTexts["Find your character"].exists)
    let companion = discoverCards(named: "Astraea").firstMatch
    XCTAssertTrue(companion.waitForExistence(timeout: 5))
    XCTAssertLessThanOrEqual(create.frame.maxY, companion.frame.minY)
    XCTAssertFalse(companion.label.contains("Current"))
    companion.tap()
    XCTAssertTrue(app.navigationBars["Astraea"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.buttons["Choose"].exists)
    XCTAssertFalse(app.buttons["Selected"].exists)
    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))

    app.tabBars.buttons["Conversations"].tap()
    let search = app.textFields["conversations.search"]
    let scenarios = app.buttons["conversations.scenarios"]
    XCTAssertTrue(search.waitForExistence(timeout: 5))
    XCTAssertTrue(scenarios.isHittable)
    XCTAssertLessThanOrEqual(search.frame.maxY, scenarios.frame.minY)
    scenarios.tap()
    XCTAssertTrue(app.navigationBars["Scenarios"].waitForExistence(timeout: 5))
    XCTAssertTrue(button("Coffee & a Walk").exists)
    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Conversations"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["conversations.scenarios"].isHittable)
  }

  func testNewConversationFromToolbar() {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.tabBars.buttons["Conversations"].tap()
    let add = app.navigationBars["Conversations"].buttons["conversations.newChat"]
    XCTAssertTrue(add.waitForExistence(timeout: 5))
    XCTAssertTrue(add.isHittable)
    let conversationCount = app.buttons.matching(identifier: "conversation.open").count
    add.tap()
    XCTAssertTrue(app.navigationBars["Choose a companion"].waitForExistence(timeout: 5))
    app.buttons["Cancel"].tap()
    XCTAssertTrue(app.navigationBars["Choose a companion"].waitForNonExistence(timeout: 5))
    XCTAssertTrue(app.navigationBars["Conversations"].exists)
    XCTAssertFalse(app.buttons["Send message"].exists)
    XCTAssertEqual(app.buttons.matching(identifier: "conversation.open").count, conversationCount)

    for name in [
      "Astraea", "Astraea", "Zephyra", "Elowen", "Vespera", "Kaida", "Selene", "Aurelia", "Miyuki",
    ] {
      openNewConversation(named: name)
      // New conversations open with a seeded greeting (SPEC §5), so the
      // chat shows history with a disabled composer instead of the
      // "Say hello" placeholder.
      XCTAssertFalse(app.staticTexts["Say hello"].exists)
      XCTAssertFalse(app.buttons["Send message"].isEnabled)
      app.navigationBars.buttons.firstMatch.tap()
      XCTAssertTrue(app.navigationBars["Conversations"].waitForExistence(timeout: 5))
    }
  }

  func testDiscoverSearch() throws {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.swipeDown()
    let search = app.searchFields.firstMatch
    XCTAssertTrue(search.waitForExistence(timeout: 5))
    search.tap()
    search.typeText("Zephyra")
    XCTAssertTrue(discoverCards(named: "Zephyra").firstMatch.waitForExistence(timeout: 5))
    capture("20-discover-search")
    search.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: "Zephyra".count))
    search.typeText("NoCompanionMatches987")
    XCTAssertTrue(
      app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "No Results")).firstMatch
        .waitForExistence(timeout: 5))
    capture("21-empty-search")
  }

  func testGalleryAndSettings() throws {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.tabBars.buttons["Gallery"].tap()
    button("Astraea's portrait").tap()
    XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 5))
    capture("11-gallery-viewer")
    app.buttons["Close"].tap()
    app.tabBars.buttons["Settings"].tap()
    button("Export Data").tap()
    XCTAssertTrue(button("Share JSON Export").exists)
    capture("22-data-export")
    app.navigationBars.buttons.firstMatch.tap()
    button("Voice Settings").tap()
    let playback = app.switches["Read responses aloud"]
    XCTAssertTrue(playback.exists)
    let original = playback.value as? String
    playback.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
    Thread.sleep(forTimeInterval: 0.5)
    XCTAssertNotEqual(playback.value as? String, original)
    app.buttons["Preview voice"].tap()
    app.buttons["Stop preview"].tap()
    capture("12-voice-settings")
    app.navigationBars.buttons.firstMatch.tap()
    button("Experience").tap()
    let motion = app.switches["Reduce motion"]
    motion.tap()
    capture("13-experience-settings")
    app.navigationBars.buttons.firstMatch.tap()
    app.swipeUp()
    button("Privacy Policy").tap()
    XCTAssertTrue(app.navigationBars["Privacy Policy"].waitForExistence(timeout: 3))
    capture("14-privacy")
    app.buttons["Done"].tap()
    button("Terms of Use").tap()
    XCTAssertTrue(app.navigationBars["Terms of Use"].waitForExistence(timeout: 3))
    capture("cyan-terms")
    app.buttons["Done"].tap()
  }

  func testCompanionEditDuplicateDelete() throws {
    let companionName = "CRUD " + UUID().uuidString.prefix(8)
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.tabBars.buttons["Settings"].tap()
    button("My Companions").tap()
    app.buttons["Create"].tap()
    let freshName = app.textFields["Name"]
    XCTAssertTrue(freshName.waitForExistence(timeout: 5))
    freshName.tap()
    freshName.typeText(companionName)
    advanceCreatorToPreview()
    app.buttons["creator.primary"].tap()
    XCTAssertTrue(app.navigationBars[companionName].waitForExistence(timeout: 5))
    app.buttons["Edit Companion"].tap()
    let name = app.textFields["Name"]
    XCTAssertTrue(name.waitForExistence(timeout: 4))
    XCTAssertEqual(name.value as? String, companionName)
    name.tap()
    name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: companionName.count))
    XCTAssertEqual(name.value as? String, "Name")
    name.typeText(companionName + " Edited")
    XCTAssertEqual(name.value as? String, companionName + " Edited")
    advanceCreatorToPreview()
    app.buttons["creator.primary"].tap()
    XCTAssertTrue(app.navigationBars[companionName + " Edited"].waitForExistence(timeout: 5))
    app.buttons["Duplicate Companion"].tap()
    XCTAssertTrue(app.navigationBars[companionName + " Edited Copy"].waitForExistence(timeout: 5))
    capture("16-duplicate-companion")
    app.buttons["Delete Companion"].tap()
    XCTAssertTrue(app.buttons["companion.confirmDelete"].waitForExistence(timeout: 3))
    // iOS 26 exposes the SwiftUI confirmation twice (button + popup node).
    app.buttons["companion.confirmDelete"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars[companionName + " Edited"].waitForExistence(timeout: 5))
    app.buttons["Delete Companion"].tap()
    XCTAssertTrue(app.buttons["companion.confirmDelete"].waitForExistence(timeout: 3))
    // iOS 26 exposes the SwiftUI confirmation twice (button + popup node).
    app.buttons["companion.confirmDelete"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["My Companions"].waitForExistence(timeout: 5))
    XCTAssertFalse(button(companionName + " Edited").exists)
    capture("17-deleted-companion")
  }

  func testCyanThemeSecondaryScreens() {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    let nova = discoverCards(named: "Astraea").firstMatch
    reveal(nova)
    nova.tap()
    XCTAssertTrue(app.navigationBars["Astraea"].waitForExistence(timeout: 5))
    app.buttons["More about Astraea"].tap()
    XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
    capture("cyan-character-more-sheet")
    app.buttons["Done"].tap()
    app.swipeUp()
    capture("cyan-character-personality")
    let gallery = button("View included and saved moments")
    reveal(gallery)
    gallery.tap()
    XCTAssertTrue(app.navigationBars["Astraea's Gallery"].waitForExistence(timeout: 5))
    capture("cyan-character-gallery")
    app.navigationBars.buttons.firstMatch.tap()
    let scenarios = button("Choose a setting with Astraea")
    reveal(scenarios)
    scenarios.tap()
    XCTAssertTrue(app.navigationBars["Scenarios"].waitForExistence(timeout: 5))
    button("Coffee & a Walk").tap()
    let selected = button("Selected character")
    let choice = selected.exists ? selected : button("Choose a character")
    reveal(choice)
    choice.tap()
    XCTAssertTrue(app.navigationBars["Choose a character"].waitForExistence(timeout: 5))
    capture("cyan-character-selection-sheet")
    button("Astraea").tap()
    let start = button("Start with Astraea")
    reveal(start)
    capture("cyan-scenario-actions")
    start.tap()
    XCTAssertTrue(app.buttons["Send message"].waitForExistence(timeout: 5))
    capture("cyan-empty-chat")
    app.buttons["Conversation actions"].tap()
    capture("cyan-chat-actions-menu")
    XCTAssertFalse(app.buttons["Export JSON"].exists)
    XCTAssertFalse(app.buttons["Stop speaking"].exists)
    XCTAssertFalse(app.buttons["AI Connection"].exists)
    XCTAssertFalse(app.buttons["AI Companion"].exists)
    app.buttons["chat.chooseScenario"].tap()
    XCTAssertTrue(app.navigationBars["Choose Scenario"].waitForExistence(timeout: 5))
    XCTAssertEqual(app.buttons["chat.scenario.coffee-walk"].value as? String, "Selected")
    capture("cyan-chat-scenario-selection")
    app.buttons["Cancel"].tap()
    app.buttons["Conversation actions"].tap()
    app.buttons["Voice Settings"].tap()
    XCTAssertTrue(app.navigationBars["Voice Settings"].waitForExistence(timeout: 5))
    capture("cyan-chat-voice-settings")
    app.navigationBars.buttons.firstMatch.tap()
    app.buttons["Conversation actions"].tap()
    app.buttons["Clear conversation"].tap()
    XCTAssertTrue(app.buttons["Clear messages"].waitForExistence(timeout: 5))
    capture("cyan-destructive-confirmation")
    // The iOS 26 confirmation popover offers no Cancel button; tapping
    // outside dismisses it and keeps the conversation.
    app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.4)).tap()
    XCTAssertTrue(app.buttons["Send message"].waitForExistence(timeout: 5))
  }

  func testChatScenarioSelectionAndReopening() {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.tabBars.buttons["Conversations"].tap()
    openNewConversation(named: "Astraea")
    XCTAssertFalse(app.staticTexts["chat.scenarioTitle"].exists)

    app.buttons["Conversation actions"].tap()
    XCTAssertFalse(app.buttons["Export JSON"].exists)
    XCTAssertFalse(app.buttons["Stop speaking"].exists)
    XCTAssertFalse(app.buttons["AI Connection"].exists)
    XCTAssertFalse(app.buttons["AI Companion"].exists)
    app.buttons["chat.chooseScenario"].tap()
    XCTAssertTrue(app.navigationBars["Choose Scenario"].waitForExistence(timeout: 5))
    XCTAssertEqual(app.buttons["chat.scenario.none"].value as? String, "Selected")
    app.buttons["Cancel"].tap()
    XCTAssertTrue(app.navigationBars["Choose Scenario"].waitForNonExistence(timeout: 5))
    XCTAssertFalse(app.staticTexts["chat.scenarioTitle"].exists)

    let scenarios = [
      ("coffee-walk", "Coffee & a Walk"),
      ("creative-evening", "Creative Evening"),
      ("stargazing", "Stargazing"),
      ("weekend-plans", "Weekend Plans"),
    ]
    for (id, title) in scenarios {
      app.buttons["Conversation actions"].tap()
      app.buttons["chat.chooseScenario"].tap()
      let option = app.buttons["chat.scenario.\(id)"]
      XCTAssertTrue(option.waitForExistence(timeout: 5))
      reveal(option)
      option.tap()
      XCTAssertTrue(app.navigationBars["Choose Scenario"].waitForNonExistence(timeout: 5))
      XCTAssertEqual(app.staticTexts["chat.scenarioTitle"].label, title)
      XCTAssertTrue(app.navigationBars["Astraea"].exists)
      // The conversation keeps its seeded greeting when a scenario is
      // chosen, so the placeholder must not reappear.
      XCTAssertFalse(app.staticTexts["Say hello"].exists)
      XCTAssertFalse(app.buttons["Send message"].isEnabled)
    }
    capture("chat-selected-scenario")
    app.navigationBars.buttons.firstMatch.tap()
    let conversation = app.buttons.matching(identifier: "conversation.open")
      .matching(NSPredicate(format: "label CONTAINS %@", "Astraea")).firstMatch
    XCTAssertTrue(conversation.waitForExistence(timeout: 5))
    conversation.tap()
    XCTAssertEqual(app.staticTexts["chat.scenarioTitle"].label, "Weekend Plans")
    app.buttons["Conversation actions"].tap()
    app.buttons["chat.chooseScenario"].tap()
    XCTAssertTrue(app.navigationBars["Choose Scenario"].waitForExistence(timeout: 5))
    XCTAssertEqual(app.buttons["chat.scenario.weekend-plans"].value as? String, "Selected")
    app.buttons["chat.scenario.none"].tap()
    XCTAssertTrue(app.navigationBars["Choose Scenario"].waitForNonExistence(timeout: 5))
    XCTAssertFalse(app.staticTexts["chat.scenarioTitle"].exists)
  }

  func testNavigationAfterScrollingAndSheetDismissal() {
    for category in ["UICTContentSizeCategoryL", "UICTContentSizeCategoryAccessibilityL"] {
      app.launchArguments = [
        "-preferences.hasCompletedOnboarding", "YES",
        "-UIPreferredContentSizeCategoryName", category,
      ]
      app.launch()
      let nova = discoverCards(named: "Astraea").firstMatch
      reveal(nova)
      nova.tap()
      let navigation = app.navigationBars["Astraea"]
      XCTAssertTrue(navigation.waitForExistence(timeout: 5))
      capture("cyan-navigation-top-\(category)")
      app.swipeUp()
      XCTAssertTrue(navigation.buttons["Discover"].isHittable)
      capture("cyan-navigation-scrolled-\(category)")
      app.buttons["More about Astraea"].tap()
      XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
      app.buttons["Done"].tap()
      XCTAssertTrue(app.buttons["Done"].waitForNonExistence(timeout: 5))
      XCTAssertTrue(navigation.buttons["Discover"].isHittable)
      capture("cyan-navigation-dismissed-\(category)")
      navigation.buttons["Discover"].tap()
      XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
      app.terminate()
    }
  }

  func testExportDelivery() {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.tabBars.buttons["Settings"].tap()
    button("Export Data").tap()
    button("Share JSON Export").tap()
    let copy = app.cells.matching(NSPredicate(format: "label == %@", "Copy")).firstMatch
    XCTAssertTrue(copy.waitForExistence(timeout: 5))
    capture("35-export-share-sheet")
    copy.tap()
    XCTAssertTrue(app.navigationBars["Export Data"].waitForExistence(timeout: 5))
  }

  func testCreatorCompanionPortraitSelectionPersists() {
    let name = "Avatar " + UUID().uuidString.prefix(8)
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.buttons["discover.createCharacter"].tap()
    let nameField = app.textFields["Name"]
    XCTAssertTrue(nameField.waitForExistence(timeout: 5))
    nameField.tap()
    nameField.typeText(name)
    app.buttons["creator.primary"].tap()

    let photo = app.buttons["creator.choosePhoto"]
    XCTAssertTrue(photo.waitForExistence(timeout: 5))
    XCTAssertTrue(photo.isHittable)
    let portraits = (1...8).map {
      app.buttons["creator.avatar.A1000000-0000-0000-0000-00000000000\($0)"]
    }
    XCTAssertTrue(portraits[0].waitForExistence(timeout: 5))
    XCTAssertEqual(
      app.buttons.matching(
        NSPredicate(format: "label BEGINSWITH %@ AND label ENDSWITH %@", "Select ", " avatar")
      ).count, 8)
    XCTAssertLessThan(photo.frame.maxY, portraits[0].frame.minY)
    for (index, portrait) in portraits.enumerated() {
      reveal(portrait)
      portrait.tap()
      XCTAssertTrue(portrait.isSelected)
      if index > 0 { XCTAssertFalse(portraits[index - 1].isSelected) }
      XCTAssertEqual(photo.label, "Choose a Photo")
    }
    capture("creator-eight-companion-portraits")
    app.buttons["creator.primary"].tap()
    XCTAssertTrue(app.staticTexts["Shape their personality"].waitForExistence(timeout: 5))
    app.buttons["creator.back"].tap()
    XCTAssertTrue(portraits[7].waitForExistence(timeout: 5))
    XCTAssertTrue(portraits[7].isSelected)

    for step in ["Personality", "Voice", "Preview"] {
      app.buttons["creator.primary"].tap()
      let expectation = XCTNSPredicateExpectation(
        predicate: NSPredicate(format: "label == %@", step),
        object: app.staticTexts["creator.step"])
      XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }
    capture("creator-selected-portrait-preview")
    app.buttons["creator.primary"].tap()
    // Creating from My Companions can land either on the saved companion's
    // detail screen or back on the list; either way the saved companion
    // must be present.
    if !app.navigationBars[name].waitForExistence(timeout: 10) {
      // The companions list is oldest-first and lazy; the new row renders at
      // the bottom, so scroll to it before asserting it exists.
      reveal(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", name)).firstMatch)
    }
    app.terminate()
    app.launch()
    app.tabBars.buttons["Settings"].tap()
    button("My Companions").tap()
    let companion = button(name)
    var openedDetail = false
    for _ in 0..<3 where !openedDetail {
      reveal(companion)
      Thread.sleep(forTimeInterval: 0.5)
      // A tap right after scrolling can be swallowed by the list's
      // deceleration, and a lazy row can dematerialize between the
      // hittable check and the tap; tap the app at the row's last frame
      // and retry until the detail screen opens.
      guard companion.exists, companion.isHittable else { continue }
      let frame = companion.frame
      // The list's last row can park with its lower third under the
      // floating tab bar; a midpoint tap then selects the row without
      // navigating. Aim at the upper part of the row, clear of the bar.
      app.coordinate(withNormalizedOffset: .zero)
        .withOffset(CGVector(dx: frame.midX, dy: frame.minY + frame.height * 0.3)).tap()
      openedDetail = app.navigationBars[name].waitForExistence(timeout: 10)
    }
    XCTAssertTrue(openedDetail)
    capture("creator-saved-portrait-relaunched")
    let edit = app.buttons["Edit Companion"]
    reveal(edit)
    edit.tap()
    XCTAssertTrue(app.textFields["Name"].waitForExistence(timeout: 5))
    app.buttons["creator.primary"].tap()
    XCTAssertTrue(portraits[7].waitForExistence(timeout: 5))
    XCTAssertTrue(portraits[7].isSelected)
    app.buttons["creator.back"].tap()
    XCTAssertTrue(app.textFields["Name"].waitForExistence(timeout: 5))
    app.buttons["creator.back"].tap()
    XCTAssertTrue(app.navigationBars["Edit Companion"].waitForNonExistence(timeout: 5))
  }

  func testPhotoImport() {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.tabBars.buttons["Settings"].tap()
    button("My Companions").tap()
    app.buttons["Create"].tap()
    let name = app.textFields["Name"]
    XCTAssertTrue(name.waitForExistence(timeout: 5))
    name.tap()
    name.typeText("Photo lifecycle")
    app.buttons["creator.primary"].tap()
    let portrait = app.buttons["creator.avatar.A1000000-0000-0000-0000-000000000001"]
    XCTAssertTrue(portrait.waitForExistence(timeout: 5))
    portrait.tap()
    XCTAssertTrue(portrait.isSelected)
    button("Choose a Photo").tap()
    capture("32-photo-picker")
    let photos = app.images.matching(identifier: "PXGGridLayout-Info")
    XCTAssertTrue(photos.firstMatch.waitForExistence(timeout: 5))
    // Picker grid cells are not hittable on iOS 26; tapping by coordinate
    // still selects the asset.
    photos.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    XCTAssertTrue(button("Replace Selected Photo").waitForExistence(timeout: 8))
    XCTAssertFalse(portrait.isSelected)
    capture("33-photo-imported")
    button("Replace Selected Photo").tap()
    XCTAssertTrue(photos.element(boundBy: 1).waitForExistence(timeout: 5))
    photos.element(boundBy: 1).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
      .tap()
    XCTAssertTrue(button("Replace Selected Photo").waitForExistence(timeout: 8))
    capture("34-photo-replaced")
    button("Replace Selected Photo").tap()
    // The system picker follows the device language, so Cancel may be
    // localized ("Отмена" on a Russian simulator).
    let cancelPicker = app.buttons["Cancel"].firstMatch.exists
      ? app.buttons["Cancel"].firstMatch : app.buttons["Отмена"].firstMatch
    XCTAssertTrue(cancelPicker.waitForExistence(timeout: 5))
    cancelPicker.tap()
    XCTAssertTrue(button("Replace Selected Photo").waitForExistence(timeout: 5))
    portrait.tap()
    XCTAssertTrue(portrait.isSelected)
    XCTAssertEqual(app.buttons["creator.choosePhoto"].label, "Choose a Photo")
    closeCreator(through: ["Identity"])
    XCTAssertTrue(app.navigationBars["My Companions"].waitForExistence(timeout: 5))
    XCTAssertFalse(button("Photo lifecycle").exists)
  }

  func testRecordingLifecycle() throws {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.tabBars.buttons["Conversations"].tap()
    button("Explore scenarios").tap()
    button("Coffee & a Walk").tap()
    selectScenarioCharacter(named: "Astraea")
    button("Start with Astraea").tap()
    let record = app.buttons["Record voice message"]
    XCTAssertTrue(record.waitForExistence(timeout: 5))
    addUIInterruptionMonitor(withDescription: "Microphone permission") { alert in
      if alert.buttons["Allow"].exists {
        alert.buttons["Allow"].tap()
        return true
      }
      if alert.buttons["OK"].exists {
        alert.buttons["OK"].tap()
        return true
      }
      return false
    }
    record.tap()
    if !app.buttons["Done"].waitForExistence(timeout: 3) {
      app.tap()
      // The permission sheet makes the scene inactive, cancelling the pending start.
      // A fresh, explicit tap must be required after returning to the app.
      if !app.buttons["Done"].exists { record.tap() }
    }
    XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 8))
    XCTAssertFalse(app.buttons["Send message"].isEnabled)
    capture("25-recording")
    app.buttons["Cancel"].tap()
    XCTAssertFalse(app.buttons["Play recording"].exists)
    XCTAssertTrue(record.isEnabled)
    record.tap()
    XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
    Thread.sleep(forTimeInterval: 1)
    app.buttons["Done"].tap()
    XCTAssertTrue(app.buttons["Play recording"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["Send message"].isEnabled)
    app.buttons["Play recording"].tap()
    capture("26-recording-draft")
    app.buttons["Discard"].tap()
    XCTAssertFalse(app.buttons["Play recording"].exists)
    XCTAssertFalse(app.buttons["Send message"].isEnabled)
    record.tap()
    XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
    XCUIDevice.shared.press(.home)
    app.activate()
    XCTAssertTrue(record.waitForExistence(timeout: 5))
    XCTAssertTrue(record.isEnabled)
    XCTAssertFalse(app.buttons["Done"].exists)
    capture("27-recording-background-cancel")
  }

  func testDiscoverCreateCharacter() {
    let name = "Discover " + UUID().uuidString.prefix(8)
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    app.tabBars.buttons["Conversations"].tap()
    XCTAssertTrue(app.buttons["conversations.newChat"].waitForExistence(timeout: 5))
    app.tabBars.buttons["Discover"].tap()
    let create = app.buttons["discover.createCharacter"]
    XCTAssertTrue(create.waitForExistence(timeout: 5))
    XCTAssertEqual(create.label, "Create Companion")
    XCTAssertTrue(create.isHittable)
    XCTAssertTrue(app.frame.contains(create.frame))
    capture("midnight-discover-create")
    create.tap()
    let field = app.textFields["Name"]
    XCTAssertTrue(field.waitForExistence(timeout: 5))
    XCTAssertFalse(app.buttons["creator.primary"].isEnabled)
    field.tap()
    field.typeText("Cancelled " + name)
    closeCreator()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    XCTAssertFalse(discoverCards(named: "Cancelled " + name).firstMatch.exists)

    create.tap()
    XCTAssertTrue(field.waitForExistence(timeout: 5))
    XCTAssertFalse(app.buttons["creator.primary"].isEnabled)
    field.tap()
    field.typeText(name)
    advanceCreatorToPreview()
    app.buttons["creator.primary"].tap()
    XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5))
    capture("midnight-discover-created-profile")
    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    app.tabBars.buttons["Conversations"].tap()
    openNewConversation(named: name)
    // Seeded greeting replaces the empty-chat placeholder (SPEC §5).
    XCTAssertFalse(app.staticTexts["Say hello"].exists)
    XCTAssertFalse(app.buttons["Send message"].isEnabled)
    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Conversations"].waitForExistence(timeout: 5))
    app.tabBars.buttons["Discover"].tap()
    let search = app.searchFields.firstMatch
    XCTAssertTrue(search.waitForExistence(timeout: 5))
    search.tap()
    search.typeText(name)
    app.keyboards.buttons["Search"].tap()
    XCTAssertEqual(search.value as? String, name)
    let card = discoverCards(named: name).firstMatch
    reveal(card)
    XCTAssertEqual(discoverCards(named: name).count, 1)
    app.terminate()
    app.launch()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    XCTAssertTrue(search.waitForExistence(timeout: 5))
    search.tap()
    search.typeText(name)
    app.keyboards.buttons["Search"].tap()
    XCTAssertEqual(search.value as? String, name)
    reveal(card)
    card.tap()
    XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5))
    capture("midnight-discover-created-persisted")

    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    app.tabBars.buttons["Conversations"].tap()
    let scenarios = app.buttons["conversations.scenarios"]
    XCTAssertTrue(scenarios.waitForExistence(timeout: 5))
    scenarios.tap()
    XCTAssertTrue(app.navigationBars["Scenarios"].waitForExistence(timeout: 5))
    button("Coffee & a Walk").tap()
    XCTAssertTrue(app.navigationBars["Coffee & a Walk"].waitForExistence(timeout: 5))
    selectScenarioCharacter(named: name)
    button("Start with " + name).tap()
    XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["Send message"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["Coffee & a Walk"].exists)
    capture("discover-created-companion-scenario-chat")
    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Conversations"].waitForExistence(timeout: 5))
    openNewConversation(named: name)
    // Seeded greeting replaces the empty-chat placeholder (SPEC §5).
    XCTAssertFalse(app.staticTexts["Say hello"].exists)
    XCTAssertFalse(app.staticTexts["Coffee & a Walk"].exists)
    app.navigationBars.buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Conversations"].waitForExistence(timeout: 5))
  }

  func testDiscoverCreateCompanionFromEmptySearch() {
    verifyDiscoverCreationFromEmptySearch(category: "UICTContentSizeCategoryL")
  }

  func testDiscoverCreateCompanionFromEmptySearchLargeText() {
    verifyDiscoverCreationFromEmptySearch(category: "UICTContentSizeCategoryAccessibilityL")
  }

  private func verifyDiscoverCreationFromEmptySearch(category: String) {
    let name = "Search " + UUID().uuidString.prefix(8)
    app.launchArguments = [
      "-preferences.hasCompletedOnboarding", "YES",
      "-UIPreferredContentSizeCategoryName", category,
    ]
    app.launch()
    app.swipeDown()
    let search = app.searchFields.firstMatch
    XCTAssertTrue(search.waitForExistence(timeout: 5))
    search.tap()
    search.typeText(name)
    let noResults = app.staticTexts.matching(
      NSPredicate(format: "label CONTAINS %@", "No Results")
    ).firstMatch
    XCTAssertTrue(noResults.waitForExistence(timeout: 5))
    let create = app.buttons["discover.createCharacter"]
    XCTAssertTrue(create.isHittable)
    capture("discover-empty-search-create-\(category)")
    create.tap()

    let field = app.textFields["Name"]
    XCTAssertTrue(field.waitForExistence(timeout: 5))
    field.tap()
    field.typeText(name)
    closeCreator()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    XCTAssertEqual(search.value as? String, name)
    XCTAssertTrue(noResults.waitForExistence(timeout: 5))
    XCTAssertTrue(create.isHittable)

    create.tap()
    XCTAssertTrue(field.waitForExistence(timeout: 5))
    XCTAssertEqual(field.value as? String, "Name")
    XCTAssertFalse(app.buttons["creator.primary"].isEnabled)
    field.tap()
    field.typeText(name)
    advanceCreatorToPreview()
    app.buttons["creator.primary"].tap()
    XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5))
    app.navigationBars[name].buttons.firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    XCTAssertEqual(search.value as? String, name)
    XCTAssertFalse(noResults.exists)
    let card = discoverCards(named: name).firstMatch
    reveal(card)
    card.tap()
    XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5))
    capture("discover-search-created-companion-\(category)")
  }

  func testEditorialPortraitsAndNavigationHeadings() {
    app.launchArguments = ["-preferences.hasCompletedOnboarding", "YES"]
    app.launch()
    let heading = app.staticTexts["nova.navigationTitle"]
    XCTAssertTrue(heading.waitForExistence(timeout: 5))
    XCTAssertEqual(heading.label, "Discover")
    capture("midnight-rounded-discover")
    for name in ["Astraea", "Zephyra", "Elowen", "Vespera", "Kaida", "Selene", "Aurelia", "Miyuki"]
    {
      let card = discoverCards(named: name).firstMatch
      reveal(card)
      card.tap()
      XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5))
      XCTAssertEqual(heading.label, name)
      capture("midnight-portrait-\(name)")
      app.navigationBars.buttons.firstMatch.tap()
      XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    }
    app.tabBars.buttons["Settings"].tap()
    XCTAssertTrue(app.navigationBars["Settings"].exists)
    capture("midnight-rounded-profile")
  }

  func testEditorialProfilesAndLargeTextChat() {
    for category in ["UICTContentSizeCategoryL", "UICTContentSizeCategoryAccessibilityL"] {
      app.launchArguments = [
        "-preferences.hasCompletedOnboarding", "YES",
        "-preferences.reduceMotion", "YES",
        "-UIPreferredContentSizeCategoryName", category,
      ]
      app.launch()
      XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
      let card = discoverCards(named: "Astraea").firstMatch
      reveal(card)
      capture("midnight-card-\(category)")
      card.tap()
      XCTAssertTrue(app.navigationBars["Astraea"].waitForExistence(timeout: 5))
      capture("midnight-character-\(category)")
      let chat = button("Chat with Astraea")
      reveal(chat, fullyVisible: true)
      XCTAssertTrue(app.frame.contains(chat.frame))
      capture("midnight-character-actions-\(category)")
      chat.tap()
      let send = app.buttons["Send message"]
      XCTAssertTrue(send.waitForExistence(timeout: 5))
      app.buttons["Conversation actions"].tap()
      app.buttons["Clear conversation"].tap()
      app.buttons["Clear messages"].tap()
      XCTAssertFalse(app.buttons["Retry"].exists)
      XCTAssertTrue(app.staticTexts["Say hello"].exists)
      XCTAssertFalse(send.isEnabled)
      let composer =
        app.textViews.firstMatch.exists
        ? app.textViews.firstMatch : app.textFields.firstMatch
      composer.tap()
      composer.typeText("Midnight layout verification")
      XCTAssertTrue(send.isEnabled)
      XCTAssertTrue(send.isHittable)
      XCTAssertTrue(app.frame.contains(send.frame))
      capture("midnight-chat-keyboard-\(category)")
      send.tap()
      // The live AI endpoint answers the message (SPEC §5): wait for the
      // reply to settle; the Retry banner only appears on transport errors.
      XCTAssertTrue(
        app.staticTexts.matching(identifier: "Midnight layout verification").firstMatch
          .waitForExistence(timeout: 10))
      let replySettled = XCTNSPredicateExpectation(
        predicate: NSPredicate(format: "exists == 0"), object: app.staticTexts["Thinking…"])
      XCTAssertEqual(XCTWaiter.wait(for: [replySettled], timeout: 120), .completed)
      XCTAssertFalse(app.buttons["Retry"].exists)
      capture("midnight-chat-reply-\(category)")
      app.navigationBars.buttons.firstMatch.tap()
      XCTAssertTrue(app.navigationBars["Conversations"].waitForExistence(timeout: 5))
      capture("midnight-conversations-\(category)")
      app.buttons["New conversation"].tap()
      XCTAssertTrue(app.navigationBars["Choose a companion"].waitForExistence(timeout: 5))
      XCTAssertTrue(app.buttons["Cancel"].isHittable)
      capture("cyan-new-conversation-\(category)")
      app.buttons["Cancel"].tap()
      XCTAssertTrue(app.navigationBars["Conversations"].waitForExistence(timeout: 5))
      app.terminate()
    }
  }

  func testEditorialLargeTextGalleryAndCreator() throws {
    app.launchArguments = [
      "-preferences.hasCompletedOnboarding", "YES",
      "-preferences.reduceMotion", "YES",
      "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL",
    ]
    app.launch()
    let create = app.buttons["discover.createCharacter"]
    XCTAssertTrue(create.waitForExistence(timeout: 5))
    XCTAssertTrue(create.isHittable)
    XCTAssertTrue(app.frame.contains(create.frame))
    capture("midnight-discover-create-large-text")
    create.tap()
    XCTAssertTrue(app.textFields["Name"].waitForExistence(timeout: 5))
    closeCreator()
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    app.tabBars.buttons["Gallery"].tap()
    let portrait = button("Astraea's portrait")
    reveal(portrait)
    capture("midnight-gallery-large-text")
    portrait.tap()
    let close = app.buttons["Close"]
    XCTAssertTrue(close.waitForExistence(timeout: 5))
    let title = try XCTUnwrap(
      app.staticTexts.matching(identifier: "Astraea's portrait").allElementsBoundByIndex.first {
        $0.isHittable
      })
    XCTAssertTrue(app.frame.contains(title.frame))
    XCTAssertTrue(close.isHittable)
    capture("midnight-gallery-viewer-large-text")
    close.tap()

    app.tabBars.buttons["Settings"].tap()
    button("My Companions").tap()
    XCTAssertTrue(app.buttons["Create"].waitForExistence(timeout: 5))
    capture("cyan-custom-companions-large-text")
    app.buttons["Create"].tap()
    let name = app.textFields["Name"]
    XCTAssertTrue(name.waitForExistence(timeout: 5))
    name.tap()
    name.typeText("Midnight reader")
    let primary = app.buttons["creator.primary"]
    XCTAssertTrue(primary.isEnabled)
    XCTAssertTrue(primary.isHittable)
    XCTAssertTrue(app.frame.contains(primary.frame))
    capture("midnight-creator-keyboard-large-text")
    for step in ["Appearance", "Personality", "Voice", "Preview"] {
      primary.tap()
      let expectation = XCTNSPredicateExpectation(
        predicate: NSPredicate(format: "label == %@", step),
        object: app.staticTexts["creator.step"])
      XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
      XCTAssertTrue(primary.isHittable)
      XCTAssertTrue(app.frame.contains(primary.frame))
      capture("midnight-creator-\(step)-large-text")
    }
    closeCreator(through: ["Voice", "Personality", "Appearance", "Identity"])
    XCTAssertTrue(app.navigationBars["My Companions"].waitForExistence(timeout: 5))
    XCTAssertFalse(button("Midnight reader").exists)
  }

  private func reveal(_ element: XCUIElement, fullyVisible: Bool = false) {
    for _ in 0..<8 {
      if element.exists && element.isHittable
        && (!fullyVisible || app.frame.contains(element.frame))
      {
        break
      }
      app.swipeUp()
    }
    XCTAssertTrue(element.exists)
    XCTAssertTrue(element.isHittable)
  }

  func testAccessibleLayout() {
    app.launchArguments = [
      "--uitest-reset-onboarding",
      "-preferences.reduceMotion", "YES",
      "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL",
    ]
    app.launch()
    XCTAssertTrue(button("Continue").waitForExistence(timeout: 5))
    XCTAssertTrue(button("Continue").isHittable)
    capture("28-accessibility-onboarding")
    button("Continue").tap()
    XCTAssertTrue(onboardingTitle("Your Perfect").waitForExistence(timeout: 3))
    button("Continue").tap()
    XCTAssertTrue(onboardingTitle("We Value").waitForExistence(timeout: 3))
    button("Continue").tap()
    XCTAssertTrue(onboardingTitle("Unlock").waitForExistence(timeout: 3))
    button("Continue").tap()
    XCTAssertTrue(onboardingTitle("Unlimited").waitForExistence(timeout: 3))
    button("Continue").tap()
    let paywallClose = app.buttons.matching(NSPredicate(format: "label == %@", "Close")).firstMatch
    if paywallClose.waitForExistence(timeout: 5) {
      paywallClose.tap()
    }
    XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    capture("29-accessibility-discover")
    app.tabBars.buttons["Settings"].tap()
    capture("30-accessibility-settings")
    app.swipeUp()
    button("Privacy Policy").tap()
    XCTAssertTrue(app.navigationBars["Privacy Policy"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["Done"].isHittable)
    capture("31-accessibility-privacy")
    app.buttons["Done"].tap()
  }

}
