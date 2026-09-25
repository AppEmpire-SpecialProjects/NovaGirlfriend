import SwiftUI

public enum SecondaryPaywallContentElement: Sendable, Hashable {
    case title
    case subtitle
    case message
    case offers
}

public struct SecondaryPaywallStyle: Sendable {
    public var contentBackground: ContentBackground
    public var title: Title
    public var messageToggle: MessageToggle
    public var offer: Offer
    public var button: ActionButton
    public var links: Links
    public var layout: Layout
    public var closeButton: CloseButton

    public init(
        contentBackground: ContentBackground = .default,
        title: Title = .default,
        messageToggle: MessageToggle = .default,
        offer: Offer = .default,
        button: ActionButton = .default,
        links: Links = .default,
        layout: Layout = .default,
        closeButton: CloseButton = .default
    ) {
        self.contentBackground = contentBackground
        self.title = title
        self.messageToggle = messageToggle
        self.offer = offer
        self.button = button
        self.links = links
        self.layout = layout
        self.closeButton = closeButton
    }

    public static let `default` = SecondaryPaywallStyle()
}

// MARK: - ContentBackground

extension SecondaryPaywallStyle {
    public struct ContentBackground: Sendable {
        public var backgroundColor: AnyShapeStyle
        public var show: Bool
        public var color: AnyShapeStyle
        public var cornerRadius: CGFloat
        public var borderColor: AnyShapeStyle
        public var borderWidth: CGFloat
        public var shadow: ContentBackgroundShadow?
        public var padding: BackgroundPadding

        public init(
            backgroundColor: any ShapeStyle = Color.white,
            show: Bool = false,
            color: any ShapeStyle = Color.white,
            cornerRadius: CGFloat = 32,
            borderColor: any ShapeStyle = Color.clear,
            borderWidth: CGFloat = 0.5,
            shadow: ContentBackgroundShadow? = nil,
            padding: BackgroundPadding = BackgroundPadding()
        ) {
            self.backgroundColor = AnyShapeStyle(backgroundColor)
            self.show = show
            self.color = AnyShapeStyle(color)
            self.cornerRadius = cornerRadius
            self.borderColor = AnyShapeStyle(borderColor)
            self.borderWidth = borderWidth
            self.shadow = shadow
            self.padding = padding
        }

        public static let `default` = ContentBackground()
    }
}

// MARK: - Title

extension SecondaryPaywallStyle {
    public struct Title: Sendable {
        public var font: Font
        public var color1: AnyShapeStyle
        public var color2: AnyShapeStyle
        public var bottomPadding: CGFloat
        public var subtitleFont: Font
        public var subtitleColor: AnyShapeStyle
        public var subtitleBottomPadding: CGFloat
        public var limitedButtonUnderline: Bool
        public var priceCustomization: PriceCustomization?
        public var priceCustomizationFont: Font?
        public var priceCustomizationColor: Color?
        public var splitSubtitleBy: Int?
        public var subtitleBeforeFont: Font?
        public var subtitleBeforeColor: Color?
        public var subtitleAfterFont: Font?
        public var subtitleAfterColor: Color?
        public var minimumScaleFactor: CGFloat
        public var titleFixedSize: Bool
        public var subtitleFixedSize: Bool

        public init(
            font: Font = .system(size: 26, weight: .heavy),
            color1: any ShapeStyle = Color.blue,
            color2: any ShapeStyle = Color.black,
            bottomPadding: CGFloat = 0,
            subtitleFont: Font = .system(size: 15, weight: .regular),
            subtitleColor: any ShapeStyle = Color.secondary.opacity(0.6),
            subtitleBottomPadding: CGFloat = 0,
            limitedButtonUnderline: Bool = false,
            priceCustomization: PriceCustomization? = nil,
            priceCustomizationFont: Font? = nil,
            priceCustomizationColor: Color? = nil,
            splitSubtitleBy: Int? = nil,
            subtitleBeforeFont: Font? = nil,
            subtitleBeforeColor: Color? = nil,
            subtitleAfterFont: Font? = nil,
            subtitleAfterColor: Color? = nil,
            minimumScaleFactor: CGFloat = 1,
            titleFixedSize: Bool = false,
            subtitleFixedSize: Bool = false
        ) {
            self.font = font
            self.color1 = AnyShapeStyle(color1)
            self.color2 = AnyShapeStyle(color2)
            self.bottomPadding = bottomPadding
            self.subtitleFont = subtitleFont
            self.subtitleColor = AnyShapeStyle(subtitleColor)
            self.subtitleBottomPadding = subtitleBottomPadding
            self.limitedButtonUnderline = limitedButtonUnderline
            self.priceCustomization = priceCustomization
            self.priceCustomizationFont = priceCustomizationFont
            self.priceCustomizationColor = priceCustomizationColor
            self.splitSubtitleBy = splitSubtitleBy
            self.subtitleBeforeFont = subtitleBeforeFont
            self.subtitleBeforeColor = subtitleBeforeColor
            self.subtitleAfterFont = subtitleAfterFont
            self.subtitleAfterColor = subtitleAfterColor
            self.minimumScaleFactor = minimumScaleFactor
            self.titleFixedSize = titleFixedSize
            self.subtitleFixedSize = subtitleFixedSize
        }

