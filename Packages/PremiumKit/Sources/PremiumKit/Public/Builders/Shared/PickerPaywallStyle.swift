import SwiftUI

public struct PickerPaywallStyle {
    // MARK: - Picker
    public var pickerBgColor: AnyShapeStyle
    public var pickerSelectedBgColor: AnyShapeStyle
    public var pickerTextColor: AnyShapeStyle
    public var pickerSelectedTextColor: AnyShapeStyle
    public var pickerFont: Font
    public var pickerCornerRadius: CGFloat
    public var pickerHeight: CGFloat
    public var pickerSegmentPadding: CGFloat
    public var pickerBottomPadding: CGFloat
    public var pickerMaxWidth: CGFloat?

    // MARK: - Badge
    public var badgeBgColor: AnyShapeStyle
    public var badgeTextColor: AnyShapeStyle
    public var badgeFont: Font
    public var badgeCornerRadius: CGFloat
    public var badgeHorizontalPadding: CGFloat
    public var badgeVerticalPadding: CGFloat
    public var badgeOffsetX: CGFloat
    public var badgeOffsetY: CGFloat

    // MARK: - Period
    public var periodTitleFont: Font
    public var periodTitleColor: AnyShapeStyle
    public var periodSubtitleFont: Font
    public var periodSubtitleColor: AnyShapeStyle
    public var pickerTodayTrialSubtitle: String?
    public var pickerTodayNonTrialSubtitle: String?
    public var periodIconSpacing: CGFloat
    public var periodContentSpacing: CGFloat
    public var periodSpacing: CGFloat
    public var periodBottomPadding: CGFloat

    // MARK: - Price
    public var priceCustomization: PriceCustomization?
    public var priceCustomizationFont: Font?
    public var priceCustomizationColor: Color?

    // MARK: - Limited
    public var limitedFont: Font
    public var limitedColor: AnyShapeStyle
    public var limitedUnderline: Bool
    public var limitedTopPadding: CGFloat
    public var limitedBottomPadding: CGFloat
    public var limitedIconPlaceholderWidth: CGFloat

    // MARK: - General
    public var contentSpacing: CGFloat
    public var scaleFactor: CGFloat

    // MARK: - Icons
    public var todayIcon: AnyView
    public var futureIcon: AnyView

    public init(
        pickerBgColor: any ShapeStyle = Color(.systemGray5),
        pickerSelectedBgColor: any ShapeStyle = Color.white,
        pickerTextColor: any ShapeStyle = Color.primary,
        pickerSelectedTextColor: any ShapeStyle = Color.primary,
        pickerFont: Font = .system(size: 15, weight: .medium),
        pickerCornerRadius: CGFloat = 12,
        pickerHeight: CGFloat = 44,
        pickerSegmentPadding: CGFloat = 3,
        pickerBottomPadding: CGFloat = 16,
        pickerMaxWidth: CGFloat? = nil,
        badgeBgColor: any ShapeStyle = Color.red,
        badgeTextColor: any ShapeStyle = Color.white,
        badgeFont: Font = .system(size: 12, weight: .semibold),
        badgeCornerRadius: CGFloat = 10,
        badgeHorizontalPadding: CGFloat = 8,
        badgeVerticalPadding: CGFloat = 4,
        badgeOffsetX: CGFloat = 10,
        badgeOffsetY: CGFloat = -10,
        periodTitleFont: Font = .system(size: 17, weight: .bold),
        periodTitleColor: any ShapeStyle = Color.primary,
        periodSubtitleFont: Font = .system(size: 14, weight: .regular),
        periodSubtitleColor: any ShapeStyle = Color.secondary,
        pickerTodayTrialSubtitle: String? = nil,
        pickerTodayNonTrialSubtitle: String? = nil,
        periodIconSpacing: CGFloat = 12,
        periodContentSpacing: CGFloat = 4,
        periodSpacing: CGFloat = 12,
        periodBottomPadding: CGFloat = 12,
        priceCustomization: PriceCustomization? = nil,
        priceCustomizationFont: Font? = nil,
        priceCustomizationColor: Color? = nil,
        limitedFont: Font = .system(size: 14, weight: .regular),
        limitedColor: any ShapeStyle = Color.secondary,
        limitedUnderline: Bool = false,
        limitedTopPadding: CGFloat = 0,
        limitedBottomPadding: CGFloat = 0,
        limitedIconPlaceholderWidth: CGFloat = 40,
        contentSpacing: CGFloat = 16,
        scaleFactor: CGFloat = 1,
        todayIcon: AnyView = AnyView(EmptyView()),
        futureIcon: AnyView = AnyView(EmptyView())
    ) {
        self.pickerBgColor = AnyShapeStyle(pickerBgColor)
        self.pickerSelectedBgColor = AnyShapeStyle(pickerSelectedBgColor)
        self.pickerTextColor = AnyShapeStyle(pickerTextColor)
        self.pickerSelectedTextColor = AnyShapeStyle(pickerSelectedTextColor)
        self.pickerFont = pickerFont
        self.pickerCornerRadius = pickerCornerRadius
        self.pickerHeight = pickerHeight
        self.pickerSegmentPadding = pickerSegmentPadding
        self.pickerBottomPadding = pickerBottomPadding
        self.pickerMaxWidth = pickerMaxWidth
        self.badgeBgColor = AnyShapeStyle(badgeBgColor)
        self.badgeTextColor = AnyShapeStyle(badgeTextColor)
        self.badgeFont = badgeFont
        self.badgeCornerRadius = badgeCornerRadius
        self.badgeHorizontalPadding = badgeHorizontalPadding
        self.badgeVerticalPadding = badgeVerticalPadding
        self.badgeOffsetX = badgeOffsetX
        self.badgeOffsetY = badgeOffsetY
        self.periodTitleFont = periodTitleFont
        self.periodTitleColor = AnyShapeStyle(periodTitleColor)
        self.periodSubtitleFont = periodSubtitleFont
        self.periodSubtitleColor = AnyShapeStyle(periodSubtitleColor)
        self.pickerTodayTrialSubtitle = pickerTodayTrialSubtitle
        self.pickerTodayNonTrialSubtitle = pickerTodayNonTrialSubtitle
        self.periodIconSpacing = periodIconSpacing
        self.periodContentSpacing = periodContentSpacing
        self.periodSpacing = periodSpacing
        self.periodBottomPadding = periodBottomPadding
        self.priceCustomization = priceCustomization
        self.priceCustomizationFont = priceCustomizationFont
        self.priceCustomizationColor = priceCustomizationColor
        self.limitedFont = limitedFont
        self.limitedColor = AnyShapeStyle(limitedColor)
        self.limitedUnderline = limitedUnderline
        self.limitedTopPadding = limitedTopPadding
        self.limitedBottomPadding = limitedBottomPadding
        self.limitedIconPlaceholderWidth = limitedIconPlaceholderWidth
        self.contentSpacing = contentSpacing
        self.scaleFactor = scaleFactor
        self.todayIcon = todayIcon
        self.futureIcon = futureIcon
    }
}

public struct SecondaryPaywallPickerSubtitle: Sendable {
    public let todayTrial: String
    public let todayNonTrial: String
    
    public init(
        todayTrial: String,
        todayNonTrial: String
    ) {
        self.todayTrial = todayTrial
        self.todayNonTrial = todayNonTrial
    }
}
