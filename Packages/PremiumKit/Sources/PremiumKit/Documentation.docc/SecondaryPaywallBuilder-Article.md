# SecondaryPaywallBuilder

Создание пейвола для второй группы подписок.

## Overview

``SecondaryPaywallBuilder`` — компонент для продажи дополнительной подписки (вторая группа продуктов). Показывается после успешной покупки основной подписки или standalone из любого места приложения.

## Настройка в Apphud

### Шаг 1: Создайте вторую группу подписок

В App Store Connect создайте вторую Subscription Group (например, "AI Features") с нужными продуктами.

### Шаг 2: Создайте placement в Apphud

В Apphud Dashboard:
1. Перейдите в **Paywalls & Placements**
2. Создайте новый **Paywall** (например, "Second Group Paywall")
3. Добавьте продукты из второй группы
4. Создайте **Placement** (например, `second_paywall`) и привяжите к нему этот paywall

### Шаг 3: Настройте JSON в Apphud

JSON для SecondaryPaywallBuilder аналогичен основному пейволу:

#### Один продукт (без toggle, без кнопки продукта)

```json
{
  "title": "Unlock AI",
  "limitedButton": "Maybe later",
  "tryFreeButton": "Continue",
  "continueButton": "Continue",
  "products": [
    {
      "id": "com.app.ai_weekly",
      "title": "AI Access",
      "subtitle": "Get AI features for just",
      "nonTrialSubtitle": "Get AI features for just",
      "message": "",
      "periodly": "Weekly"
    }
  ]
}
```

#### Два продукта — trial + non-trial (с toggle)

```json
{
  "title": "Unlock AI",
  "limitedButton": "Maybe later",
  "tryFreeButton": "Start free trial",
  "continueButton": "Continue",
  "products": [
    {
      "id": "com.app.ai_weekly_trial",
      "title": "AI Weekly",
      "subtitle": "Try 3 days free then",
      "nonTrialSubtitle": "Get AI features for just",
      "message": "Enable a 3 days free trial",
      "periodly": "Weekly"
    },
    {
      "id": "com.app.ai_weekly",
      "title": "AI Weekly",
      "subtitle": "Get AI features for just",
      "nonTrialSubtitle": "Get AI features for just",
      "message": "Without trial",
      "periodly": "Weekly"
    }
  ]
}
```

#### Три и более продуктов (ряд кнопок как на main paywall)

```json
{
  "title": "Unlock AI",
  "limitedButton": "Maybe later",
  "tryFreeButton": "Start free trial",
  "continueButton": "Continue",
  "purchaseButton": "Purchase",
  "products": [
    {
      "id": "com.app.ai_weekly",
      "title": "Weekly",
      "subtitle": "AI features",
      "periodly": "Weekly"
    },
    {
      "id": "com.app.ai_monthly",
      "title": "Monthly",
      "subtitle": "Best value",
      "periodly": "Monthly"
    },
    {
      "id": "com.app.ai_yearly",
      "title": "Yearly",
      "subtitle": "Save 80%",
      "periodly": "Yearly"
    }
  ]
}
```

## Настройка в приложении

### Шаг 1: Добавьте PremiumPaywallID

```swift
extension PremiumPaywallID {
    static let secondGroup = PremiumPaywallID("second_paywall")
}
```

### Шаг 2: Загрузите paywall

```swift
await Premium.shared.loadPaywall(.secondGroup)
```

## Режимы отображения

SecondaryPaywallBuilder автоматически выбирает UI в зависимости от количества продуктов:

| Продуктов | Режим | UI |
|-----------|-------|----|
| 1 | `single` | Без toggle, без кнопки продукта — только кнопка покупки |
| 2 (любой состав) | `double` | Toggle/checkmark или пикер для переключения продуктов |
| 3+ | `many` | Ряд кнопок продуктов (как на PaywallBuilder) |

### Два продукта одного типа (два триала / два безтриала)