        public static let `default` = Title()
    }
}

// MARK: - MessageToggle

extension SecondaryPaywallStyle {
    public struct MessageToggle: Sendable {
        public var font: Font
        public var color: AnyShapeStyle
        public var backgroundColor: AnyShapeStyle
        public var height: CGFloat
        public var cornerRadius: CGFloat
        public var borderColor: AnyShapeStyle
        public var borderWidth: CGFloat
        public var showBorder: Bool
        public var bottomPadding: CGFloat
        public var toggleColor: Color
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

        public init(
            font: Font = .system(size: 15, weight: .regular),
            color: any ShapeStyle = Color.black,
            backgroundColor: any ShapeStyle = Color.secondary.opacity(0.2),
            height: CGFloat = 48,
            cornerRadius: CGFloat = 100,
            borderColor: any ShapeStyle = Color.clear,
            borderWidth: CGFloat = 1,
            showBorder: Bool = false,
            bottomPadding: CGFloat = 0,
            toggleColor: Color = .blue,
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
            checkmarkIconWeight: Font.Weight = .semibold
        ) {
            self.font = font
            self.color = AnyShapeStyle(color)
            self.backgroundColor = AnyShapeStyle(backgroundColor)
            self.height = height
            self.cornerRadius = cornerRadius
            self.borderColor = AnyShapeStyle(borderColor)
            self.borderWidth = borderWidth
            self.showBorder = showBorder
            self.bottomPadding = bottomPadding
            self.toggleColor = toggleColor
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
        }

        public static let `default` = MessageToggle()
    }
}

// MARK: - Offer

extension SecondaryPaywallStyle {
    public struct Offer: Sendable {
        public var height: CGFloat
        public var cornerRadius: CGFloat
        public var spacing: CGFloat
        public var bottomPadding: CGFloat
        public var titleFont: Font
        public var titleColor: AnyShapeStyle
        public var selectedTitleFont: Font
        public var selectedTitleColor: AnyShapeStyle
        public var subtitleFont: Font
        public var subtitleColor: AnyShapeStyle
        public var selectedSubtitleFont: Font
        public var selectedSubtitleColor: AnyShapeStyle
        public var priceFont: Font
        public var priceColor: AnyShapeStyle
        public var selectedPriceFont: Font
        public var selectedPriceColor: AnyShapeStyle
        public var borderColor: AnyShapeStyle
        public var selectedBorderColor: AnyShapeStyle
        public var borderWidth: CGFloat
        public var selectedBorderWidth: CGFloat
        public var backgroundColor: AnyShapeStyle
        public var selectedBackgroundColor: AnyShapeStyle
        public var showCheckmark: Bool
        public var shadow: ContentBackgroundShadow?
        public var selectedShadow: ContentBackgroundShadow?
        public var checkmarkSize: CGFloat
        public var checkmarkActiveBGColor: AnyShapeStyle
        public var checkmarkInactiveBGColor: AnyShapeStyle
        public var checkmarkActiveColor: AnyShapeStyle
        public var checkmarkInactiveColor: AnyShapeStyle
        public var checkmarkActiveBorderColor: AnyShapeStyle
        public var checkmarkInactiveBorderColor: AnyShapeStyle
        public var checkmarkIconSize: CGFloat
        public var checkmarkIconWeight: Font.Weight
        public var showDivider: Bool
        public var priceWidth: CGFloat
        public var dividerActiveColor: AnyShapeStyle
        public var dividerInactiveColor: AnyShapeStyle
        public var dividerActiveWidth: CGFloat
        public var dividerActiveHeight: CGFloat
        public var dividerInactiveWidth: CGFloat
        public var dividerInactiveHeight: CGFloat
        public var dividerPaddingHorizontal: CGFloat
        public var dividerPaddingVertical: CGFloat

