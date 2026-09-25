import SwiftUI

public struct OnboardingScreen: Identifiable {
    public let id: Int
    public let title1: String
    public let title2: String
    public let subtitle: String
    public let message: String
    public let buttonTitle: String
    public let images: AdaptiveResources
    public let showReviewRequest: Bool
    public let backgroundContent: AnyView?
    public let middleContent: AnyView?
    public let overlayContent: AnyView?
    public let hideContent: [OnboardingContentElement]
    
    public init(
        id: Int,
        title1: String,
        title2: String = "",
        subtitle: String,
        message: String = "",
        buttonTitle: String? = nil,
        images: AdaptiveResources,
        showReviewRequest: Bool = false,
        backgroundView: AnyView? = nil,
        middleView: AnyView? = nil,
        overlayView: AnyView? = nil,
        hideContent: [OnboardingContentElement] = []
    ) {
        self.id = id
        self.title1 = title1
        self.title2 = title2
        self.subtitle = subtitle
        self.message = message
        self.buttonTitle = buttonTitle ?? L10n.Button.next
        self.images = images
        self.showReviewRequest = showReviewRequest
        self.backgroundContent = backgroundView
        self.middleContent = middleView
        self.overlayContent = overlayView
        self.hideContent = hideContent
    }
}