Если из Apphud приходят два триальных или два безтриальных продукта, режим `double` сохраняется: toggle/checkmark и пикер переключают **между этими двумя продуктами**.

- Первый продукт из JSON — левый сегмент пикера, выбран по умолчанию при выключенном toggle/checkmark.
- Второй продукт — правый сегмент, выбирается включением toggle/checkmark.
- В пикере бейдж «Trial» показывается над каждым сегментом, чей продукт триальный (при двух триалах — над обоими, при двух безтриальных — нет).
- Алерт «Trial Unavailable» для такой пары не показывается.

При классическом наборе (триал + безтриальный) поведение прежнее: безтриальный слева выбран по умолчанию, триальный справа с бейджем.

## Standalone использование

Показ из настроек или любого другого места:

```swift
struct SettingsView: View {
    @State private var showSecondPaywall = false

    var body: some View {
        Button("Unlock AI Features") {
            showSecondPaywall = true
        }
        .fullScreenCover(isPresented: $showSecondPaywall) {
            SecondaryPaywallBuilder(
                paywallID: .secondGroup,
                images: AdaptiveResources(iphone: .aiPaywall),
                termsURL: "https://example.com/terms",
                privacyURL: "https://example.com/privacy",
                onDismiss: { showSecondPaywall = false },
                onSuccess: { showSecondPaywall = false }
            )
        }
        .taskOnce {
            await Premium.shared.loadPaywall(.secondGroup)
        }
    }
}
```

## Интеграция с OnboardingBuilder

Передайте SecondaryPaywallBuilder как `secondaryPaywallView`. После успешной покупки основной подписки автоматически покажется второй пейвол:

```swift
struct OnboardingFlow: View {
    @EnvironmentObject private var router: Router

    private let adaptiveImages = AdaptiveResources(iphone: Image("paywall_bg"))

    var body: some View {
        OnboardingBuilder(
            screens: [
                OnboardingScreen(
                    id: 0,
                    title1: "Welcome",
                    title2: "to the App",
                    subtitle: "Best app ever",
                    buttonTitle: "Next",
                    images: adaptiveImages
                ),
                OnboardingScreen(
                    id: 1,
                    title1: "Feature",
                    title2: "Overview",
                    subtitle: "Amazing features",
                    buttonTitle: "Continue",
                    images: adaptiveImages
                )
            ],
            paywallImages: adaptiveImages,
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            secondaryPaywallView: AnyView(secondaryPaywall),
            onComplete: { [weak router] in
                withAnimation { router?.appState = .main }
            }
        )
        .task {
            await Premium.shared.loadPaywall(.onboarding)
            await Premium.shared.loadPaywall(.secondGroup)
        }
    }

    private var secondaryPaywall: some View {
        SecondaryPaywallBuilder(
            paywallID: .secondGroup,
            images: adaptiveImages,
            style: SecondaryPaywallStyle(
                contentBackground: .init(show: true, color: Color.black.opacity(0.7), cornerRadius: 32),
                title: .init(color1: Color.white, color2: Color.white.opacity(0.8)),
                links: .init(color: Color.white.opacity(0.6)),
                closeButton: .init(color: Color.white)
            ),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            onDismiss: { [weak router] in
                withAnimation { router?.appState = .main }
            },
            onSuccess: { [weak router] in
                withAnimation { router?.appState = .main }
            }
        )
    }
}
```

**Flow:** Онбординг экраны → Пейвол → Покупка → SecondaryPaywall → onDismiss/onSuccess

## Интеграция с PaywallBuilder

Аналогично работает с ``PaywallBuilder``:

```swift
struct SettingsPaywallView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        PaywallBuilder(
            images: AdaptiveResources(iphone: .paywall),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            secondaryPaywallView: AnyView(
                SecondaryPaywallBuilder(
                    paywallID: .secondGroup,
                    images: AdaptiveResources(iphone: .aiPaywall),
                    termsURL: "https://example.com/terms",
                    privacyURL: "https://example.com/privacy",
                    onDismiss: { dismiss() },
                    onSuccess: { dismiss() }
                )
            ),
            onDismiss: { dismiss() },
            onSuccess: { dismiss() }
        )
    }
}
```