        public init(
            height: CGFloat = 54,
            cornerRadius: CGFloat = 14,
            spacing: CGFloat = 4,
            bottomPadding: CGFloat = 0,
            titleFont: Font = .system(size: 15, weight: .bold),
            titleColor: any ShapeStyle = Color.black,
            selectedTitleFont: Font = .system(size: 15, weight: .bold),
            selectedTitleColor: any ShapeStyle = Color.black,
            subtitleFont: Font = .system(size: 13, weight: .regular),
            subtitleColor: any ShapeStyle = Color.black.opacity(0.6),
            selectedSubtitleFont: Font = .system(size: 13, weight: .regular),
            selectedSubtitleColor: any ShapeStyle = Color.black.opacity(0.6),
            priceFont: Font = .system(size: 15, weight: .bold),
            priceColor: any ShapeStyle = Color.black,
            selectedPriceFont: Font = .system(size: 15, weight: .bold),
            selectedPriceColor: any ShapeStyle = Color.black,
            borderColor: any ShapeStyle = Color.gray.opacity(0.3),
            selectedBorderColor: any ShapeStyle = Color.pink,
            borderWidth: CGFloat = 0,
            selectedBorderWidth: CGFloat = 0.5,
            backgroundColor: any ShapeStyle = Color.clear,
            selectedBackgroundColor: any ShapeStyle = Color.clear,
            showCheckmark: Bool = true,
            shadow: ContentBackgroundShadow? = nil,
            selectedShadow: ContentBackgroundShadow? = nil,
            checkmarkSize: CGFloat = 22,
            checkmarkActiveBGColor: any ShapeStyle = Color.blue,
            checkmarkInactiveBGColor: any ShapeStyle = Color.clear,
            checkmarkActiveColor: any ShapeStyle = Color.white,
            checkmarkInactiveColor: any ShapeStyle = Color.clear,
            checkmarkActiveBorderColor: any ShapeStyle = Color.secondary.opacity(0.3),
            checkmarkInactiveBorderColor: any ShapeStyle = Color.gray,
            checkmarkIconSize: CGFloat = 14,
            checkmarkIconWeight: Font.Weight = .semibold,
            showDivider: Bool = false,
            priceWidth: CGFloat = 130,
            dividerActiveColor: any ShapeStyle = Color.white,
            dividerInactiveColor: any ShapeStyle = Color.white,
            dividerActiveWidth: CGFloat = 1,
            dividerActiveHeight: CGFloat = 38,
            dividerInactiveWidth: CGFloat = 1,
            dividerInactiveHeight: CGFloat = 38,
            dividerPaddingHorizontal: CGFloat = 0,
            dividerPaddingVertical: CGFloat = 0
        ) {
            self.height = height
            self.cornerRadius = cornerRadius
            self.spacing = spacing
            self.bottomPadding = bottomPadding
            self.titleFont = titleFont
            self.titleColor = AnyShapeStyle(titleColor)
            self.selectedTitleFont = selectedTitleFont
            self.selectedTitleColor = AnyShapeStyle(selectedTitleColor)
            self.subtitleFont = subtitleFont
            self.subtitleColor = AnyShapeStyle(subtitleColor)
            self.selectedSubtitleFont = selectedSubtitleFont
            self.selectedSubtitleColor = AnyShapeStyle(selectedSubtitleColor)
            self.priceFont = priceFont
            self.priceColor = AnyShapeStyle(priceColor)
            self.selectedPriceFont = selectedPriceFont
            self.selectedPriceColor = AnyShapeStyle(selectedPriceColor)
            self.borderColor = AnyShapeStyle(borderColor)
            self.selectedBorderColor = AnyShapeStyle(selectedBorderColor)
            self.borderWidth = borderWidth
            self.selectedBorderWidth = selectedBorderWidth
            self.backgroundColor = AnyShapeStyle(backgroundColor)
            self.selectedBackgroundColor = AnyShapeStyle(selectedBackgroundColor)
            self.showCheckmark = showCheckmark
            self.shadow = shadow
            self.selectedShadow = selectedShadow
            self.checkmarkSize = checkmarkSize
            self.checkmarkActiveBGColor = AnyShapeStyle(checkmarkActiveBGColor)
            self.checkmarkInactiveBGColor = AnyShapeStyle(checkmarkInactiveBGColor)
            self.checkmarkActiveColor = AnyShapeStyle(checkmarkActiveColor)
            self.checkmarkInactiveColor = AnyShapeStyle(checkmarkInactiveColor)
            self.checkmarkActiveBorderColor = AnyShapeStyle(checkmarkActiveBorderColor)
            self.checkmarkInactiveBorderColor = AnyShapeStyle(checkmarkInactiveBorderColor)
            self.checkmarkIconSize = checkmarkIconSize
            self.checkmarkIconWeight = checkmarkIconWeight
            self.showDivider = showDivider
            self.priceWidth = priceWidth
            self.dividerActiveColor = AnyShapeStyle(dividerActiveColor)
            self.dividerInactiveColor = AnyShapeStyle(dividerInactiveColor)
            self.dividerActiveWidth = dividerActiveWidth
            self.dividerActiveHeight = dividerActiveHeight
            self.dividerInactiveWidth = dividerInactiveWidth
            self.dividerInactiveHeight = dividerInactiveHeight
            self.dividerPaddingHorizontal = dividerPaddingHorizontal
            self.dividerPaddingVertical = dividerPaddingVertical
        }

