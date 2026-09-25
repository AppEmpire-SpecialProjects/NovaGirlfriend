# Customization

Полный список параметров для кастомизации билдеров.

## Overview

PremiumKit предоставляет гибкую систему стилей для полной кастомизации внешнего вида.

## Цвета и градиенты

Все цветовые параметры принимают любой `ShapeStyle` — можно передавать как обычные цвета, так и градиенты напрямую:

```swift
// Обычный цвет
backgroundColor: .black
titleColor: .white
subtitleColor: Color.secondary.opacity(0.6)

// Линейный градиент
buttonBackgroundColor: LinearGradient(
    colors: [.pink, .purple],
    startPoint: .leading,
    endPoint: .trailing
)

// Радиальный градиент
title2Color: RadialGradient(
    colors: [.yellow, .orange],
    center: .center,
    startRadius: 0,
    endRadius: 100
)

// Угловой градиент
indicatorActiveColor: AngularGradient(
    colors: [.red, .blue, .green],
    center: .center
)
```

## OnboardingStyle

### Content Order

Порядок отображения элементов контента:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `contentOrder` | `[OnboardingContentElement]` | `[.indicators, .title, .subtitle, .message]` | Порядок элементов |

```swift
// Свой порядок элементов
contentOrder: [.title, .subtitle, .indicators, .message]
```

Доступные элементы `OnboardingContentElement`:
- `.indicators` — индикаторы прогресса
- `.title` — заголовок (title1 + title2)
- `.subtitle` — подзаголовок
- `.message` — сообщение с toggle

### Price Customization

Кастомизация отображения цены в подзаголовке пейвола:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `priceCustomization` | `PriceCustomization?` | `nil` | Стилизация цены |
| `priceCustomizationFont` | `Font?` | `nil` | Шрифт цены |
| `priceCustomizationColor` | `Color?` | `nil` | Цвет цены |
| `limitedButtonUnderline` | `Bool` | `false` | Подчёркивание кнопки Limited |
| `limitedButtonFont` | `Font?` | `nil` | Шрифт кнопки Limited (fallback — `subtitleFont`) |
| `limitedButtonColor` | `(any ShapeStyle)?` | `nil` | Цвет кнопки Limited (fallback — `subtitleColor`) |

```swift
// Жирная цена с подчёркиванием
priceCustomization: [.heavy, .underline]

// Только жирная
priceCustomization: .heavy

// Только подчёркивание
priceCustomization: .underline

// Свой шрифт и цвет цены
priceCustomizationFont: .system(size: 15, weight: .bold),
priceCustomizationColor: .red

// Кнопка "Limited version": подчёркивание, свой шрифт и цвет
limitedButtonUnderline: true,
limitedButtonFont: .system(size: 15, weight: .semibold),
limitedButtonColor: Color.secondary.opacity(0.6)
```

Доступные опции `PriceCustomization`:
- `.heavy` — жирный шрифт для цены
- `.underline` — подчёркивание цены

### Split Subtitle

Разбивает подзаголовок по индексу слова и стилизует части до и от слова (включая само слово) по-разному. Полезно для визуального разделения текста под требования App Store review:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `splitSubtitleBy` | `Int?` | `nil` | Индекс слова, по которому делится подзаголовок |
| `subtitleBeforeFont` | `Font?` | `nil` | Шрифт части до слова (`words[0..<index]`) |
| `subtitleBeforeColor` | `Color?` | `nil` | Цвет части до слова |
| `subtitleAfterFont` | `Font?` | `nil` | Шрифт части от слова включительно (`words[index...]`) |
| `subtitleAfterColor` | `Color?` | `nil` | Цвет части от слова включительно |

```swift
// "Unlimited access to all premium features"
//  слова:  0        1      2  3   4       5
// splitSubtitleBy: 2 -> до = "Unlimited access", от = "to all premium features"
splitSubtitleBy: 2,
subtitleBeforeFont: .system(size: 15, weight: .regular),
subtitleBeforeColor: Color.secondary.opacity(0.4),
subtitleAfterFont: .system(size: 15, weight: .semibold),
subtitleAfterColor: Color.secondary.opacity(0.9)
```