> Important: При передаче `secondaryPaywallView`, `onSuccess` основного билдера не вызывается — вместо этого показывается второй пейвол. Завершение flow происходит через `onDismiss`/`onSuccess` SecondaryPaywallBuilder.

## Кастомизация стиля

``SecondaryPaywallStyle`` использует sub-модели для группировки свойств. Передавайте только те группы, которые хотите изменить:

```swift
SecondaryPaywallStyle(
    contentBackground: .init(
        show: true,
        color: Color.black.opacity(0.8),
        cornerRadius: 24,
        padding: BackgroundPadding(horizontal: 20, bottom: 20)
    ),
    title: .init(
        font: .system(size: 30, weight: .black),
        color1: Color.orange,
        color2: Color.white,
        subtitleColor: Color.white.opacity(0.6),
        priceCustomization: [.heavy, .underline],
        titleFixedSize: true,
        subtitleFixedSize: true
    ),
    messageToggle: .init(
        backgroundColor: Color.white.opacity(0.15),
        toggleColor: .orange
    ),
    offer: .init(
        cornerRadius: 16,
        selectedBorderColor: Color.orange,
        checkmarkActiveBGColor: Color.orange
    ),
    button: .init(
        backgroundColor: LinearGradient(
            colors: [.orange, .pink],
            startPoint: .leading,
            endPoint: .trailing
        ),
        cornerRadius: 16,
        showAnimation: true
    ),
    links: .init(color: Color.white.opacity(0.5)),
    closeButton: .init(color: Color.white, showGlass: false)
)
```

### Группы стиля

| Группа | Свойств | Описание |
|--------|---------|----------|
| `contentBackground` | 8 | Фон, скругление, бордер, тень, отступы |
| `title` | 10 | Шрифты/цвета заголовка и подзаголовка |
| `messageToggle` | 20 | Сообщение + toggle (режим `double`) |
| `offer` | 44 | Ряды продуктов + чекмарки + разделитель (режим `many`) |
| `button` | 12 | Кнопка покупки |
| `links` | 5 | Terms/Privacy/Restore ссылки |
| `layout` | 4 | Отступы и максимальная ширина |
| `closeButton` | 7 | Кнопка закрытия |

Каждая группа имеет `.default` — можно менять только нужные свойства через `.init(...)`.

### Анимация кнопки (`button`)

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `showAnimation` | `Bool` | `false` | Пульсация кнопки покупки |
| `animationDuration` | `CGFloat` | `0.8` | Длительность одного цикла (секунды) |
| `animationScale` | `CGFloat` | `0.92` | Минимальный масштаб при пульсации |

```swift
SecondaryPaywallStyle(
    button: .init(showAnimation: true)
)
```

### Кастомизация подзаголовка и цены (`title`)

Группа `title` поддерживает те же расширенные поля стилизации, что и `OnboardingStyle`:

