import SwiftUI

struct PickerPaywallView: View {
    let products: [PremiumProduct]
    @Binding var isTrialEnabled: Bool
    let limitedButtonText: String
    let style: PickerPaywallStyle
    var isSecondaryStep: Bool = false
    var secondaryPaywallPickerSubtitle: SecondaryPaywallPickerSubtitle?
    let onTrialToggle: (Bool) -> Void
    let onLimitedTapped: () -> Void

    private var selectedProduct: PremiumProduct? {
        guard let pair = products.togglePair else { return products.first }
        return isTrialEnabled ? pair.on : pair.off
    }

    /// Продукт правого сегмента (положение тоггла «вкл»): триальный при
    /// смешанном наборе, второй — когда продукты одного типа
    private var onProduct: PremiumProduct? {
        products.togglePair?.on
    }

    /// Продукт левого сегмента (положение тоггла «выкл», выбран по умолчанию):
    /// безтриальный при смешанном наборе, первый — когда продукты одного типа
    private var offProduct: PremiumProduct? {
        products.togglePair?.off
    }

    private var todaySubtitle: String {
        let isSelectedTrial = selectedProduct?.hasTrial ?? isTrialEnabled
        if isSecondaryStep, let subtitle = secondaryPaywallPickerSubtitle {
            let customSubtitle = isSelectedTrial
                ? secondaryPaywallPickerSubtitle?.todayTrial
                : secondaryPaywallPickerSubtitle?.todayNonTrial
            return customSubtitle ?? L10n.localized("picker.today.subtitle")
        }
        let customSubtitle = isSelectedTrial
            ? style.pickerTodayTrialSubtitle
            : style.pickerTodayNonTrialSubtitle
        return customSubtitle ?? L10n.localized("picker.today.subtitle")
    }

    var body: some View {
        VStack(spacing: style.contentSpacing) {
            pickerSection
            periodSection
        }
        .scaleEffect(style.scaleFactor)
    }

    // MARK: - Picker

    @ViewBuilder
    private var pickerSection: some View {
        HStack(spacing: 0) {
            pickerSegment(
                title: offProduct?.period ?? "",
                isSelected: !isTrialEnabled
            ) {
                onTrialToggle(false)
            }

            pickerSegment(
                title: onProduct?.pickerDuration ?? L10n.localized("picker.segment.trial"),
                isSelected: isTrialEnabled
            ) {
                onTrialToggle(true)
            }
        }
        .frame(height: style.pickerHeight)
        .frame(maxWidth: style.pickerMaxWidth)
        .background(
            RoundedRectangle(cornerRadius: style.pickerCornerRadius)
                .fill(style.pickerBgColor)
        )
        // Бейдж правого сегмента — когда его продукт триальный
        .overlay(alignment: .topTrailing) {
            if onProduct?.hasTrial == true {
                trialBadge
                    .offset(x: style.badgeOffsetX, y: style.badgeOffsetY)
            }
        }
        // Бейдж левого сегмента — когда оба продукта триальные
        .overlay(alignment: .topLeading) {
            if offProduct?.hasTrial == true {
                trialBadge
                    .offset(x: -style.badgeOffsetX, y: style.badgeOffsetY)
            }
        }
        .padding(.bottom, style.pickerBottomPadding)
    }

    private func pickerSegment(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(style.pickerFont)
                .foregroundStyle(isSelected ? style.pickerSelectedTextColor : style.pickerTextColor)
                .frame(maxWidth: UIDevice.isIpad ? 213 : 135)
                .frame(height: style.pickerHeight - style.pickerSegmentPadding * 2)
                .background(
                    RoundedRectangle(cornerRadius: style.pickerCornerRadius - style.pickerSegmentPadding)
                        .fill(isSelected ? style.pickerSelectedBgColor : AnyShapeStyle(Color.clear))
                )
        }
        .padding(style.pickerSegmentPadding)
    }

    private var trialBadge: some View {
        Text(L10n.localized("picker.badge.trial"))
            .font(style.badgeFont)
            .foregroundStyle(style.badgeTextColor)
            .padding(.horizontal, style.badgeHorizontalPadding)
            .padding(.vertical, style.badgeVerticalPadding)
            .background(
                RoundedRectangle(cornerRadius: style.badgeCornerRadius)
                    .fill(style.badgeBgColor)
            )
    }

    // MARK: - Period

    @ViewBuilder
    private var periodSection: some View {
        VStack(alignment: .leading, spacing: style.periodSpacing) {
            periodRow(
                icon: style.todayIcon,
                title: L10n.localized("picker.today"),
                subtitle: todaySubtitle,
                price: ""
            )

            periodRow(
                icon: style.futureIcon,
                title: futureTitle,
                subtitle: futureSubtitle,
                price: selectedProduct?.pricePerPeriod ?? "",
                bottomContent: !limitedButtonText.isEmpty ? AnyView(
                    Button(action: onLimitedTapped) {
                        Text(limitedButtonText)
                            .font(style.limitedFont)
                            .foregroundStyle(style.limitedColor)
                            .underline(style.limitedUnderline)
                    }
                    .padding(.top, style.limitedTopPadding)
                    .padding(.bottom, style.limitedBottomPadding)
                ) : nil
            )
        }
        .padding(.bottom, style.periodBottomPadding)
    }

    private func periodRow(icon: AnyView, title: String, subtitle: String, price: String, bottomContent: AnyView? = nil) -> some View {
        HStack(alignment: .top, spacing: style.periodIconSpacing) {
            icon

            VStack(alignment: .leading, spacing: style.periodContentSpacing) {
                Text(title)
                    .font(style.periodTitleFont)
                    .foregroundStyle(style.periodTitleColor)

                VStack(alignment: .leading, spacing: 0) {
                    Text(attributedSubtitle(sub: subtitle, price: price))
                        .font(style.periodSubtitleFont)
                        .foregroundStyle(style.periodSubtitleColor)
                        .fixedSize(horizontal: false, vertical: true)

                    if let bottomContent {
                        bottomContent
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func attributedSubtitle(sub: String, price: String) -> AttributedString {
        var result = AttributedString(sub)

        if !price.isEmpty, let range = result.range(of: price) {
            if style.priceCustomization?.contains(.heavy) == true {
                result[range].font = style.periodSubtitleFont.weight(.heavy)
            }
            if style.priceCustomization?.contains(.underline) == true {
                result[range].underlineStyle = .single
            }
            if let f = style.priceCustomizationFont { result[range].font = f }
            if let c = style.priceCustomizationColor { result[range].foregroundColor = c }
        }

        return result
    }

    // MARK: - Computed Texts

    private var futureTitle: String {
        guard let product = selectedProduct else { return "" }
        return L10n.localized("picker.future.title", product.pickerDuration)
    }

    private var futureSubtitle: String {
        guard let product = selectedProduct else { return "" }
        if product.hasTrial {
            return L10n.localized("picker.future.subtitle.trial", product.pricePerPeriod, product.pickerDuration)
        } else {
            return L10n.localized("picker.future.subtitle.nonTrial", product.pricePerPeriod)
        }
    }
}