> Note: Split-стилизация применяется первой, затем поверх накладывается `priceCustomization` для диапазона цены (если цена присутствует в подзаголовке).


### Content Background

Фоновая подложка под UI элементами:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `contentBackgroundShow` | `Bool` | `false` | Показывать фон |
| `contentBackgroundColor` | `any ShapeStyle` | `Color.white` | Цвет фона |
| `contentBackgroundCornerRadius` | `CGFloat` | `32` | Скругление верхних углов |
| `contentBackgroundBorderColor` | `any ShapeStyle` | `Color.clear` | Цвет бордера |
| `contentBackgroundBorderWidth` | `CGFloat` | `0.5` | Толщина бордера |
| `contentBackgroundShadow` | `ContentBackgroundShadow?` | `nil` | Тень (см. ниже) |
| `contentBackgroundPadding` | `BackgroundPadding` | `BackgroundPadding()` | Отступы фона от краёв |

#### ContentBackgroundShadow

```swift
ContentBackgroundShadow(
    color: .black.opacity(0.2),
    radius: 10,
    x: 0,
    y: 0
)
```

#### BackgroundPadding

Отступы фона от краёв экрана. При наличии отступов фон использует скругление всех углов:

```swift
BackgroundPadding(
    horizontal: 20,  // Горизонтальные отступы
    bottom: 20       // Нижний отступ
)
```

### Цвета

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `toggleColor` | `Color` | `.blue` | Акцентный цвет (Toggle) |
| `backgroundColor` | `any ShapeStyle` | `Color.white` | Фон экрана |
| `title1Color` | `any ShapeStyle` | `Color.blue` | Цвет первой строки |
| `title2Color` | `any ShapeStyle` | `Color.black` | Цвет второй строки |
| `subtitleColor` | `any ShapeStyle` | `Color.secondary.opacity(0.6)` | Цвет подзаголовка |
| `messageColor` | `any ShapeStyle` | `Color.black` | Цвет сообщения |
| `messageBackgroundColor` | `any ShapeStyle` | `Color.secondary.opacity(0.2)` | Фон сообщения |
| `buttonTextColor` | `any ShapeStyle` | `Color.white` | Цвет текста кнопки |
| `buttonBackgroundColor` | `any ShapeStyle` | `Color.blue` | Фон кнопки |
| `linksColor` | `any ShapeStyle` | `Color.secondary.opacity(0.3)` | Цвет ссылок |
| `indicatorActiveColor` | `any ShapeStyle` | `Color.blue` | Цвет активного индикатора |
| `indicatorInactiveColor` | `any ShapeStyle` | `Color.blue.opacity(0.2)` | Цвет прошедших индикаторов |
| `indicatorFutureColor` | `any ShapeStyle` | `Color.blue.opacity(0.2)` | Цвет будущих индикаторов |
| `indicatorCornerRadius` | `CGFloat` | `100` | Радиус углов индикаторов: `100` — капсула, `0` — квадратные |
| `indicatorBackgroundColor` | `any ShapeStyle` | `Color.clear` | Фон всей области индикаторов |
| `indicatorBackgroundCornerRadius` | `CGFloat` | `0` | Радиус скругления фона индикаторов |

### Шрифты

| Параметр | По умолчанию |
|----------|--------------|
| `titleFont` | `.system(size: 26, weight: .heavy)` |
| `subtitleFont` | `.system(size: 15, weight: .regular)` |
| `messageFont` | `.system(size: 15, weight: .regular)` |
| `buttonFont` | `.system(size: 20, weight: .bold)` |
| `linksFont` | `.system(size: 13, weight: .regular)` |

### Fixed Size (заголовок / подзаголовок)

По умолчанию текст может сжиматься (`minimumScaleFactor`). Флаги `fixedSize` фиксируют размер текста по контенту, запрещая вертикальное сжатие (полезно для многострочного текста, который обрезается):

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `titleFixedSize` | `Bool` | `false` | Фиксированный размер заголовка |
| `subtitleFixedSize` | `Bool` | `false` | Фиксированный размер подзаголовка |

```swift
OnboardingStyle(
    titleFixedSize: true,
    subtitleFixedSize: true
)
```

