# Picker Paywall

Пейвол с сегментным пикером для переключения между продуктами.

## Overview

``PickerPaywallView`` — альтернативный UI для пейвола, заменяющий стандартный message + toggle/checkmark. Вместо них отображается сегментный пикер с двумя продуктами, бейдж "Trial" и секция с описанием периодов подписки.

Работает в ``OnboardingBuilder`` и ``SecondaryPaywallBuilder``.

## Как включить

Установите `toggleType: .picker` и передайте `pickerStyle`:

### В OnboardingBuilder

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    style: OnboardingStyle(
        toggleType: .picker,
        pickerStyle: PickerPaywallStyle(
            pickerBgColor: Color(.systemGray5),
            pickerSelectedBgColor: .white,
            pickerCornerRadius: 12,
            pickerHeight: 44,
            badgeBgColor: .red,
            badgeTextColor: .white,
            badgeCornerRadius: 10,
            periodTitleFont: .system(size: 17, weight: .bold),
            periodTitleColor: .primary,
            periodSubtitleFont: .system(size: 14),
            periodSubtitleColor: .secondary,
            pickerTodayTrialSubtitle: "Триал начнётся без списания",
            pickerTodayNonTrialSubtitle: "Полный доступ начинается сегодня",
            limitedFont: .system(size: 14),
            limitedColor: .secondary,
            todayIcon: AnyView(
                Image(systemName: "lock.fill")
                    .foregroundStyle(.red)
                    .frame(width: 40, height: 40)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            ),
            futureIcon: AnyView(
                Image(systemName: "bell.fill")
                    .foregroundStyle(.red)
                    .frame(width: 40, height: 40)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            )
        )
    ),
    onComplete: { }
)
```

### В SecondaryPaywallBuilder

```swift
SecondaryPaywallBuilder(
    paywallID: .init("secondary"),
    style: SecondaryPaywallStyle(
        messageToggle: .init(
            toggleType: .picker,
            pickerStyle: PickerPaywallStyle(
                pickerBgColor: Color(.systemGray5),
                pickerSelectedBgColor: .white,
                badgeBgColor: .orange,
                todayIcon: AnyView(myTodayIcon),
                futureIcon: AnyView(myFutureIcon)
            )
        )
    )
)
```

## PaywallToggleType

Энам определяет тип UI для переключения продуктов:

| Значение | Описание |
|----------|----------|
| `.checkmark` | Стандартный toggle/чекмарка рядом с сообщением (по умолчанию) |
| `.picker` | Сегментный пикер с периодами, бейджем и описанием |

## Структура Picker UI

Пикер отображает следующие элементы (сверху вниз):

1. **Segmented picker** — два сегмента: безтриальный период (слева) и триальный (справа); при двух продуктах одного типа — первый продукт слева, второй справа
2. **Trial badge** — бейдж "Trial" над каждым сегментом, чей продукт триальный (при двух триалах — над обоими, при двух безтриальных — нет)
3. **Period секция** — два блока с иконками:
   - **Today**: локализованный заголовок + "Enjoy unlimited access"
   - **In X days**: период продукта + условия автопродления
4. **Limited button** — кнопка "Or continue with limited version" из `paywall.buttons.limited`

Subtitle первой строки **Today** настраивается отдельно для выбранного продукта: `pickerTodayTrialSubtitle` используется для продукта с триалом, а `pickerTodayNonTrialSubtitle` — для продукта без триала. Если соответствующее значение не задано (`nil`), используется локализованная строка `picker.today.subtitle`. Настройка работает одинаково в ``OnboardingBuilder`` и ``SecondaryPaywallBuilder``.

## Два продукта одного типа (два триала / два безтриала)

Когда из Apphud приходят два триальных или два безтриальных продукта, пикер переключает **между этими двумя продуктами**:

- Первый продукт из JSON — **левый сегмент**, выбран по умолчанию (toggle/checkmark выключены).
- Второй продукт — правый сегмент, выбирается включением toggle/checkmark.
- Сегменты подписываются периодами своих продуктов, бейдж «Trial» — по `hasTrial` каждого продукта.
- Subtitle строки **Today** выбирается по выбранному продукту: триальная версия — для продукта с триалом, безтриальная — для продукта без него.

## Trial Expired

Если пользователь уже использовал триал, при нажатии на триальный сегмент (или toggle/checkmark) переключение блокируется и показывается локализованный алерт:

- **Title:** "Trial Unavailable"
- **Message:** "You've already used your free trial. You can subscribe without a trial period."

Проверка основана на `product.hasTrial` — если Apphud/StoreKit возвращает продукт без триала, значит триал уже использован. Работает для всех трёх типов toggle: native Toggle, checkmark, picker. Исключение — пара продуктов одного типа (два триала или два безтриальных): она переключается без проверки триала, алерт не показывается.

## PickerPaywallStyle — полный список параметров

### Picker

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `pickerBgColor` | `any ShapeStyle` | `Color(.systemGray5)` | Фон пикера |
| `pickerSelectedBgColor` | `any ShapeStyle` | `Color.white` | Фон выбранного сегмента |
| `pickerTextColor` | `any ShapeStyle` | `Color.primary` | Цвет текста |
| `pickerSelectedTextColor` | `any ShapeStyle` | `Color.primary` | Цвет текста выбранного |
| `pickerFont` | `Font` | `.system(size: 15, weight: .medium)` | Шрифт сегментов |
| `pickerCornerRadius` | `CGFloat` | `12` | Скругление пикера |
| `pickerHeight` | `CGFloat` | `44` | Высота пикера |
| `pickerSegmentPadding` | `CGFloat` | `3` | Внутренний отступ сегментов |
| `pickerBottomPadding` | `CGFloat` | `16` | Отступ снизу |

### Badge

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `badgeBgColor` | `any ShapeStyle` | `Color.red` | Фон бейджа |
| `badgeTextColor` | `any ShapeStyle` | `Color.white` | Цвет текста бейджа |
| `badgeFont` | `Font` | `.system(size: 12, weight: .semibold)` | Шрифт бейджа |
| `badgeCornerRadius` | `CGFloat` | `10` | Скругление бейджа |
| `badgeHorizontalPadding` | `CGFloat` | `8` | Горизонтальный паддинг |
| `badgeVerticalPadding` | `CGFloat` | `4` | Вертикальный паддинг |
| `badgeOffsetX` | `CGFloat` | `10` | Смещение по X |
| `badgeOffsetY` | `CGFloat` | `-10` | Смещение по Y |

### Period

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `periodTitleFont` | `Font` | `.system(size: 17, weight: .bold)` | Шрифт заголовка периода |
| `periodTitleColor` | `any ShapeStyle` | `Color.primary` | Цвет заголовка периода |
| `periodSubtitleFont` | `Font` | `.system(size: 14, weight: .regular)` | Шрифт описания периода |
| `periodSubtitleColor` | `any ShapeStyle` | `Color.secondary` | Цвет описания периода |
| `pickerTodayTrialSubtitle` | `String?` | `nil` | Subtitle строки Today для выбранного триального продукта; при `nil` используется `picker.today.subtitle` |
| `pickerTodayNonTrialSubtitle` | `String?` | `nil` | Subtitle строки Today для выбранного продукта без триала; при `nil` используется `picker.today.subtitle` |
| `periodIconSpacing` | `CGFloat` | `12` | Расстояние между иконкой и текстом |
| `periodContentSpacing` | `CGFloat` | `4` | Расстояние между заголовком и описанием |
| `periodSpacing` | `CGFloat` | `12` | Расстояние между строками периодов (Today / In X days) |
| `periodBottomPadding` | `CGFloat` | `12` | Нижний отступ секции периодов |

### Limited

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `limitedFont` | `Font` | `.system(size: 14, weight: .regular)` | Шрифт текста |
| `limitedColor` | `any ShapeStyle` | `Color.secondary` | Цвет текста |
| `limitedUnderline` | `Bool` | `false` | Подчёркивание текста |
| `limitedTopPadding` | `CGFloat` | `0` | Отступ сверху |
| `limitedBottomPadding` | `CGFloat` | `0` | Отступ снизу |
| `limitedIconPlaceholderWidth` | `CGFloat` | `40` | Ширина отступа слева (выравнивание по тексту периода) |

### Общие

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `contentSpacing` | `CGFloat` | `16` | Расстояние между основными блоками |
| `scaleFactor` | `CGFloat` | `1` | Масштаб всего пикер-компонента (0...1) |

### Иконки

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `todayIcon` | `AnyView` | `EmptyView()` | Иконка блока "Today" |
| `futureIcon` | `AnyView` | `EmptyView()` | Иконка блока "In X days" |

## Настройка Apphud JSON

### Для Picker (toggleType == .picker)

При использовании picker тексты периодов по умолчанию формируются из L10n ключей библиотеки — поля `subtitle` и `nonTrialSubtitle` продукта **игнорируются**. Subtitle строки Today можно отдельно заменить через `PickerPaywallStyle.pickerTodayTrialSubtitle` и `PickerPaywallStyle.pickerTodayNonTrialSubtitle`.

```json
{
  "products": [
    {
      "product_id": "weekly_trial",
      "subtitle": "onboarding.weekly_picker_trial",
      "nonTrialSubtitle": "onboarding.weekly_picker_nonTrial",
      "periodly": "onboarding.weekly_trial.periodly"
    },
    {
      "product_id": "weekly",
      "subtitle": "onboarding.weekly_picker_nonTrial",
      "periodly": "onboarding.weekly.periodly"
    }
  ]
}
```

Локализованные шаблоны:
- `onboarding.weekly_picker_trial` = "Subscribe to unlock all the features, just for %@ + %@ free trial"
- `onboarding.weekly_picker_nonTrial` = "Subscribe to unlock all the features, just for %@"

### Для Toggle / Checkmark

При обычном toggle/checkmark subtitle берётся из `product.paywallSubtitle`, который использует `subtitle` (для trial) и `nonTrialSubtitle` (без trial).

Формат с `%@` (рекомендуемый — цена подставляется автоматически):

```json
{
  "products": [
    {
      "product_id": "weekly_trial",
      "subtitle": "Subscribe to unlock all the features, just for %@ + %@ free trial",
      "nonTrialSubtitle": "Subscribe to unlock all the features, just for %@"
    },
    {
      "product_id": "weekly",
      "subtitle": "Subscribe to unlock all the features, just for %@",
      "nonTrialSubtitle": "Subscribe to unlock all the features, just for %@"
    }
  ]
}
```

- `%@` первый = `pricePerPeriod` (напр. "$4.99/week")
- `%@` второй = `period` (напр. "3 days")
- Результат: *"Subscribe to unlock all the features, just for $4.99/week + 3 days free trial"*

> Если `subtitle`/`nonTrialSubtitle` не содержит `%@`, цена приклеивается через пробел в конец.

## Локализация

Тексты периодов локализованы на 30 языков внутри библиотеки:

| Ключ | EN | RU |
|------|----|----|
| `picker.badge.trial` | Trial | Пробный |
| `picker.segment.trial` | 3 days | 3 дня |
| `picker.today` | Today | Сегодня |
| `picker.today.subtitle` | Enjoy unlimited access | Наслаждайтесь неограниченным доступом |
| `picker.future.title` | In %@ | Через %@ |
| `picker.future.subtitle.trial` | Subscription auto-renews at %@ after the %@ trial. Cancel anytime | Подписка автоматически продлевается за %@ после пробного периода %@. Отмена в любое время |
| `picker.future.subtitle.nonTrial` | Subscription auto-renews at %@. Cancel anytime | Подписка автоматически продлевается за %@. Отмена в любое время |
| `alert.trial_expired.title` | Trial Unavailable | Пробный период недоступен |
| `alert.trial_expired.message` | You've already used your free trial... | Вы уже использовали бесплатный пробный период... |

Текст "Or continue with limited version" берётся из `paywall.buttons.limited` (настраивается в Apphud JSON, ключ `limitedButton`).

## Topics

### Related

- ``OnboardingBuilder``
- ``SecondaryPaywallBuilder``
- <doc:Customization-Article>
- <doc:Localization-Article>
- <doc:ApphudJSON>
