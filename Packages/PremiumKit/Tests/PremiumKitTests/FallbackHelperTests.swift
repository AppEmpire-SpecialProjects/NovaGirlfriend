import XCTest
@testable import PremiumKit

@MainActor
final class FallbackHelperTests: XCTestCase {
    func testLocalFallbackDecodesWithoutStartingApphud() throws {
        let model = FallbackHelper().localPaywallModel(
            for: .main, fileName: "Fixtures/fallback", bundle: .module
        )
        XCTAssertEqual(model.products.map(\.id), ["test.weekly"])
        XCTAssertEqual(model.title, "Local fallback")
        XCTAssertFalse(model.showRequestReview)
        // No store response means eligibility is unknown, not a promised trial.
        XCTAssertFalse(try XCTUnwrap(model.products.first).isTrial)
    }

    func testMissingFallbackDoesNotExposeMockPurchaseIDs() {
        let model = FallbackHelper().localPaywallModel(
            for: .main, fileName: "does-not-exist", bundle: .module
        )
        XCTAssertTrue(model.products.isEmpty)
    }

    func testMissingPlacementDoesNotUseAnotherPlacement() {
        let model = FallbackHelper().localPaywallModel(
            for: .onboarding, fileName: "Fixtures/fallback", bundle: .module
        )
        XCTAssertTrue(model.products.isEmpty)
    }
}