### Размеры

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `messageHeight` | `48` | Высота сообщения |
| `messageCornerRadius` | `100` | Скругление сообщения |
| `messageBorderColor` | `Color.gray` | Цвет бордера сообщения |
| `messageBorderWidth` | `1` | Толщина бордера сообщения |
| `buttonHeight` | `56` | Высота кнопки |
| `buttonCornerRadius` | `100` | Скругление кнопки |
| `contentSpacing` | `16` | Отступ между элементами |
| `horizontalPadding` | `16` | Горизонтальные отступы |
| `bottomPadding` | `20` | Нижний отступ |

### Bottom Padding

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `indicatorsBottomPadding` | `0` | Отступ снизу прогресс индикаторов |
| `titleBottomPadding` | `0` | Отступ снизу заголовка |
| `subtitleBottomPadding` | `0` | Отступ снизу подзаголовка |
| `messageBottomPadding` | `0` | Отступ снизу сообщения |
| `buttonBottomPadding` | `0` | Отступ снизу кнопки |
| `linksBottomPadding` | `0` | Отступ снизу ссылок |

### Индикаторы

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `indicatorActiveWidth` | `24` | Ширина активного |
| `indicatorInactiveWidth` | `6` | Ширина неактивного |
| `indicatorHeight` | `6` | Высота (базовая) |
| `indicatorActiveHeight` | `indicatorHeight` | Высота активного |
| `indicatorInactiveHeight` | `indicatorHeight` | Высота неактивного |
| `indicatorCornerRadius` | `100` | Радиус углов индикаторов: 100 — капсула, 0 — квадратные |
| `indicatorSpacing` | `4` | Отступ между индикаторами |
| `indicatorBackgroundColor` | `Color.clear` | Фон области индикаторов; принимает любой `ShapeStyle` |
| `indicatorBackgroundCornerRadius` | `0` | Радиус скругления фона индикаторов |
| `indicatorHorizontalPadding` | `0` | Горизонтальный внутренний отступ области с фоном |
| `indicatorVerticalPadding` | `0` | Вертикальный внутренний отступ области с фоном |

```swift
OnboardingStyle(
    indicatorBackgroundColor: Color.black.opacity(0.15),
    indicatorBackgroundCornerRadius: 12,
    indicatorHorizontalPadding: 16,
    indicatorVerticalPadding: 8
)
```

### Ссылки

| Параметр | По умолчанию |
|----------|--------------|
| `linksSpacing` | `10` |
| `linksShowDividers` | `true` |

### Checkmark (showNewToggle)

Если `showNewToggle: true` — вместо нативного Toggle показывается кастомная чекмарка:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `showNewToggle` | `Bool` | `false` | Показать чекмарку вместо Toggle |
| `checkmarkSize` | `CGFloat` | `22` | Размер круга |
| `checkmarkActiveBGColor` | `any ShapeStyle` | `Color.blue` | Фон активной |
| `checkmarkInactiveBGColor` | `any ShapeStyle` | `Color.clear` | Фон неактивной |
| `checkmarkActiveColor` | `any ShapeStyle` | `Color.white` | Цвет галочки |
| `checkmarkInactiveColor` | `any ShapeStyle` | `Color.clear` | Цвет неактивной |
| `checkmarkActiveBorderColor` | `any ShapeStyle` | `Color.secondary.opacity(0.3)` | Бордер активной |
| `checkmarkInactiveBorderColor` | `any ShapeStyle` | `Color.clear` | Бордер неактивной |
| `checkmarkIconSize` | `CGFloat` | `14` | Размер иконки галочки |
| `checkmarkIconWeight` | `Font.Weight` | `.semibold` | Вес иконки |

### Picker Paywall (toggleType: .picker)

Если `toggleType: .picker` — вместо message + toggle/checkmark показывается сегментный пикер с периодами. Подробнее: <doc:PickerPaywall-Article>.

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `toggleType` | `PaywallToggleType` | `.checkmark` | Тип переключателя продуктов |
| `pickerStyle` | `PickerPaywallStyle?` | `nil` | Стиль пикер-пейвола |

### Анимация кнопки (showPaywallButtonAnimation)