        public static let `default` = Offer()
    }
}

// MARK: - ActionButton

extension SecondaryPaywallStyle {
    public struct ActionButton: Sendable {
        public var font: Font
        public var textColor: AnyShapeStyle
        public var backgroundColor: AnyShapeStyle
        public var cornerRadius: CGFloat
        public var height: CGFloat
        public var borderColor: AnyShapeStyle
        public var borderWidth: CGFloat
        public var showBorder: Bool
        public var showAnimation: Bool
        public var animationDuration: CGFloat
        public var animationScale: CGFloat
        public var bottomPadding: CGFloat

        public init(
            font: Font = .system(size: 20, weight: .bold),
            textColor: any ShapeStyle = Color.white,
            backgroundColor: any ShapeStyle = Color.blue,
            cornerRadius: CGFloat = 100,
            height: CGFloat = 56,
            borderColor: any ShapeStyle = Color.clear,
            borderWidth: CGFloat = 1,
            showBorder: Bool = false,
            showAnimation: Bool = false,
            animationDuration: CGFloat = 0.8,
            animationScale: CGFloat = 0.92,
            bottomPadding: CGFloat = 0
        ) {
            self.font = font
            self.textColor = AnyShapeStyle(textColor)
            self.backgroundColor = AnyShapeStyle(backgroundColor)
            self.cornerRadius = cornerRadius
            self.height = height
            self.borderColor = AnyShapeStyle(borderColor)
            self.borderWidth = borderWidth
            self.showBorder = showBorder
            self.showAnimation = showAnimation
            self.animationDuration = animationDuration
            self.animationScale = animationScale
            self.bottomPadding = bottomPadding
        }

        public static let `default` = ActionButton()
    }
}

// MARK: - Links

extension SecondaryPaywallStyle {
    public struct Links: Sendable {
        public var font: Font
        public var color: AnyShapeStyle
        public var spacing: CGFloat
        public var showDividers: Bool
        public var bottomPadding: CGFloat

        public init(
            font: Font = .system(size: 13, weight: .regular),
            color: any ShapeStyle = Color.secondary.opacity(0.3),
            spacing: CGFloat = 10,
            showDividers: Bool = true,
            bottomPadding: CGFloat = 0
        ) {
            self.font = font
            self.color = AnyShapeStyle(color)
            self.spacing = spacing
            self.showDividers = showDividers
            self.bottomPadding = bottomPadding
        }

        public static let `default` = Links()
    }
}

// MARK: - Layout

extension SecondaryPaywallStyle {
    public struct Layout: Sendable {
        public var contentSpacing: CGFloat
        public var horizontalPadding: CGFloat
        public var bottomPadding: CGFloat
        public var maxWidth: CGFloat
        public var contentOrder: [SecondaryPaywallContentElement]

        public init(
            contentSpacing: CGFloat = 12,
            horizontalPadding: CGFloat = 16,
            bottomPadding: CGFloat = 60,
            maxWidth: CGFloat = 744,
            contentOrder: [SecondaryPaywallContentElement] = [.title, .subtitle, .message, .offers]
        ) {
            self.contentSpacing = contentSpacing
            self.horizontalPadding = horizontalPadding
            self.bottomPadding = bottomPadding
            self.maxWidth = maxWidth
            self.contentOrder = contentOrder
        }

        public static let `default` = Layout()
    }
}

// MARK: - CloseButton

// MARK: - CloseButton

extension SecondaryPaywallStyle {
    public struct CloseButton: Sendable {
        public var icon: String
        public var color: AnyShapeStyle
        public var font: Font
        public var placement: CloseButtonPlacement
        public var showGlass: Bool
        public var showBackground: Bool
        public var backgroundColor: AnyShapeStyle

        public init(
            icon: String = "xmark",
            color: any ShapeStyle = Color.white,
            font: Font = .system(size: 12, weight: .regular),
            placement: CloseButtonPlacement = .topBarLeading,
            showGlass: Bool = true,
            showBackground: Bool = false,
            backgroundColor: any ShapeStyle = Color.clear
        ) {
            self.icon = icon
            self.color = AnyShapeStyle(color)
            self.font = font
            self.placement = placement
            self.showGlass = showGlass
            self.showBackground = showBackground
            self.backgroundColor = AnyShapeStyle(backgroundColor)
        }

        public static let `default` = CloseButton()
    }
}
