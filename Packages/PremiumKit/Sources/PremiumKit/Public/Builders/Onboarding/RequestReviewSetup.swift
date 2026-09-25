import Foundation

public struct RequestReviewSetup: Sendable {
    public let isEnabled: Bool
    public let launch: Int
    public let delay: TimeInterval

    public init(
        isEnabled: Bool = true,
        launch: Int = 2,
        delay: TimeInterval = 2.0
    ) {
        self.isEnabled = isEnabled
        self.launch = launch
        self.delay = delay
    }
}