Плавная пульсация кнопки покупки (scale 1.0 → 0.92):

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `showPaywallButtonAnimation` | `Bool` | `true` (Onboarding) / `false` (Paywall) | Включить пульсацию кнопки |
| `showButtonAnimationAlways` | `Bool` | `false` | Только `OnboardingStyle`: анимация на всех шагах, а не только на пейвол-шаге |
| `buttonAnimationDuration` | `CGFloat` | `0.8` | Длительность одного цикла (секунды) |
| `buttonAnimationScale` | `CGFloat` | `0.92` | Минимальный масштаб при пульсации |

В `OnboardingBuilder` анимация по умолчанию активна только на пейвол-шаге. В `SecondaryPaywallStyle` параметр называется `button.showAnimation` (по умолчанию `false`).

```swift
OnboardingStyle(
    showPaywallButtonAnimation: true,
    showButtonAnimationAlways: true,
    buttonAnimationDuration: 0.8,
    buttonAnimationScale: 0.92
)

PaywallStyle(
    showPaywallButtonAnimation: true,
    buttonAnimationDuration: 0.8,
    buttonAnimationScale: 0.92
)
```

### Hide Content (per-screen)

Скрытие элементов задаётся не в стиле, а в каждом `OnboardingScreen` через параметр `hideContent`:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `hideContent` | `[OnboardingContentElement]` | `[]` | Элементы для скрытия на данном экране |

```swift
OnboardingScreen(
    id: 0,
    title1: "Welcome",
    subtitle: "Get started",
    images: AdaptiveResources(iphone: .onb1),
    hideContent: [.indicators, .message, .button]
)
```

Доступны `.indicators`, `.title`, `.subtitle`, `.message` и `.button`. Значение `.button` скрывает основную кнопку перехода только на выбранном экране. Для пейвол-шагов тот же элемент можно передать в `paywallHideContent` у `OnboardingBuilder`.

### Полный пример OnboardingStyle

```swift
OnboardingStyle(
    backgroundColor: .black,
    contentBackgroundShow: true,
    contentBackgroundColor: Color(red: 0.9, green: 0.95, blue: 1.0),
    contentBackgroundCornerRadius: 32,
    contentBackgroundBorderColor: Color.clear,
    contentBackgroundBorderWidth: 0.5,
    contentBackgroundShadow: nil,
    titleFont: .system(size: 26, weight: .heavy),
    title1Color: .black,
    title2Color: LinearGradient(
        colors: [.pink, .purple],
        startPoint: .leading,
        endPoint: .trailing
    ),
    titleBottomPadding: 0,
    subtitleFont: .system(size: 15, weight: .regular),
    subtitleColor: Color.secondary.opacity(0.6),
    subtitleBottomPadding: 0,
    messageFont: .system(size: 15, weight: .regular),
    messageColor: .black,
    messageBackgroundColor: Color.secondary.opacity(0.1),
    messageHeight: 48,
    messageCornerRadius: 100,
    messageBorderColor: Color.gray.opacity(0.3),
    messageBorderWidth: 1,
    messageBottomPadding: 0,
    buttonFont: .system(size: 20, weight: .bold),
    buttonTextColor: .white,
    buttonBackgroundColor: LinearGradient(
        colors: [.pink, .purple],
        startPoint: .leading,
        endPoint: .trailing
    ),
    buttonCornerRadius: 100,
    buttonHeight: 56,
    buttonBottomPadding: 0,
    linksFont: .system(size: 13, weight: .regular),
    linksColor: Color.secondary.opacity(0.3),
    linksSpacing: 10,
    linksShowDividers: true,
    linksBottomPadding: 0,
    contentSpacing: 20,
    horizontalPadding: 16,
    bottomPadding: 20,
    indicatorActiveColor: LinearGradient(
        colors: [.pink, .purple],
        startPoint: .leading,
        endPoint: .trailing
    ),
    indicatorInactiveColor: Color.pink.opacity(0.2),
    indicatorFutureColor: Color.pink.opacity(0.2),
    indicatorActiveWidth: 24,
    indicatorInactiveWidth: 6,
    indicatorHeight: 6,
    indicatorActiveHeight: 6,
    indicatorInactiveHeight: 6,
    indicatorSpacing: 4,
    indicatorBackgroundColor: Color.black.opacity(0.15),
    indicatorBackgroundCornerRadius: 12,
    indicatorHorizontalPadding: 16,
    indicatorVerticalPadding: 8
)
```