```swift
title: .init(
    // цена (поверх .heavy / .underline)
    priceCustomization: [.heavy, .underline],
    priceCustomizationFont: .system(size: 15, weight: .bold),
    priceCustomizationColor: .orange,
    // split subtitle: "Unlimited access to all premium features"
    splitSubtitleBy: 2,
    subtitleBeforeFont: .system(size: 15, weight: .regular),
    subtitleBeforeColor: Color.white.opacity(0.4),
    subtitleAfterFont: .system(size: 15, weight: .semibold),
    subtitleAfterColor: Color.white.opacity(0.9)
)
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `priceCustomizationFont` | `Font?` | `nil` | Шрифт цены (поверх `priceCustomization`) |
| `priceCustomizationColor` | `Color?` | `nil` | Цвет цены (поверх `priceCustomization`) |
| `splitSubtitleBy` | `Int?` | `nil` | Индекс слова, по которому делится подзаголовок |
| `subtitleBeforeFont` | `Font?` | `nil` | Шрифт части до слова (`words[0..<index]`) |
| `subtitleBeforeColor` | `Color?` | `nil` | Цвет части до слова |
| `subtitleAfterFont` | `Font?` | `nil` | Шрифт части от слова включительно (`words[index...]`) |
| `subtitleAfterColor` | `Color?` | `nil` | Цвет части от слова включительно |

> Note: Split-стилизация применяется первой, затем поверх диапазона цены накладывается `priceCustomization` (если цена присутствует в подзаголовке).

### Offer Divider (режим `many`)

Вертикальный разделитель в ряду продукта между названием и ценой. По умолчанию скрыт (`showDivider: false`):

```swift
offer: .init(
    showDivider: true,
    priceWidth: 130,
    dividerActiveColor: .white,
    dividerInactiveColor: .white,
    dividerActiveWidth: 1,
    dividerActiveHeight: 38,
    dividerInactiveWidth: 1,
    dividerInactiveHeight: 38,
    dividerPaddingHorizontal: 0,
    dividerPaddingVertical: 0
)
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `showDivider` | `Bool` | `false` | Показывать разделитель |
| `priceWidth` | `CGFloat` | `130` | Фикс. ширина текста цены |
| `dividerActiveColor` | `any ShapeStyle` | `Color.white` | Цвет для выбранного |
| `dividerInactiveColor` | `any ShapeStyle` | `Color.white` | Цвет для невыбранного |
| `dividerActiveWidth` / `dividerActiveHeight` | `CGFloat` | `1` / `38` | Размер для выбранного |
| `dividerInactiveWidth` / `dividerInactiveHeight` | `CGFloat` | `1` / `38` | Размер для невыбранного |
| `dividerPaddingHorizontal` / `dividerPaddingVertical` | `CGFloat` | `0` / `0` | Отступы разделителя |

## View-слоты

| Слот | Описание |
|------|----------|
| `backgroundView` | Заменяет стандартный Image-фон |
| `middleView` | Между фоном и контентом |
| `overlayView` | Поверх всего |

```swift
SecondaryPaywallBuilder(
    paywallID: .secondGroup,
    images: AdaptiveResources(iphone: .aiPaywall),
    backgroundView: AnyView(
        LinearGradient(colors: [.purple, .black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    ),
    onDismiss: { },
    onSuccess: { }
)
```

## Колбэки для метрик

Опциональные замыкания для аналитики (дефолт `nil`):

| Параметр | Тип | Когда вызывается |
|----------|-----|------------------|
| `onPaywallShown` | `(() -> Void)?` | Пейвол показан |
| `onDismissTapped` | `(() -> Void)?` | Тап по кнопке закрытия или по limited-кнопке |

```swift
SecondaryPaywallBuilder(
    paywallID: .secondary,
    images: AdaptiveResources(iphone: .secondary),
    onPaywallShown: { Analytics.log("secondary_paywall_shown") },
    onDismissTapped: { Analytics.log("secondary_paywall_dismiss") },
    onDismiss: { dismiss() },
    onSuccess: { dismiss() }
)
```

> Note: `onDismissTapped` срабатывает до `onDismiss` — первый для метрик, второй для вашей логики закрытия.

## Trial Expired Alert

Если пользователь уже использовал триал (Apphud/StoreKit возвращает продукт без `hasTrial`), при попытке включить toggle/checkmark/picker на триальный продукт переключение блокируется и показывается локализованный алерт. Работает автоматически, не требует дополнительной настройки. Исключение — пара продуктов одного типа (два триала или два безтриальных): переключение между ними не требует триала, алерт не показывается.

## Terms и Privacy

### Вариант 1: URL (открывается в браузере)

