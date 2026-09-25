# PremiumKit

Swift Package для интеграции in-app purchases через Apphud с удобным публичным API.

## Возможности

- Простая интеграция покупок через `Premium` сервис
- Автоматическая загрузка paywall с fallback на локальные данные
- Поддержка sandbox режима для тестирования
- Готовый `DemoContentView` для быстрого прототипирования
- Детальная обработка ошибок покупок (StoreKit 2)
- **OnboardingBuilder** — конструктор онбординг флоу с пейволом
- **PaywallBuilder** — конструктор пейвола для main флоу
- **Toggle/Picker для пар продуктов** — корректное переключение, когда из Apphud приходят два триальных или два безтриальных продукта
- **View-слоты** — кастомный background, middle layer и overlay для каждого экрана билдера
- **hideContent** — скрытие элементов контента (индикаторы, заголовок, подзаголовок, сообщение) per-screen
- **Локализация** — встроенная поддержка 30 языков
- **Consumable продукты** — поддержка одноразовых покупок (токены)
- **Расширяемые ID** — кастомные `PremiumPaywallID` и `PaywallConfiguration`
- **WebBannerView** — WebView компонент для показа баннеров из Apphud

## Требования

- iOS 16.0+
- Swift 5.9+
- Xcode 15+

## Установка

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/AppEmpire-Utility/PremiumKit", from: "1.0.0")
]
```

## Быстрый старт

### 1. App Delegate

Подключите `PremiumAppDelegate` для автоматической инициализации:

```swift
@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(PremiumAppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Если нужен свой делегат — наследуйтесь от `PremiumAppDelegate`:

```swift
class MyAppDelegate: PremiumAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        _ = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        // своя логика
        return true
    }
}
```

### 2. Инициализация API Key

В точке входа приложения:

```swift
    init() {
        let apiKey = Bundle.main.infoDictionary?["PremiumAPIKey"] as? String ?? ""
        Premium.shared.configure(PremiumConfiguration(apiKey: apiKey))
    }
```

### Debug / Release режим

PremiumKit автоматически определяет режим сборки через `#if DEBUG`:

| | Debug | Release |
|---|---|---|
| **Данные пейвола** | Из Apphud (без fallback) | Fallback в sandbox, Apphud в production |
| **Покупки** | StoreKit 2 | Apphud |

Никаких флагов включать не нужно — всё работает автоматически.

В Debug консоли:
```
🔧 [PremiumKit] DEBUG mode — loading paywall from Apphud, no fallback
📦 [PremiumKit] Paywall main loaded — source: Apphud, configuration: variant2
👁️ [PremiumKit] Paywall shown — main
🛒 [PremiumKit] Purchase started — com.app.WeekTrial
🛒 [PremiumKit] Debug: purchased via SK2 — com.app.WeekTrial
```

### 3. Загрузка Paywall

Загрузите onboarding и main paywall:

```swift
.task {
    await Premium.shared.loadPaywall(.onboarding)
}

.task {
    await Premium.shared.loadPaywall(.main)
}
```

### 4. Splash Screen и WebBanner

Добавьте оверлей для показа сплэш скрина, пока тянется пейвол:

```swift
    .overlay {
        if premiumService.isShowingSplash {
            DemoSplashView()
        }
    }
```

И вью модифайер для показа вебвью:

```swift
    .webBannerOverlay()
```        

### 5. Онбординг и Пейвол

Используйте билдеры для UI:

```swift
// Онбординг
OnboardingBuilder(
    screens: [...],
    paywallImages: AdaptiveResources(iphone: .paywall),
    onComplete: { }
)

// Пейвол
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    onDismiss: { },
    onSuccess: { }
)
```

#### View-слоты

Оба билдера поддерживают 3 опциональных view-слота:

| Слот | Описание |
|------|----------|
| `backgroundView` | Заменяет стандартный Image-фон |
| `middleView` | Между фоном и основным контентом |
| `overlayView` | Поверх всего (лоадеры, анимации) |

В **OnboardingBuilder** слоты задаются на каждый `OnboardingScreen`:

```swift
OnboardingScreen(
    id: 0,
    title1: "Welcome",
    subtitle: "Get started",
    images: AdaptiveResources(iphone: .onb1),
    backgroundView: { Color.black.ignoresSafeArea() },
    middleView: { FeatureAnimationView() },
    overlayView: { EmptyView() }
)
```

В **PaywallBuilder** слоты передаются в init:

```swift
PaywallBuilder(
    images: AdaptiveResources(iphone: .paywall),
    backgroundView: { GradientBackground() },
    middleView: { EmptyView() },
    overlayView: { CustomLoaderView() },
    onDismiss: { },
    onSuccess: { }
)
```

Все 3 слота опциональны — без них билдеры работают как раньше.

### 6. Проверка подписки и токены

```swift
@ObservedObject private var premium = Premium.shared

if premium.isPremium {
    // премиум контент
}

// Баланс токенов
let balance = premium.tokens

// Начисление токенов
premium.addTokens(10)

// Списание токенов
let success = premium.spendTokens()
```

### 7. Кастомные Paywall ID

`PremiumPaywallID` — расширяемый struct. Встроенные: `.onboarding`, `.main`, `.consumable`, `.banner`. Добавляйте свои:

```swift
extension PremiumPaywallID {
    static let yearSale = PremiumPaywallID("yearSale")
}

await Premium.shared.loadPaywall(.yearSale)
let paywall = Premium.shared.paywall(for: .yearSale)
```

## Документация

Подробная документация доступна в формате DocC: `Sources/PremiumKit/Documentation.docc/`

Для просмотра в Xcode: **Product → Build Documentation**

## Архитектура

```
PremiumKit/
├── Public/
│   ├── Premium/
│   │   ├── Premium.swift              # Публичный сервис
│   │   ├── PremiumConfiguration       # Конфигурация
│   │   ├── PremiumPaywallID           # Расширяемый ID пейвола
│   │   ├── PremiumPaywall             # Модель paywall
│   │   ├── PremiumProduct             # Модель продукта
│   │   ├── PremiumError               # Ошибки
│   │   └── PaywallConfiguration       # AB-конфигурация
│   │
│   └── Builders/
│       ├── Onboarding/
│       │   ├── OnboardingBuilder      # View онбординга
│       │   ├── OnboardingStyle        # Стили онбординга
│       │   └── OnboardingScreen       # Модель экрана
│       │
│       ├── Paywall/
│       │   ├── PaywallBuilder         # View пейвола
│       │   └── PaywallStyle           # Стили пейвола
│       │
│       └── Shared/
│           ├── AdaptiveResources      # Адаптивные изображения
│           ├── LinksConfiguration     # Конфигурация ссылок
│           └── LegalPresentationStyle # Стиль показа legal
│
├── Internal/
│   ├── Payment/
│   │   ├── PaymentManager             # Менеджер Apphud
│   │   ├── TokenStorage               # Хранение токенов (Keychain)
│   │   └── Fallback/                  # Fallback логика
│   └── Extensions/
│
├── Resources/
│   └── Localizable.xcstrings          # Локализация (30 языков)
│
├── Demo/                              # Демо компоненты
│
└── PremiumAppDelegate                 # App Delegate
```