## PaywallStyle

### TitleOrder

Порядок отображения заголовка и подзаголовка:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `titleOrder` | `TitleOrder` | `.subtitleFirst` | Порядок title/subtitle |

```swift
// Сначала subtitle, потом title (по умолчанию)
titleOrder: .subtitleFirst

// Сначала title, потом subtitle
titleOrder: .titleFirst
```

### Content Background

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `contentBackgroundShow` | `Bool` | `false` | Показывать фон |
| `contentBackgroundColor` | `any ShapeStyle` | `Color.white` | Цвет фона |
| `contentBackgroundCornerRadius` | `CGFloat` | `32` | Скругление верхних углов |
| `contentBackgroundBorderColor` | `any ShapeStyle` | `Color.clear` | Цвет бордера |
| `contentBackgroundBorderWidth` | `CGFloat` | `0.5` | Толщина бордера |
| `contentBackgroundShadow` | `ContentBackgroundShadow?` | `nil` | Тень |
| `contentBackgroundPadding` | `BackgroundPadding` | `BackgroundPadding()` | Отступы фона от краёв |

### Цвета

| Параметр | Тип | По умолчанию |
|----------|-----|--------------|
| `accentColor` | `Color` | `.blue` |
| `backgroundColor` | `any ShapeStyle` | `Color.white` |
| `titleColor` | `any ShapeStyle` | `Color.black` |
| `subtitleColor` | `any ShapeStyle` | `Color.black.opacity(0.6)` |
| `buttonTextColor` | `any ShapeStyle` | `Color.white` |
| `buttonBackgroundColor` | `any ShapeStyle` | `Color.blue` |
| `linksColor` | `any ShapeStyle` | `Color.secondary.opacity(0.3)` |

### Шрифты

| Параметр | По умолчанию |
|----------|--------------|
| `titleFont` | `.system(size: 28, weight: .bold)` |
| `subtitleFont` | `.system(size: 13, weight: .regular)` |
| `buttonFont` | `.system(size: 17, weight: .semibold)` |
| `linksFont` | `.system(size: 13, weight: .regular)` |

### Fixed Size (заголовок / подзаголовок)

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `titleFixedSize` | `Bool` | `false` | Фиксированный размер заголовка |
| `subtitleFixedSize` | `Bool` | `false` | Фиксированный размер подзаголовка |

### Размеры

| Параметр | По умолчанию |
|----------|--------------|
| `buttonHeight` | `56` |
| `buttonCornerRadius` | `100` |
| `contentSpacing` | `12` |
| `horizontalPadding` | `16` |
| `bottomPadding` | `60` |

### Bottom Padding

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `titleBottomPadding` | `0` | Отступ снизу заголовка |
| `subtitleBottomPadding` | `0` | Отступ снизу подзаголовка |
| `offersBottomPadding` | `0` | Отступ снизу офферов |
| `buttonBottomPadding` | `0` | Отступ снизу кнопки |
| `linksBottomPadding` | `0` | Отступ снизу ссылок |

### Offers

