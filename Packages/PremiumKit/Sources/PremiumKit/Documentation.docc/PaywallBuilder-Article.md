# PaywallBuilder

Создание standalone пейвола для показа из любого места приложения.

## Overview

``PaywallBuilder`` — готовый компонент пейвола для показа из настроек, баннеров или любого другого места.

## Базовое использование

Минимальная настройка пейвола:

PaywallBuilder поддерживает два варианта: с View (через `@ViewBuilder`) и с URL (через строки).

### Вариант с URL (простой)

```swift
import SwiftUI
import PremiumKit

struct SettingsPaywallView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        PaywallBuilder(
            images: AdaptiveResources(iphone: .paywall),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            onDismiss: { dismiss() },
            onSuccess: { dismiss() }
        )
    }
}
```

### Вариант с View

```swift
struct SettingsPaywallView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        PaywallBuilder(
            images: AdaptiveResources(iphone: .paywall),
            legalPresentation: .sheet,
            termsView: { TermsView() },
            privacyView: { PrivacyView() },
            onDismiss: { dismiss() },
            onSuccess: { dismiss() }
        )
    }
}
```

## Показ из Settings

```swift
struct SettingsView: View {
    @State private var showPaywall = false
    @ObservedObject private var premium = Premium.shared
    
    var body: some View {
        VStack {
            if !premium.isPremium {
                Button("Upgrade to Premium") {
                    showPaywall = true
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallBuilder(
                images: AdaptiveResources(iphone: .paywall),
                termsURL: "https://example.com/terms",
                privacyURL: "https://example.com/privacy",
                onDismiss: { showPaywall = false },
                onSuccess: { showPaywall = false }
            )
        }
    }
}
```

## View-слоты

PaywallBuilder поддерживает 3 view-слота для кастомизации экрана:

| Слот | Описание |
|------|----------|
| `backgroundView` | Заменяет стандартный Image-фон. Если передан — Image не рендерится |
| `middleView` | Отображается между фоном и основным контентом в ZStack |
| `overlayView` | Отображается в `.overlay {}` поверх всего (лоадеры, анимации) |

### Два варианта init

PaywallBuilder имеет два init:

1. **Стандартный** — без слотов, фон из Image (AdaptiveResources)
2. **С @ViewBuilder** — все 3 слота обязательны

Если вам не нужны кастомные слои — используйте стандартный init. Слоты нужны когда вы хотите полностью заменить фон, добавить промежуточный слой или оверлей.

> Warning: В @ViewBuilder init все 3 слота обязательны. `backgroundView` заменяет Image-фон — стандартное изображение не будет отрендерено.

### Пример: кастомный фон + middle + overlay

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    backgroundView: {
        LinearGradient(
            colors: [.purple, .blue],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    },
    middleView: {
        FeaturesScrollView()
    },
    overlayView: {
        VStack {
            HStack {
                Spacer()
                Text("NEW")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.pink))
                    .padding(.trailing, 20)
                    .padding(.top, 56)
            }
            Spacer()
        }
        .allowsHitTesting(false)
    },
    onDismiss: { },
    onSuccess: { }
)
```

### Пример: градиент + анимация

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    backgroundView: {
        ZStack {
            Color.black.ignoresSafeArea()
            LottieView(animation: "stars")
                .ignoresSafeArea()
        }
    },
    middleView: {
        LottieView(animation: "confetti")
            .ignoresSafeArea()
            .allowsHitTesting(false)
    },
    overlayView: {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "sparkles")
                Text("Limited offer!")
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.bottom, 120)
        }
        .allowsHitTesting(false)
    },
    onDismiss: { },
    onSuccess: { }
)
```

## Кастомизация стиля

Используйте ``PaywallStyle`` для кастомизации. Цвета и градиенты передаются напрямую:

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    style: PaywallStyle(
        accentColor: .purple,
        backgroundColor: .black,
        contentBackgroundShow: true,
        contentBackgroundColor: Color.white.opacity(0.95),
        contentBackgroundCornerRadius: 32,
        contentBackgroundBorderColor: Color.clear,
        contentBackgroundBorderWidth: 0.5,
        contentBackgroundShadow: nil,
        titleColor: .white,
        buttonBackgroundColor: LinearGradient(
            colors: [.pink, .purple],
            startPoint: .leading,
            endPoint: .trailing
        ),
        offerSelectedBorderColor: .purple
    ),
    onDismiss: { },
    onSuccess: { }
)
```

## Анимация кнопки покупки

Добавьте `showPaywallButtonAnimation: true` для плавной пульсации кнопки покупки (по умолчанию `false`):

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    style: PaywallStyle(
        showPaywallButtonAnimation: true,
        buttonAnimationDuration: 0.8,
        buttonAnimationScale: 0.92
    ),
    onDismiss: { },
    onSuccess: { }
)
```

## Кнопка закрытия

Настройте иконку и положение кнопки закрытия:

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    style: PaywallStyle(
        closeButtonIcon: "xmark",
        closeButtonColor: .white,
        closeButtonFont: .system(size: 16, weight: .medium),
        closeButtonPlacement: .topBarTrailing,
        closeButtonShowGlass: false,
        closeButtonShowBackground: false,
        closeButtonBackgroundColor: Color.clear
    ),
    onDismiss: { },
    onSuccess: { }
)
```

### Скрытие кнопки закрытия

Используйте `showCloseButton: false` чтобы полностью убрать кнопку:

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    showCloseButton: false,
    onDismiss: { },
    onSuccess: { }
)
```

### Скрытие Navigation Bar

