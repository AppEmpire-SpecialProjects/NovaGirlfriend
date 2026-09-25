import SwiftUI

public struct ContentBackgroundShadow: Sendable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public init(color: Color = .black.opacity(0.2), radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public struct BackgroundPadding: Sendable {
    public let horizontal: CGFloat
    public let bottom: CGFloat
    
    public init(horizontal: CGFloat = 0, bottom: CGFloat = 0) {
        self.horizontal = horizontal
        self.bottom = bottom
    }
}

public enum OnboardingContentElement: Sendable {
    case indicators
    case title
    case subtitle
    case message
    case button
}

public struct PriceCustomization: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let underline = PriceCustomization(rawValue: 1 << 0)
    public static let heavy = PriceCustomization(rawValue: 1 << 1)
}

public struct OnboardingStyle: Sendable {
    public var contentOrder: [OnboardingContentElement]
    public var priceCustomization: PriceCustomization?
    public var priceCustomizationFont: Font?
    public var priceCustomizationColor: Color?
    public var limitedButtonUnderline: Bool
    public var limitedButtonFont: Font?
    public var limitedButtonColor: AnyShapeStyle?
    public var splitSubtitleBy: Int?
    public var subtitleBeforeFont: Font?
    public var subtitleBeforeColor: Color?
    public var subtitleAfterFont: Font?
    public var subtitleAfterColor: Color?
    public var toggleColor: Color
    public var backgroundColor: AnyShapeStyle
    public var contentBackgroundShow: Bool
    public var contentBackgroundColor: AnyShapeStyle
    public var contentBackgroundCornerRadius: CGFloat
    public var contentBackgroundBorderColor: AnyShapeStyle
    public var contentBackgroundBorderWidth: CGFloat
    public var contentBackgroundShadow: ContentBackgroundShadow?
    public var contentBackgroundPadding: BackgroundPadding
    public var titleFont: Font
    public var titleFixedSize: Bool
    public var subtitleFixedSize: Bool
    public var title1Color: AnyShapeStyle
    public var title2Color: AnyShapeStyle
    public var titleBottomPadding: CGFloat
    public var subtitleFont: Font
    public var subtitleColor: AnyShapeStyle
    public var subtitleBottomPadding: CGFloat
    public var messageFont: Font
    public var messageColor: AnyShapeStyle
    public var messageBackgroundColor: AnyShapeStyle
    public var messageHeight: CGFloat
    public var messageCornerRadius: CGFloat
    public var messageBorderColor: AnyShapeStyle
    public var messageBorderWidth: CGFloat
    public var messageShowBorder: Bool
    public var messageBottomPadding: CGFloat
    public var buttonFont: Font
    public var buttonTextColor: AnyShapeStyle
    public var buttonBackgroundColor: AnyShapeStyle
    public var buttonCornerRadius: CGFloat
    public var buttonHeight: CGFloat
    public var buttonBorderColor: AnyShapeStyle
    public var buttonBorderWidth: CGFloat
    public var buttonShowBorder: Bool
    public var showPaywallButtonAnimation: Bool
    public var showButtonAnimationAlways: Bool
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
    public var indicatorActiveColor: AnyShapeStyle
    public var indicatorInactiveColor: AnyShapeStyle
    public var indicatorFutureColor: AnyShapeStyle
    public var indicatorActiveWidth: CGFloat
    public var indicatorInactiveWidth: CGFloat
    public var indicatorHeight: CGFloat
    public var indicatorActiveHeight: CGFloat
    public var indicatorInactiveHeight: CGFloat
    /// Радиус углов индикаторов: 100 — капсула (по умолчанию), 0 — квадратные
    public var indicatorCornerRadius: CGFloat
    public var indicatorSpacing: CGFloat
    public var indicatorBackgroundColor: AnyShapeStyle
    public var indicatorBackgroundCornerRadius: CGFloat
    public var indicatorHorizontalPadding: CGFloat
    public var indicatorVerticalPadding: CGFloat
    public var indicatorsBottomPadding: CGFloat
    public var showNewToggle: Bool
    public var toggleType: PaywallToggleType
    public var pickerStyle: PickerPaywallStyle?
    public var checkmarkSize: CGFloat
    public var checkmarkActiveBGColor: AnyShapeStyle
    public var checkmarkInactiveBGColor: AnyShapeStyle
    public var checkmarkActiveColor: AnyShapeStyle
    public var checkmarkInactiveColor: AnyShapeStyle
    public var checkmarkActiveBorderColor: AnyShapeStyle
    public var checkmarkInactiveBorderColor: AnyShapeStyle
    public var checkmarkIconSize: CGFloat
    public var checkmarkIconWeight: Font.Weight
    public var minimumScaleFactor: CGFloat
    