| Параметр | Тип | По умолчанию |
|----------|-----|--------------|
| `offerHeight` | `CGFloat` | `54` |
| `offerCornerRadius` | `CGFloat` | `14` |
| `offerSpacing` | `CGFloat` | `4` |
| `offerTitleFont` | `Font` | `.system(size: 15, weight: .bold)` |
| `offerTitleColor` | `any ShapeStyle` | `Color.black` |
| `offerSelectedTitleColor` | `any ShapeStyle` | `Color.black` |
| `offerSubtitleFont` | `Font` | `.system(size: 13, weight: .regular)` |
| `offerSubtitleColor` | `any ShapeStyle` | `Color.black.opacity(0.6)` |
| `offerSelectedSubtitleColor` | `any ShapeStyle` | `Color.black.opacity(0.6)` |
| `offerPriceFont` | `Font` | `.system(size: 15, weight: .bold)` |
| `offerPriceColor` | `any ShapeStyle` | `Color.black` |
| `offerSelectedPriceColor` | `any ShapeStyle` | `Color.black` |
| `offerBorderColor` | `any ShapeStyle` | `Color.gray.opacity(0.3)` |
| `offerSelectedBorderColor` | `any ShapeStyle` | `Color.pink` |
| `offerBorderWidth` | `CGFloat` | `0` |
| `offerSelectedBorderWidth` | `CGFloat` | `0.5` |
| `offerBackgroundColor` | `any ShapeStyle` | `Color.clear` |
| `offerSelectedBackgroundColor` | `any ShapeStyle` | `Color.clear` |
| `offerShowCheckmark` | `Bool` | `true` |
| `offerShadow` | `ContentBackgroundShadow?` | `nil` |
| `offerSelectedShadow` | `ContentBackgroundShadow?` | `nil` |
| `offerCheckmarkSize` | `CGFloat` | `22` |
| `offerCheckmarkActiveBGColor` | `any ShapeStyle` | `Color.blue` |
| `offerCheckmarkInactiveBGColor` | `any ShapeStyle` | `Color.gray.opacity(0.3)` |
| `offerCheckmarkActiveColor` | `any ShapeStyle` | `Color.white` |
| `offerCheckmarkInactiveColor` | `any ShapeStyle` | `Color.clear` |
| `offerCheckmarkActiveBorderColor` | `any ShapeStyle` | `Color.secondary` |
| `offerCheckmarkInactiveBorderColor` | `any ShapeStyle` | `Color.clear` |

#### Offer Divider

Вертикальный разделитель между названием оффера и ценой. По умолчанию скрыт:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `offerShowDivider` | `Bool` | `false` | Показывать разделитель |
| `offerPriceWidth` | `CGFloat` | `130` | Фикс. ширина текста цены |
| `offerDividerActiveColor` | `any ShapeStyle` | `Color.white` | Цвет для выбранного оффера |
| `offerDividerInactiveColor` | `any ShapeStyle` | `Color.white` | Цвет для невыбранного |
| `offerDividerActiveWidth` | `CGFloat` | `1` | Ширина для выбранного |
| `offerDividerActiveHeight` | `CGFloat` | `38` | Высота для выбранного |
| `offerDividerInactiveWidth` | `CGFloat` | `1` | Ширина для невыбранного |
| `offerDividerInactiveHeight` | `CGFloat` | `38` | Высота для невыбранного |
| `offerDividerPaddingHorizontal` | `CGFloat` | `0` | Горизонтальный отступ |
| `offerDividerPaddingVertical` | `CGFloat` | `0` | Вертикальный отступ |

#### Offer Shadow

Тень для карточек офферов. Можно задать отдельно для обычного и выбранного состояния:

```swift
// Одинаковая тень для всех офферов
offerShadow: ContentBackgroundShadow(
    color: .red.opacity(0.1),
    radius: 8,
    x: 0,
    y: 2
),
offerSelectedShadow: ContentBackgroundShadow(
    color: .red.opacity(0.1),
    radius: 8,
    x: 0,
    y: 2
)

// Тень только для выбранного оффера
offerShadow: nil,
offerSelectedShadow: ContentBackgroundShadow(
    color: .purple.opacity(0.15),
    radius: 10,
    x: 0,
    y: 4
)
```

> Important: Для корректного отображения тени `offerBackgroundColor` должен быть непрозрачным (например `.white`), иначе тень будет видна сквозь карточку.

### Кнопка закрытия

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `closeButtonIcon` | `String` | `"chevron.left"` | SF Symbol |
| `closeButtonColor` | `any ShapeStyle` | `Color.white` | Цвет |
| `closeButtonFont` | `Font` | `.system(size: 12, weight: .regular)` | Шрифт |
| `closeButtonPlacement` | `CloseButtonPlacement` | `.topBarLeading` | Положение |
| `closeButtonShowGlass` | `Bool` | `true` | Glass эффект (iOS 26+) |
| `closeButtonShowBackground` | `Bool` | `false` | Показывать фон кнопки |
| `closeButtonBackgroundColor` | `any ShapeStyle` | `Color.clear` | Цвет фона кнопки |

### Полный пример PaywallStyle

