import SwiftUI

public enum CloseButtonPlacement: Sendable {
    case topBarLeading
    case topBarTrailing
    
    var toolbarPlacement: ToolbarItemPlacement {
        switch self {
        case .topBarLeading: return .topBarLeading
        case .topBarTrailing: return .topBarTrailing
        }
    }
}

public struct PaywallStyle: Sendable {
    public var accentColor: Color
    public var backgroundColor: AnyShapeStyle
    public var contentBackgroundShow: Bool
    public var contentBackgroundColor: AnyShapeStyle
    public var contentBackgroundCornerRadius: CGFloat
    public var contentBackgroundBorderColor: AnyShapeStyle
    public var contentBackgroundBorderWidth: CGFloat
    public var contentBackgroundShadow: ContentBackgroundShadow?
    public var contentBackgroundPadding: BackgroundPadding
    public var titleOrder: TitleOrder
    public var titleFont: Font
    public var titleColor: AnyShapeStyle
    public var titleBottomPadding: CGFloat
    public var subtitleFont: Font
    public var subtitleColor: AnyShapeStyle
    public var subtitleBottomPadding: CGFloat
    public var titleSubtitleSpacing: CGFloat
    public var titleFixedSize: Bool
    public var subtitleFixedSize: Bool
    public var buttonFont: Font
    public var buttonTextColor: AnyShapeStyle
    public var buttonBackgroundColor: AnyShapeStyle
    public var buttonCornerRadius: CGFloat
    public var buttonHeight: CGFloat
    public var buttonBorderColor: AnyShapeStyle
    public var buttonBorderWidth: CGFloat
    public var buttonShowBorder: Bool
    public var showPaywallButtonAnimation: Bool
    public var buttonAnimationDuration: CGFloat
    public var buttonAnimationScale: CGFloat
    public var buttonBottomPadding: CGFloat
    public var linksFont: Font
    public var linksColor: AnyShapeStyle
    public var linksSpacing: CGFloat
    public var linksShowDividers: Bool
    public var linksBottomPadding: CGFloat
    public var contentSpacing: CGFloat
    public var horizontalPadding: CGFloat
    public var bottomPadding: CGFloat
    public var maxWidth: CGFloat
    public var offerHeight: CGFloat
    public var offerCornerRadius: CGFloat
    public var offerSpacing: CGFloat
    public var offersBottomPadding: CGFloat
    public var offerTitleFont: Font
    public var offerTitleColor: AnyShapeStyle
    public var offerSelectedTitleFont: Font
    public var offerSelectedTitleColor: AnyShapeStyle
    public var offerSubtitleFont: Font
    public var offerSubtitleColor: AnyShapeStyle
    public var offerSelectedSubtitleFont: Font
    public var offerSelectedSubtitleColor: AnyShapeStyle
    public var offerPriceFont: Font
    public var offerPriceColor: AnyShapeStyle
    public var offerSelectedPriceFont: Font
    public var offerSelectedPriceColor: AnyShapeStyle
    public var offerBorderColor: AnyShapeStyle
    public var offerSelectedBorderColor: AnyShapeStyle
    public var offerBorderWidth: CGFloat
    public var offerSelectedBorderWidth: CGFloat
    public var offerBackgroundColor: AnyShapeStyle
    public var offerSelectedBackgroundColor: AnyShapeStyle
    public var offerShowCheckmark: Bool
    public var offerShadow: ContentBackgroundShadow?
    public var offerSelectedShadow: ContentBackgroundShadow?
    public var offerCheckmarkSize: CGFloat
    public var offerCheckmarkActiveBGColor: AnyShapeStyle
    public var offerCheckmarkInactiveBGColor: AnyShapeStyle
    public var offerCheckmarkActiveColor: AnyShapeStyle
    public var offerCheckmarkInactiveColor: AnyShapeStyle
    public var offerCheckmarkActiveBorderColor: AnyShapeStyle
    public var offerCheckmarkInactiveBorderColor: AnyShapeStyle
    public var offerCheckmarkIconSize: CGFloat
    public var offerCheckmarkIconWeight: Font.Weight
    public var offerShowDivider: Bool
    public var offerPriceWidth: CGFloat
    public var offerDividerActiveColor: AnyShapeStyle
    public var offerDividerInactiveColor: AnyShapeStyle
    public var offerDividerActiveWidth: CGFloat
    public var offerDividerActiveHeight: CGFloat
    public var offerDividerInactiveWidth: CGFloat
    public var offerDividerInactiveHeight: CGFloat
    public var offerDividerPaddingHorizontal: CGFloat
    public var offerDividerPaddingVertical: CGFloat
    public var closeButtonIcon: String
    public var closeButtonColor: AnyShapeStyle
    public var closeButtonFont: Font
    public var closeButtonPlacement: CloseButtonPlacement
    public var closeButtonShowGlass: Bool
    public var closeButtonShowBackground: Bool
    public var closeButtonBackgroundColor: AnyShapeStyle
    