```swift
SecondaryPaywallBuilder(
    paywallID: .secondGroup,
    images: adaptiveImages,
    termsURL: "https://example.com/terms",
    privacyURL: "https://example.com/privacy",
    onDismiss: { },
    onSuccess: { }
)
```

### Вариант 2: View (sheet/fullScreenCover)

```swift
SecondaryPaywallBuilder(
    paywallID: .secondGroup,
    images: adaptiveImages,
    legalPresentation: .sheet,
    termsView: { TermsView() },
    privacyView: { PrivacyView() },
    onDismiss: { },
    onSuccess: { }
)
```

## Footer

Настройте текст и порядок ссылок:

```swift
SecondaryPaywallBuilder(
    paywallID: .secondGroup,
    images: adaptiveImages,
    linksConfig: LinksConfiguration(
        termsTitle: "Terms",
        privacyTitle: "Privacy",
        restoreTitle: "Restore",
        order: [.restore, .terms, .privacy]
    ),
    termsURL: "https://example.com/terms",
    privacyURL: "https://example.com/privacy",
    onDismiss: { },
    onSuccess: { }
)
```

## Полный пример

```swift
struct OnboardingFlow: View {
    @EnvironmentObject private var router: Router

    private let adaptiveImages = AdaptiveResources(iphone: Image("paywall_bg"))
    private let aiImages = AdaptiveResources(iphone: Image("ai_paywall_bg"))

    var body: some View {
        OnboardingBuilder(
            screens: [
                OnboardingScreen(
                    id: 0,
                    title1: "Welcome",
                    title2: "to the App",
                    subtitle: "Best app ever",
                    buttonTitle: "Next",
                    images: adaptiveImages
                ),
                OnboardingScreen(
                    id: 1,
                    title1: "Feature",
                    title2: "Overview",
                    subtitle: "Amazing features",
                    buttonTitle: "Continue",
                    images: adaptiveImages
                )
            ],
            paywallImages: adaptiveImages,
            style: OnboardingStyle(
                buttonBackgroundColor: LinearGradient(
                    colors: [.pink, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            ),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            secondaryPaywallView: AnyView(secondaryPaywall),
            onComplete: { [weak router] in
                withAnimation { router?.appState = .main }
            }
        )
        .task {
            await Premium.shared.loadPaywall(.onboarding)
            await Premium.shared.loadPaywall(.secondGroup)
        }
    }

    private var secondaryPaywall: some View {
        SecondaryPaywallBuilder(
            paywallID: .secondGroup,
            images: aiImages,
            style: SecondaryPaywallStyle(
                contentBackground: .init(
                    show: true,
                    color: Color.black.opacity(0.7),
                    cornerRadius: 32
                ),
                title: .init(
                    font: .system(size: 28, weight: .black),
                    color1: Color.white,
                    color2: Color.white.opacity(0.8),
                    subtitleColor: Color.white.opacity(0.6)
                ),
                messageToggle: .init(
                    color: Color.white,
                    backgroundColor: Color.white.opacity(0.15),
                    toggleColor: .pink
                ),
                button: .init(
                    backgroundColor: LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    showAnimation: true
                ),
                links: .init(color: Color.white.opacity(0.5)),
                closeButton: .init(color: Color.white, showGlass: false)
            ),
            linksConfig: LinksConfiguration(
                termsTitle: "Terms",
                privacyTitle: "Privacy",
                restoreTitle: "Restore",
                order: [.terms, .privacy, .restore]
            ),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            onDismiss: { [weak router] in
                withAnimation { router?.appState = .main }
            },
            onSuccess: { [weak router] in
                withAnimation { router?.appState = .main }
            }
        )
    }
}
```

## Topics

### Related

- ``SecondaryPaywallBuilder``
- ``SecondaryPaywallStyle``
- ``OnboardingBuilder``
- ``PaywallBuilder``
- <doc:ApphudJSON>
- <doc:Customization-Article>
- <doc:PickerPaywall-Article>