```swift
PaywallStyle(
    accentColor: .purple,
    backgroundColor: .black,
    contentBackgroundShow: true,
    contentBackgroundColor: Color.white.opacity(0.95),
    contentBackgroundCornerRadius: 32,
    contentBackgroundBorderColor: Color.clear,
    contentBackgroundBorderWidth: 0.5,
    contentBackgroundShadow: nil,
    titleOrder: .subtitleFirst,
    titleFont: .system(size: 32, weight: .bold),
    titleColor: .black,
    titleBottomPadding: 0,
    subtitleFont: .system(size: 14, weight: .regular),
    subtitleColor: Color.black.opacity(0.7),
    subtitleBottomPadding: 0,
    buttonFont: .system(size: 18, weight: .semibold),
    buttonTextColor: .white,
    buttonBackgroundColor: LinearGradient(
        colors: [.pink, .purple],
        startPoint: .leading,
        endPoint: .trailing
    ),
    buttonCornerRadius: 16,
    buttonHeight: 56,
    buttonBottomPadding: 0,
    linksFont: .system(size: 13, weight: .regular),
    linksColor: Color.gray.opacity(0.6),
    linksSpacing: 12,
    linksShowDividers: true,
    linksBottomPadding: 0,
    contentSpacing: 16,
    horizontalPadding: 24,
    bottomPadding: 40,
    offerHeight: 60,
    offerCornerRadius: 16,
    offerSpacing: 8,
    offersBottomPadding: 0,
    offerTitleFont: .system(size: 16, weight: .bold),
    offerTitleColor: .black,
    offerSubtitleFont: .system(size: 13, weight: .regular),
    offerSubtitleColor: Color.black.opacity(0.6),
    offerPriceFont: .system(size: 16, weight: .bold),
    offerPriceColor: .black,
    offerBorderColor: Color.gray.opacity(0.2),
    offerSelectedBorderColor: .purple,
    offerBackgroundColor: .white,
    offerSelectedBackgroundColor: Color.purple.opacity(0.1),
    offerShadow: ContentBackgroundShadow(
        color: .purple.opacity(0.1),
        radius: 8,
        x: 0,
        y: 2
    ),
    offerSelectedShadow: ContentBackgroundShadow(
        color: .purple.opacity(0.1),
        radius: 8,
        x: 0,
        y: 2
    ),
    closeButtonIcon: "xmark",
    closeButtonColor: .black,
    closeButtonFont: .system(size: 16, weight: .medium),
    closeButtonPlacement: .topBarTrailing,
    closeButtonShowGlass: false,
    closeButtonShowBackground: false,
    closeButtonBackgroundColor: Color.clear
)
```

## LinksConfiguration

Настройка ссылок Terms/Privacy/Restore:

```swift
LinksConfiguration(
    termsTitle: "Terms of Use",
    privacyTitle: "Privacy Policy",
    restoreTitle: "Restore",
    order: [.restore, .terms, .privacy]
)
```

### LinkType

- `.terms` — Terms of Use
- `.privacy` — Privacy Policy  
- `.restore` — Restore

## Terms и Privacy

### Вариант 1: View

Показ через sheet или fullScreenCover:

```swift
OnboardingBuilder(
    // ...
    legalPresentation: .sheet,  // или .fullScreenCover
    termsView: { TermsView() },
    privacyView: { PrivacyView() },
    onComplete: { }
)
```

### Вариант 2: URL

Открытие через браузер:

```swift
OnboardingBuilder(
    // ...
    termsURL: "https://example.com/terms",
    privacyURL: "https://example.com/privacy",
    onComplete: { }
)
```

## LegalPresentationStyle

Способ показа Terms/Privacy:

```swift
// Модальное окно снизу
legalPresentation: .sheet

// Полноэкранное окно
legalPresentation: .fullScreenCover
```

## CloseButtonPlacement

Положение кнопки закрытия:

```swift
// Слева
closeButtonPlacement: .topBarLeading

// Справа
closeButtonPlacement: .topBarTrailing
```

## Topics

### Styles

- ``OnboardingStyle``
- ``PaywallStyle``

### Configuration

- ``LinksConfiguration``
- ``PickerPaywallStyle``
- ``LegalPresentationStyle``
- ``CloseButtonPlacement``