    public init(
        contentOrder: [OnboardingContentElement] = [.indicators, .title, .subtitle, .message],
        priceCustomization: PriceCustomization? = nil,
        priceCustomizationFont: Font? = nil,
        priceCustomizationColor: Color? = nil,
        limitedButtonUnderline: Bool = false,
        limitedButtonFont: Font? = nil,
        limitedButtonColor: (any ShapeStyle)? = nil,
        splitSubtitleBy: Int? = nil,
        subtitleBeforeFont: Font? = nil,
        subtitleBeforeColor: Color? = nil,
        subtitleAfterFont: Font? = nil,
        subtitleAfterColor: Color? = nil,
        toggleColor: Color = .blue,
        backgroundColor: any ShapeStyle = Color.white,
        contentBackgroundShow: Bool = false,
        contentBackgroundColor: any ShapeStyle = Color.white,
        contentBackgroundCornerRadius: CGFloat = 32,
        contentBackgroundBorderColor: any ShapeStyle = Color.clear,
        contentBackgroundBorderWidth: CGFloat = 0.5,
        contentBackgroundShadow: ContentBackgroundShadow? = nil,
        contentBackgroundPadding: BackgroundPadding = BackgroundPadding(),
        titleFont: Font = .system(size: 26, weight: .heavy),
        titleFixedSize: Bool = false,
        subtitleFixedSize: Bool = false,
        title1Color: any ShapeStyle = Color.blue,
        title2Color: any ShapeStyle = Color.black,
        titleBottomPadding: CGFloat = 0,
        subtitleFont: Font = .system(size: 15, weight: .regular),
        subtitleColor: any ShapeStyle = Color.secondary.opacity(0.6),
        subtitleBottomPadding: CGFloat = 0,
        messageFont: Font = .system(size: 15, weight: .regular),
        messageColor: any ShapeStyle = Color.black,
        messageBackgroundColor: any ShapeStyle = Color.secondary.opacity(0.2),
        messageHeight: CGFloat = 48,
        messageCornerRadius: CGFloat = 100,
        messageBorderColor: any ShapeStyle = Color.clear,
        messageBorderWidth: CGFloat = 1,
        messageShowBorder: Bool = false,
        messageBottomPadding: CGFloat = 0,
        buttonFont: Font = .system(size: 20, weight: .bold),
        buttonTextColor: any ShapeStyle = Color.white,
        buttonBackgroundColor: any ShapeStyle = Color.blue,
        buttonCornerRadius: CGFloat = 100,
        buttonHeight: CGFloat = 56,
        buttonBorderColor: any ShapeStyle = Color.clear,
        buttonBorderWidth: CGFloat = 1,
        buttonShowBorder: Bool = false,
        showPaywallButtonAnimation: Bool = true,
        showButtonAnimationAlways: Bool = false,
        buttonAnimationDuration: CGFloat = 0.8,
        buttonAnimationScale: CGFloat = 0.92,
        buttonBottomPadding: CGFloat = 0,
        linksFont: Font = .system(size: 13, weight: .regular),
        linksColor: any ShapeStyle = Color.secondary.opacity(0.3),
        linksSpacing: CGFloat = 10,
        linksShowDividers: Bool = true,
        linksBottomPadding: CGFloat = 0,
        contentSpacing: CGFloat = 16,
        horizontalPadding: CGFloat = 16,
        bottomPadding: CGFloat = 20,
        maxWidth: CGFloat = 744,
        indicatorActiveColor: any ShapeStyle = Color.blue,
        indicatorInactiveColor: any ShapeStyle = Color.blue.opacity(0.2),
        indicatorFutureColor: any ShapeStyle = Color.blue.opacity(0.2),
        indicatorActiveWidth: CGFloat = 24,
        indicatorInactiveWidth: CGFloat = 6,
        indicatorHeight: CGFloat = 6,
        indicatorActiveHeight: CGFloat? = nil,
        indicatorInactiveHeight: CGFloat? = nil,
        indicatorCornerRadius: CGFloat = 100,
        indicatorSpacing: CGFloat = 4,
        indicatorBackgroundColor: any ShapeStyle = Color.clear,
        indicatorBackgroundCornerRadius: CGFloat = 0,
        indicatorHorizontalPadding: CGFloat = 0,
        indicatorVerticalPadding: CGFloat = 0,
        indicatorsBottomPadding: CGFloat = 0,
        showNewToggle: Bool = false,
        toggleType: PaywallToggleType = .checkmark,
        pickerStyle: PickerPaywallStyle? = nil,
        checkmarkSize: CGFloat = 22,
        checkmarkActiveBGColor: any ShapeStyle = Color.blue,
        checkmarkInactiveBGColor: any ShapeStyle = Color.clear,
        checkmarkActiveColor: any ShapeStyle = Color.white,
        checkmarkInactiveColor: any ShapeStyle = Color.clear,
        checkmarkActiveBorderColor: any ShapeStyle = Color.secondary.opacity(0.3),
        checkmarkInactiveBorderColor: any ShapeStyle = Color.gray,
        checkmarkIconSize: CGFloat = 14,
        checkmarkIconWeight: Font.Weight = .semibold,
        minimumScaleFactor: CGFloat = 1
    ) {
        self.contentOrder = contentOrder
        self.priceCustomization = priceCustomization
        self.priceCustomizationFont = priceCustomizationFont
        self.priceCustomizationColor = priceCustomizationColor
        self.limitedButtonUnderline = limitedButtonUnderline
        self.limitedButtonFont = limitedButtonFont
        self.limitedButtonColor = limitedButtonColor.map { AnyShapeStyle($0) }
        self.splitSubtitleBy = splitSubtitleBy
        self.subtitleBeforeFont = subtitleBeforeFont
        self.subtitleBeforeColor = subtitleBeforeColor
        self.subtitleAfterFont = subtitleAfterFont
        self.subtitleAfterColor = subtitleAfterColor
        self.toggleColor = toggleColor
        self.backgroundColor = AnyShapeStyle(backgroundColor)
        self.contentBackgroundShow = contentBackgroundShow
        self.contentBackgroundColor = AnyShapeStyle(contentBackgroundColor)
        self.contentBackgroundCornerRadius = contentBackgroundCornerRadius
        self.contentBackgroundBorderColor = AnyShapeStyle(contentBackgroundBorderColor)
        self.contentBackgroundBorderWidth = contentBackgroundBorderWidth
        self.contentBackgroundShadow = contentBackgroundShadow
        self.contentBackgroundPadding = contentBackgroundPadding
        self.titleFont = titleFont
        self.titleFixedSize = titleFixedSize
        self.subtitleFixedSize = subtitleFixedSize
        self.title1Color = AnyShapeStyle(title1Color)
        self.title2Color = AnyShapeStyle(title2Color)
        self.titleBottomPadding = titleBottomPadding
        self.subtitleFont = subtitleFont
        self.subtitleColor = AnyShapeStyle(subtitleColor)
        self.subtitleBottomPadding = subtitleBottomPadding
        self.messageFont = messageFont
        self.messageColor = AnyShapeStyle(messageColor)
        self.messageBackgroundColor = AnyShapeStyle(messageBackgroundColor)
        self.messageHeight = messageHeight
        self.messageCornerRadius = messageCornerRadius
        self.messageBorderColor = AnyShapeStyle(messageBorderColor)
        self.messageBorderWidth = messageBorderWidth
        self.messageShowBorder = messageShowBorder
        self.messageBottomPadding = messageBottomPadding
        self.buttonFont = buttonFont
        self.buttonTextColor = AnyShapeStyle(buttonTextColor)
        self.buttonBackgroundColor = AnyShapeStyle(buttonBackgroundColor)
        self.buttonCornerRadius = buttonCornerRadius
        self.buttonHeight = buttonHeight
        self.buttonBorderColor = AnyShapeStyle(buttonBorderColor)
        self.buttonBorderWidth = buttonBorderWidth
        self.buttonShowBorder = buttonShowBorder
        self.showPaywallButtonAnimation = showPaywallButtonAnimation
        self.showButtonAnimationAlways = showButtonAnimationAlways
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
        self.indicatorActiveColor = AnyShapeStyle(indicatorActiveColor)
        self.indicatorInactiveColor = AnyShapeStyle(indicatorInactiveColor)
        self.indicatorFutureColor = AnyShapeStyle(indicatorFutureColor)
        self.indicatorActiveWidth = indicatorActiveWidth
        self.indicatorInactiveWidth = indicatorInactiveWidth
        self.indicatorHeight = indicatorHeight
        self.indicatorActiveHeight = indicatorActiveHeight ?? indicatorHeight
        self.indicatorInactiveHeight = indicatorInactiveHeight ?? indicatorHeight
        self.indicatorCornerRadius = indicatorCornerRadius
        self.indicatorSpacing = indicatorSpacing
        self.indicatorBackgroundColor = AnyShapeStyle(indicatorBackgroundColor)
        self.indicatorBackgroundCornerRadius = indicatorBackgroundCornerRadius
        self.indicatorHorizontalPadding = indicatorHorizontalPadding
        self.indicatorVerticalPadding = indicatorVerticalPadding
        self.indicatorsBottomPadding = indicatorsBottomPadding
        self.showNewToggle = showNewToggle
        self.toggleType = toggleType
        self.pickerStyle = pickerStyle
        self.checkmarkSize = checkmarkSize
        self.checkmarkActiveBGColor = AnyShapeStyle(checkmarkActiveBGColor)
        self.checkmarkInactiveBGColor = AnyShapeStyle(checkmarkInactiveBGColor)
        self.checkmarkActiveColor = AnyShapeStyle(checkmarkActiveColor)
        self.checkmarkInactiveColor = AnyShapeStyle(checkmarkInactiveColor)
        self.checkmarkActiveBorderColor = AnyShapeStyle(checkmarkActiveBorderColor)
        self.checkmarkInactiveBorderColor = AnyShapeStyle(checkmarkInactiveBorderColor)
        self.checkmarkIconSize = checkmarkIconSize
        self.checkmarkIconWeight = checkmarkIconWeight
        self.minimumScaleFactor = minimumScaleFactor
    }
    
    public static let `default` = OnboardingStyle()
}
