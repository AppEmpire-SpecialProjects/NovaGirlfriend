# Getting Started

Быстрый старт с PremiumKit.

## Overview

Настройка PremiumKit занимает несколько минут. Следуйте этому руководству для базовой интеграции.

## Установка

Добавьте PremiumKit через Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/AppEmpire-Utility/PremiumKit", from: "1.0.0")
]
```

## Настройка API ключа

Добавьте ключ в `Info.plist` вашего приложения:

```xml
<key>PremiumAPIKey</key>
<string>your_apphud_api_key</string>
```

## Настройка App

### Шаг 1: Добавьте App Delegate

```swift
import SwiftUI
import PremiumKit

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(PremiumAppDelegate.self) 
    private var premiumDelegate
    
    init() {
        let apiKey = Bundle.main.infoDictionary?["PremiumAPIKey"] as? String ?? ""
        Premium.shared.configure(PremiumConfiguration(apiKey: apiKey))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Debug / Release режим

PremiumKit автоматически определяет режим сборки через `#if DEBUG`:

| | Debug | Release |
|---|---|---|
| **Данные пейвола** | Из Apphud (без fallback) | Fallback в sandbox, Apphud в production |
| **Покупки** | StoreKit 2 | Apphud |

Никаких флагов не нужно — работает автоматически.

В Debug консоли:
```
🔧 [PremiumKit] DEBUG mode — loading paywall from Apphud, no fallback
📦 [PremiumKit] Paywall main loaded — source: Apphud, configuration: variant2
👁️ [PremiumKit] Paywall shown — main
🛒 [PremiumKit] Purchase started — com.app.WeekTrial
🛒 [PremiumKit] Debug: purchased via SK2 — com.app.WeekTrial
```

### Шаг 2: Загрузите Paywall

```swift
struct ContentView: View {
    var body: some View {
        MainView()
            .taskOnce {
                await Premium.shared.loadPaywall(.main)
            }
    }
}
```

#### Несколько пейволов

PremiumKit содержит встроенные идентификаторы пейволов (`.main`, `.onboarding`, `.consumable`, `.banner`), а также позволяет добавлять собственные через расширения `PremiumPaywallID`.

Каждый `loadPaywall` записывает данные в словарь `paywalls`:

```swift
await Premium.shared.loadPaywall(.main)        // → premium.availablePaywall
await Premium.shared.loadPaywall(.onboarding)  // → premium.availablePaywall
await Premium.shared.loadPaywall(.consumable)  // → premium.consumablePaywall
await Premium.shared.loadPaywall(.banner)      // → premium.bannerPaywall
```

Для удобства есть шорткаты `availablePaywall`, `consumablePaywall`, `bannerPaywall`. Для любого пейвола можно обратиться через словарь:

```swift
premium.paywalls[.main]
premium.paywall(for: .consumable)
```

#### Кастомные пейволы

Добавьте собственный идентификатор через расширение:

```swift
extension PremiumPaywallID {
    static let yearSale = PremiumPaywallID("yearSale")
}
```

Загрузка и доступ:

```swift
await Premium.shared.loadPaywall(.yearSale)
let paywall = premium.paywall(for: .yearSale)
```

#### Примеры

Загрузка баннерного пейвола:

```swift
YearSaleView()
    .taskOnce {
        await Premium.shared.loadPaywall(.banner)
    }
```

Доступ к продуктам:

```swift
@ObservedObject private var premium = Premium.shared

// main / onboarding
premium.availablePaywall.products

// consumable / banner
premium.consumablePaywall.products
premium.bannerPaywall.products
```

Покупка и paywallShown по умолчанию работают с `availablePaywall`. Для других пейволов передайте тип явно:

```swift
// main/onboarding (по умолчанию)
await premium.purchase(product)
premium.paywallShown()

// banner
await premium.purchase(product, from: .banner)
premium.paywallShown(.banner)
```

> Указывайте `from:` если один и тот же productID используется в нескольких placement — это важно для корректного трекинга в Apphud.

### Шаг 3: Проверяйте премиум статус

```swift
struct ContentView: View {
    @ObservedObject private var premium = Premium.shared
    
    var body: some View {
        if premium.isPremium {
            PremiumContentView()
        } else {
            FreeContentView()
        }
    }
}
```

## Web Banner Overlay

Для показа рекламного баннера из Apphud JSON используйте модификатор `.webBannerOverlay()`:

```swift
struct ContentView: View {
    var body: some View {
        MainView()
            .webBannerOverlay()
    }
}
```

Баннер автоматически загружается из JSON поля `adBanner`:
- `adBanner.link` — URL для WebView
- `adBanner.isShow` — флаг показа (true/false)

## Быстрый тест

Используйте `DemoContentView` для тестирования без настройки UI:

```swift
import PremiumKit

struct ContentView: View {
    var body: some View {
        DemoContentView()
    }
}
```

## Следующие шаги

- <doc:PremiumService-Article> — работа с Premium сервисом
- <doc:OnboardingBuilder-Article> — создание онбординга
- <doc:PaywallBuilder-Article> — создание пейвола
- <doc:Customization-Article> — кастомизация стилей
- <doc:ApphudJSON> — настройка JSON в Apphud
- <doc:Localization-Article> — локализация на 30 языков
- <doc:SecondaryPaywallBuilder-Article> — пейвол для второй группы подписок
- <doc:ConsumableFlow-Article> — работа с Consumable продуктами