    public init(
        accentColor: Color = .blue,
        backgroundColor: any ShapeStyle = Color.white,
        contentBackgroundShow: Bool = false,
        contentBackgroundColor: any ShapeStyle = Color.white,
        contentBackgroundCornerRadius: CGFloat = 32,
        contentBackgroundBorderColor: any ShapeStyle = Color.clear,
        contentBackgroundBorderWidth: CGFloat = 0.5,
        contentBackgroundShadow: ContentBackgroundShadow? = nil,
        contentBackgroundPadding: BackgroundPadding = BackgroundPadding(),
        titleOrder: TitleOrder = .subtitleFirst,
        titleFont: Font = .system(size: 28, weight: .bold),
        titleColor: any ShapeStyle = Color.black,
        titleBottomPadding: CGFloat = 0,
        subtitleFont: Font = .system(size: 13, weight: .regular),
        subtitleColor: any ShapeStyle = Color.black.opacity(0.6),
        subtitleBottomPadding: CGFloat = 0,
        titleSubtitleSpacing: CGFloat = 0,
        titleFixedSize: Bool = false,
        subtitleFixedSize: Bool = false,
        buttonFont: Font = .system(size: 17, weight: .semibold),
        buttonTextColor: any ShapeStyle = Color.white,
        buttonBackgroundColor: any ShapeStyle = Color.blue,
        buttonCornerRadius: CGFloat = 100,
        buttonHeight: CGFloat = 56,
        buttonBorderColor: any ShapeStyle = Color.clear,
        buttonBorderWidth: CGFloat = 1,
        buttonShowBorder: Bool = false,
        showPaywallButtonAnimation: Bool = false,
        buttonAnimationDuration: CGFloat = 0.8,
        buttonAnimationScale: CGFloat = 0.92,
        buttonBottomPadding: CGFloat = 0,
        linksFont: Font = .system(size: 13, weight: .regular),
        linksColor: any ShapeStyle = Color.secondary.opacity(0.3),
        linksSpacing: CGFloat = 10,
        linksShowDividers: Bool = true,
        linksBottomPadding: CGFloat = 0,
        contentSpacing: CGFloat = 12,
        horizontalPadding: CGFloat = 16,
        bottomPadding: CGFloat = 60,
        maxWidth: CGFloat = 744,
        offerHeight: CGFloat = 54,
        offerCornerRadius: CGFloat = 14,
        offerSpacing: CGFloat = 4,
        offersBottomPadding: CGFloat = 0,
        offerTitleFont: Font = .system(size: 15, weight: .bold),
        offerTitleColor: any ShapeStyle = Color.black,
        offerSelectedTitleFont: Font = .system(size: 15, weight: .bold),
        offerSelectedTitleColor: any ShapeStyle = Color.black,
        offerSubtitleFont: Font = .system(size: 13, weight: .regular),
        offerSubtitleColor: any ShapeStyle = Color.black.opacity(0.6),
        offerSelectedSubtitleFont: Font = .system(size: 13, weight: .regular),
        offerSelectedSubtitleColor: any ShapeStyle = Color.black.opacity(0.6),
        offerPriceFont: Font = .system(size: 15, weight: .bold),
        offerPriceColor: any ShapeStyle = Color.black,
        offerSelectedPriceFont: Font = .system(size: 15, weight: .bold),
        offerSelectedPriceColor: any ShapeStyle = Color.black,
        offerBorderColor: any ShapeStyle = Color.gray.opacity(0.3),
        offerSelectedBorderColor: any ShapeStyle = Color.pink,
        offerBorderWidth: CGFloat = 0,
        offerSelectedBorderWidth: CGFloat = 0.5,
        offerBackgroundColor: any ShapeStyle = Color.clear,
        offerSelectedBackgroundColor: any ShapeStyle = Color.clear,
        offerShowCheckmark: Bool = true,
        offerShadow: ContentBackgroundShadow? = nil,
        offerSelectedShadow: ContentBackgroundShadow? = nil,
        offerCheckmarkSize: CGFloat = 22,
        offerCheckmarkActiveBGColor: any ShapeStyle = Color.blue,
        offerCheckmarkInactiveBGColor: any ShapeStyle = Color.clear,
        offerCheckmarkActiveColor: any ShapeStyle = Color.white,
        offerCheckmarkInactiveColor: any ShapeStyle = Color.clear,
        offerCheckmarkActiveBorderColor: any ShapeStyle = Color.secondary.opacity(0.3),
        offerCheckmarkInactiveBorderColor: any ShapeStyle = Color.clear,
        offerCheckmarkIconSize: CGFloat = 14,
        offerCheckmarkIconWeight: Font.Weight = .semibold,
        offerShowDivider: Bool = false,
        offerPriceWidth: CGFloat = 130,
        offerDividerActiveColor: any ShapeStyle = Color.white,
        offerDividerInactiveColor: any ShapeStyle = Color.white,
        offerDividerActiveWidth: CGFloat = 1,
        offerDividerActiveHeight: CGFloat = 38,
        offerDividerInactiveWidth: CGFloat = 1,
        offerDividerInactiveHeight: CGFloat = 38,
        offerDividerPaddingHorizontal: CGFloat = 0,
        offerDividerPaddingVertical: CGFloat = 0,
        closeButtonIcon: String = "chevron.left",
        closeButtonColor: any ShapeStyle = Color.white,
        closeButtonFont: Font = .system(size: 12, weight: .regular),
        closeButtonPlacement: CloseButtonPlacement = .topBarLeading,
        closeButtonShowGlass: Bool = true,
        closeButtonShowBackground: Bool = false,
        closeButtonBackgroundColor: any ShapeStyle = Color.clear
    ) {
        self.accentColor = accentColor
        self.backgroundColor = AnyShapeStyle(backgroundColor)
        self.contentBackgroundShow = contentBackgroundShow
        self.contentBackgroundColor = AnyShapeStyle(contentBackgroundColor)
        self.contentBackgroundCornerRadius = contentBackgroundCornerRadius
        self.contentBackgroundBorderColor = AnyShapeStyle(contentBackgroundBorderColor)
        self.contentBackgroundBorderWidth = contentBackgroundBorderWidth
        self.contentBackgroundShadow = contentBackgroundShadow
        self.contentBackgroundPadding = contentBackgroundPadding
        self.titleOrder = titleOrder
        self.titleFont = titleFont
        self.titleColor = AnyShapeStyle(titleColor)
        self.titleBottomPadding = titleBottomPadding
        self.subtitleFont = subtitleFont
        self.subtitleColor = AnyShapeStyle(subtitleColor)
        self.subtitleBottomPadding = subtitleBottomPadding
        self.titleSubtitleSpacing = titleSubtitleSpacing
        self.titleFixedSize = titleFixedSize
        self.subtitleFixedSize = subtitleFixedSize
        self.buttonFont = buttonFont
        self.buttonTextColor = AnyShapeStyle(buttonTextColor)
        self.buttonBackgroundColor = AnyShapeStyle(buttonBackgroundColor)
        self.buttonCornerRadius = buttonCornerRadius
        self.buttonHeight = buttonHeight
        self.buttonBorderColor = AnyShapeStyle(buttonBorderColor)
        self.buttonBorderWidth = buttonBorderWidth
        self.buttonShowBorder = buttonShowBorder
        self.showPaywallButtonAnimation = showPaywallButtonAnimation
        self.buttonAnimationDuration = buttonAnimationDuration
        self.buttonAnimationScale = buttonAnimationScale
        self.buttonBottomPadding = buttonBottomPadding
        self.linksFont = linksFont
        self.linksColor = AnyShapeStyle(linksColor)
        self.linksSpacing = linksSpacing
        self.linksShowDividers = linksShowDividers
        self.linksBottomPadding = linksBottomPadding
        self.contentSpacing = contentSpacing
        self.horizontalPadding = horizontalPadding
        self.bottomPadding = bottomPadding
        self.maxWidth = maxWidth
        self.offerHeight = offerHeight
        self.offerCornerRadius = offerCornerRadius
        self.offerSpacing = offerSpacing
        self.offersBottomPadding = offersBottomPadding
        self.offerTitleFont = offerTitleFont
        self.offerTitleColor = AnyShapeStyle(offerTitleColor)
        self.offerSelectedTitleFont = offerSelectedTitleFont
        self.offerSelectedTitleColor = AnyShapeStyle(offerSelectedTitleColor)
        self.offerSubtitleFont = offerSubtitleFont
        self.offerSubtitleColor = AnyShapeStyle(offerSubtitleColor)
        self.offerSelectedSubtitleFont = offerSelectedSubtitleFont
        self.offerSelectedSubtitleColor = AnyShapeStyle(offerSelectedSubtitleColor)
        self.offerPriceFont = offerPriceFont
        self.offerPriceColor = AnyShapeStyle(offerPriceColor)
        self.offerSelectedPriceFont = offerSelectedPriceFont
        self.offerSelectedPriceColor = AnyShapeStyle(offerSelectedPriceColor)
        self.offerBorderColor = AnyShapeStyle(offerBorderColor)
        self.offerSelectedBorderColor = AnyShapeStyle(offerSelectedBorderColor)
        self.offerBorderWidth = offerBorderWidth
        self.offerSelectedBorderWidth = offerSelectedBorderWidth
        self.offerBackgroundColor = AnyShapeStyle(offerBackgroundColor)
        self.offerSelectedBackgroundColor = AnyShapeStyle(offerSelectedBackgroundColor)
        self.offerShowCheckmark = offerShowCheckmark
        self.offerShadow = offerShadow
        self.offerSelectedShadow = offerSelectedShadow
        self.offerCheckmarkSize = offerCheckmarkSize
        self.offerCheckmarkActiveBGColor = AnyShapeStyle(offerCheckmarkActiveBGColor)
        self.offerCheckmarkInactiveBGColor = AnyShapeStyle(offerCheckmarkInactiveBGColor)
        self.offerCheckmarkActiveColor = AnyShapeStyle(offerCheckmarkActiveColor)
        self.offerCheckmarkInactiveColor = AnyShapeStyle(offerCheckmarkInactiveColor)
        self.offerCheckmarkActiveBorderColor = AnyShapeStyle(offerCheckmarkActiveBorderColor)
        self.offerCheckmarkInactiveBorderColor = AnyShapeStyle(offerCheckmarkInactiveBorderColor)
        self.offerCheckmarkIconSize = offerCheckmarkIconSize
        self.offerCheckmarkIconWeight = offerCheckmarkIconWeight
        self.offerShowDivider = offerShowDivider
        self.offerPriceWidth = offerPriceWidth
        self.offerDividerActiveColor = AnyShapeStyle(offerDividerActiveColor)
        self.offerDividerInactiveColor = AnyShapeStyle(offerDividerInactiveColor)
        self.offerDividerActiveWidth = offerDividerActiveWidth
        self.offerDividerActiveHeight = offerDividerActiveHeight
        self.offerDividerInactiveWidth = offerDividerInactiveWidth
        self.offerDividerInactiveHeight = offerDividerInactiveHeight
        self.offerDividerPaddingHorizontal = offerDividerPaddingHorizontal
        self.offerDividerPaddingVertical = offerDividerPaddingVertical
        self.closeButtonIcon = closeButtonIcon
        self.closeButtonColor = AnyShapeStyle(closeButtonColor)
        self.closeButtonFont = closeButtonFont
        self.closeButtonPlacement = closeButtonPlacement
        self.closeButtonShowGlass = closeButtonShowGlass
        self.closeButtonShowBackground = closeButtonShowBackground
        self.closeButtonBackgroundColor = AnyShapeStyle(closeButtonBackgroundColor)
    }
    
    public static let `default` = PaywallStyle()
}