Используйте `navigationBarHidden: true` чтобы скрыть navigation bar:

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    navigationBarHidden: true,
    onDismiss: { },
    onSuccess: { }
)
```

## Отключение Cancelled Alert

По умолчанию при отмене покупки показывается алерт с предложением повторить. Используйте `showCancelledAlert: false` чтобы отключить:

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    showCancelledAlert: false,
    onDismiss: { },
    onSuccess: { }
)
```

## Тени для офферов

Добавьте тень карточкам офферов через `offerShadow` и `offerSelectedShadow`:

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    style: PaywallStyle(
        offerBackgroundColor: .white,
        offerSelectedBackgroundColor: .pink.opacity(0.1),
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
    ),
    onDismiss: { },
    onSuccess: { }
)
```

> Important: Для корректного отображения тени `offerBackgroundColor` должен быть непрозрачным (например `.white`).

## Скрытие продуктов (A/B тесты)

Используйте `hiddenProductIDs` чтобы исключить конкретные продукты из списка офферов, не убирая их из пейвола в Apphud. Продукт остаётся загруженным в `Premium` (доступен по `id` для других экранов), но не отображается в этом `PaywallBuilder`.

Кейс: в одном Apphud-пейволе хранятся обычный годовой и скидочный годовой продукт для сравнения метрик. В обычном main-пейволе скидочный скрывается, а отдельный экран (лимитед-оффер) берёт его по `id`.

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    hiddenProductIDs: ["com.example.app.yearLimited"],
    onDismiss: { },
    onSuccess: { }
)
```

По умолчанию `hiddenProductIDs` пустой — фильтрация не применяется. Скрытие затрагивает список офферов, выбор (`selectedIndex`) и покупку — они работают только с видимыми продуктами.

## Terms и Privacy

### Вариант 1: View (sheet/fullScreenCover)

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    legalPresentation: .sheet,
    termsView: { TermsView() },
    privacyView: { PrivacyView() },
    onDismiss: { },
    onSuccess: { }
)
```

### Вариант 2: URL (открывается в браузере)

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    termsURL: "https://example.com/terms",
    privacyURL: "https://example.com/privacy",
    onDismiss: { },
    onSuccess: { }
)
```

## Footer

Настройте текст и порядок кнопок:

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    linksConfig: LinksConfiguration(
        termsTitle: "Terms",
        privacyTitle: "Privacy", 
        restoreTitle: "Restore purchases",
        order: [.restore, .terms, .privacy]
    ),
    termsURL: "https://example.com/terms",
    privacyURL: "https://example.com/privacy",
    onDismiss: { },
    onSuccess: { }
)
```

## Callbacks

### onDismiss

Вызывается когда пользователь закрывает пейвол:

```swift
onDismiss: {
    dismiss()
}
```

### onSuccess

Вызывается после успешной покупки:

```swift
onSuccess: {
    dismiss()
}
```

### Колбэки для метрик

Опциональные замыкания для аналитики (дефолт `nil`):

| Параметр | Тип | Когда вызывается |
|----------|-----|------------------|
| `onPaywallShown` | `(() -> Void)?` | Пейвол показан |
| `onDismissTapped` | `(() -> Void)?` | Тап по кнопке закрытия |

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    onPaywallShown: { Analytics.log("paywall_shown") },
    onDismissTapped: { Analytics.log("paywall_dismiss") },
    onDismiss: { dismiss() },
    onSuccess: { dismiss() }
)
```

> Note: `onDismissTapped` срабатывает до `onDismiss` — первый для метрик, второй для вашей логики закрытия.

## Полный пример

```swift
struct PremiumPaywallView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        PaywallBuilder(
            images: AdaptiveResources(
                iphone: .paywall,
                iphoneS: .paywallSE,
                ipadL: .paywallLandscape
            ),
            style: customStyle,
            linksConfig: LinksConfiguration(
                termsTitle: "Terms of Use",
                privacyTitle: "Privacy Policy",
                restoreTitle: "Restore Purchases",
                order: [.terms, .privacy, .restore]
            ),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            onDismiss: {
                dismiss()
            },
            onSuccess: {
                dismiss()
            }
        )
    }
    
    var customStyle: PaywallStyle {
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
            buttonBorderColor: .purple,
            buttonBorderWidth: 1,
            buttonShowBorder: false,
            buttonBottomPadding: 0,
            linksFont: .system(size: 13, weight: .regular),
            linksColor: Color.gray.opacity(0.6),
            linksSpacing: 12,
            linksShowDividers: true,
            linksBottomPadding: 0,
            offerHeight: 60,
            offerCornerRadius: 16,
            offersBottomPadding: 0,
            offerTitleColor: .black,
            offerSubtitleColor: Color.black.opacity(0.6),
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
            offerCheckmarkActiveBGColor: .purple,
            offerCheckmarkInactiveBGColor: Color.gray.opacity(0.2),
            offerCheckmarkActiveColor: .white,
            offerCheckmarkActiveBorderColor: .purple,
            offerCheckmarkInactiveBorderColor: Color.gray.opacity(0.3),
            closeButtonIcon: "xmark",
            closeButtonColor: .black,
            closeButtonFont: .system(size: 16, weight: .medium),
            closeButtonPlacement: .topBarTrailing,
        closeButtonShowGlass: false,
        closeButtonShowBackground: false,
        closeButtonBackgroundColor: Color.clear
    )
    }
}
```

## Topics

### Related

- ``PaywallBuilder``
- ``PaywallStyle``
- ``AdaptiveResources``
- <doc:Customization-Article>
