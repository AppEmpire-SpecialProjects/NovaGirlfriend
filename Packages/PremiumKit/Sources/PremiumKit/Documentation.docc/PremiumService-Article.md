# Premium Service

Основной сервис для работы с покупками.

## Overview

`Premium` — singleton сервис, предоставляющий API для работы с in-app purchases через Apphud.

## Конфигурация

### Инициализация

```swift
import PremiumKit

let apiKey = Bundle.main.infoDictionary?["PremiumAPIKey"] as? String ?? ""
Premium.shared.configure(PremiumConfiguration(apiKey: apiKey))
```

### shouldLogout

Флаг `shouldLogout` вызывает `Apphud.logout()` при конфигурации — сбрасывает сессию, статус премиума и активные подписки. По умолчанию `false`.

```swift
Premium.shared.configure(PremiumConfiguration(
    apiKey: apiKey,
    shouldLogout: true
))
```

### Имя fallback-файла

По умолчанию PremiumKit ищет `apphud_paywalls_fallback.json` в основном bundle приложения. Чтобы использовать файл с другим названием, передайте имя без расширения в `PremiumConfiguration`:

```swift
Premium.shared.configure(PremiumConfiguration(
    apiKey: apiKey,
    fallbackFileName: "my_paywalls_fallback"
))
```

В этом примере fallback будет загружен из `my_paywalls_fallback.json`.

### Загрузка Paywall

```swift
// Для onboarding флоу
await Premium.shared.loadPaywall(.onboarding)

// Для main флоу
await Premium.shared.loadPaywall(.main)
```

### Кастомные Paywall ID

`PremiumPaywallID` — extensible struct. Добавляйте свои через extension:

```swift
extension PremiumPaywallID {
    static let settings = PremiumPaywallID("settings")
    static let yearSale = PremiumPaywallID("yearSale")
}
```

Загрузка и доступ:

```swift
await Premium.shared.loadPaywall(.yearSale)
let paywall = Premium.shared.paywall(for: .yearSale)
```

### Кастомные PaywallConfiguration

`PaywallConfiguration` — extensible struct для A/B тестов:

```swift
extension PaywallConfiguration {
    static let darkTheme = PaywallConfiguration("darkTheme")
    static let compact = PaywallConfiguration("compact")
}
```

### Хранилища пейволов

Каждый загруженный paywall доступен через `Premium`:

```swift
@ObservedObject private var premium = Premium.shared

// Встроенные шорткаты
premium.availablePaywall    // .main / .onboarding
premium.consumablePaywall   // .consumable
premium.bannerPaywall       // .banner

// Любой пейвол через словарь
premium.paywalls[.main]
premium.paywall(for: .yearSale)
```

Покупка с указанием источника:

```swift
// main/onboarding (по умолчанию)
await premium.purchase(product)
premium.paywallShown()

// другой пейвол — укажите from:
await premium.purchase(product, from: .banner)
premium.paywallShown(.banner)
```

> Указывайте `from:` если один и тот же productID используется в нескольких placement — это важно для корректного трекинга в Apphud.

## Properties

| Property | Тип | Описание |
|----------|-----|----------|
| `isPremium` | `Bool` | Статус премиум подписки |
| `availablePaywall` | `PremiumPaywall` | Загруженный paywall (по умолчанию mock) |
| `availableProducts` | `PremiumAvailableProducts` | Тип доступных продуктов |
| `paywalls` | `[PremiumPaywallID: PremiumPaywall]` | Словарь всех загруженных paywall |
| `consumablePaywall` | `PremiumPaywall` | Paywall для consumable продуктов |
| `bannerPaywall` | `PremiumPaywall` | Paywall для баннера |
| `tokens` | `Int` | Количество доступных токенов |
| `isTrialExpired` | `Bool` | Триал был активирован и истёк (isPremium == false) |
| `activeProductIds` | `Set<String>` | Множество ID активных подписок |
| `isShowingSplash` | `Bool` | Показ сплэш скрина, пока тянется пейвол |
| `isShowingPaywall` | `Bool` | Показ пейвола |

### Методы

| Метод | Возврат | Описание |
|-------|---------|----------|
| `paywall(for: PremiumPaywallID)` | `PremiumPaywall?` | Получить пейвол по ID |
| `spendTokens(_ amount: Int)` | `Bool` | Списать токены. Возвращает `true` при успехе |
| `hasActiveProduct(_ productId: String)` | `Bool` | Проверить активна ли подписка по product ID |
| `hasActiveProduct(fromPaywall: PremiumPaywallID)` | `Bool` | Проверить есть ли активная подписка с конкретного пейвола |
| `logout()` | `Void` | Выход из Apphud. Сбрасывает isPremium и activeProductIds |

### Пример использования properties

```swift
struct ContentView: View {
    @ObservedObject private var premium = Premium.shared
    
    var body: some View {
        MainView()
            .overlay {
                if premium.isShowingSplash {
                    SplashView()
                }
            }
            .fullScreenCover(isPresented: $premium.isShowingPaywall) {
                PaywallView()
            }
    }
}
```

## Покупка

### Базовая покупка

```swift
let result = await Premium.shared.purchase(product)

switch result {
case .success:
    // Успешная покупка
    dismiss()
    
case .failure(let error):
    handleError(error)
}
```

### Обработка ошибок

```swift
func handleError(_ error: PremiumError) {
    switch error {
    case .cancelled:
        // Пользователь отменил — ничего не делаем
        break
        
    case .pending:
        // Покупка ожидает подтверждения (например, Ask to Buy)
        showAlert("Покупка ожидает подтверждения")
        
    case .productNotAvailable:
        showAlert("Продукт временно недоступен")
        
    case .network:
        showAlert("Ошибка сети. Проверьте подключение")
        
    case .verificationFailed:
        showAlert("Ошибка верификации покупки")
        
    case .purchaseFailed(let message):
        showAlert("Ошибка покупки: \(message)")
        
    case .paymentNotAllowed:
        showAlert("Покупки запрещены на этом устройстве")
        
    case .paymentInvalid:
        showAlert("Неверные платёжные данные")
        
    case .billingIssue:
        showAlert("Проблема с оплатой. Обновите способ оплаты")
        
    case .notEntitled:
        showAlert("Вы не можете совершить эту покупку")
        
    case .restoreNothingToRestore:
        showAlert("Нет покупок для восстановления")
        
    case .restoreFailed(let message):
        showAlert("Ошибка восстановления: \(message)")
        
    case .unknown:
        showAlert("Произошла ошибка. Попробуйте позже")
    }
}
```

### PremiumError

| Ошибка | Описание |
|--------|----------|
| `.cancelled` | Пользователь отменил покупку |
| `.pending` | Покупка ожидает подтверждения (Ask to Buy) |
| `.productNotAvailable` | Продукт недоступен |
| `.network` | Ошибка сети |
| `.verificationFailed` | Ошибка верификации покупки |
| `.purchaseFailed(message)` | Ошибка покупки с сообщением |
| `.paymentNotAllowed` | Покупки запрещены на устройстве |
| `.paymentInvalid` | Неверные платёжные данные |
| `.billingIssue` | Проблема с оплатой |
| `.notEntitled` | Пользователь не может совершить покупку |
| `.restoreNothingToRestore` | Нет покупок для восстановления |
| `.restoreFailed(message)` | Ошибка восстановления с сообщением |
| `.unknown` | Неизвестная ошибка |

## Восстановление покупок

```swift
let result = await Premium.shared.restore()

switch result {
case .success:
    showAlert("Покупки восстановлены!")
    
case .failure(let error):
    handleError(error)
}
```

## API

### Событие показа paywall

```swift
// Вызывайте когда paywall показан пользователю
Premium.shared.paywallShown()
```

### Получение paywall по ID

```swift
// Получить конкретный paywall
let paywall = Premium.shared.paywall(for: .consumable)
```

### Расход токенов

```swift
// Списать 1 токен (по умолчанию)
let success = Premium.shared.spendTokens()

// Списать несколько токенов
let success = Premium.shared.spendTokens(5)
```

## Проверка подписок по пейволу

Для доп. платных фич (например AI-чат поверх основной подписки) используйте проверку активных подписок по конкретному пейволу:

### Проверка по пейволу

```swift
extension PremiumPaywallID {
    static let aiChat = PremiumPaywallID("aiChat")
}

// Загрузить пейвол
await Premium.shared.loadPaywall(.aiChat)

// Проверить есть ли активная подписка с этого пейвола
if premium.hasActiveProduct(fromPaywall: .aiChat) {
    // Дать доступ к AI-чату
}
```

### Проверка по product ID

```swift
if premium.hasActiveProduct("com.app.aiChatMonthly") {
    // Подписка активна
}
```

### Показ/скрытие баннера

```swift
@ObservedObject private var premium = Premium.shared

var body: some View {
    MainView()
        .overlay {
            if !premium.hasActiveProduct(fromPaywall: .aiChat) {
                AIChatBannerView()
            }
        }
}
```

## PremiumAvailableProducts

Типы доступных продуктов для онбординга:

| Тип | Описание |
|-----|----------|
| `.both` | Доступны продукты с trial и без |
| `.withTrial` | Только продукт с trial |
| `.noTrial` | Только продукт без trial |

### Пример использования

```swift
@ObservedObject private var premium = Premium.shared

var body: some View {
    switch premium.availableProducts {
    case .both:
        // Показать toggle для выбора trial
        TrialToggleView()
    case .withTrial:
        // Показать только trial вариант
        TrialOnlyView()
    case .noTrial:
        // Показать только обычный вариант
        RegularOnlyView()
    }
}
```

## PremiumProduct

Модель продукта с информацией о цене и периоде.

### Properties

| Property | Тип | Описание |
|----------|-----|----------|
| `id` | `String` | Product ID |
| `title` | `String` | Название из Apphud JSON |
| `subtitle` | `String?` | Подзаголовок из Apphud JSON |
| `message` | `String?` | Сообщение из Apphud JSON |
| `period` | `String` | Период из Apphud JSON |
| `hasTrial` | `Bool` | Есть ли trial |
| `isLifetime` | `Bool` | Lifetime продукт |
| `pricePerPeriod` | `String` | Цена за период|
| `pricePerWeek` | `String` | Цена за неделю |
| `consumable` | `Int?` | Количество токенов при покупке |
| `consumableUnit` | `String?` | Единица измерения токенов |
| `paywallSubtitle` | `String` | trial: subtitle + цена, non-trial: nonTrialSubtitle + цена |
| `nonTrialSubtitle` | `String?` | Подзаголовок для non-trial продуктов ("Get full access for just") |
| `consumableSubtitle` | `String?` | Форматированная строка consumable (например "5 videos/week") |

## PremiumPaywall

Модель paywall с продуктами и текстами кнопок.

### Properties

| Property | Тип | Описание |
|----------|-----|----------|
| `title` | `String` | Заголовок paywall |
| `configuration` | `PaywallConfiguration` | Конфигурация (A/B тесты) |
| `products` | `[PremiumProduct]` | Массив продуктов |
| `buttons` | `Buttons` | Тексты кнопок |

### PremiumPaywall.Buttons

| Property | Тип | Описание |
|----------|-----|----------|
| `tryFree` | `String` | Текст кнопки для trial |
| `continue` | `String` | Текст кнопки для обычной подписки |
| `purchase` | `String` | Текст кнопки для lifetime |
| `limited` | `String` | Текст кнопки "or proceed with limited version" |

### Получение текста кнопки

```swift
guard let product = selectedProduct else {
    return ""
}

// Автоматический выбор текста в зависимости от продукта
let buttonText = premiumService.availablePaywall.buttonTitle(for: product)
```

## Полный пример

```swift
import SwiftUI
import PremiumKit

struct CustomPaywallView: View {
    @ObservedObject private var premium = Premium.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedProduct: PremiumProduct?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            Text(premium.availablePaywall.title)
                .font(.largeTitle.bold())
            
            // Продукты
            ForEach(premium.availablePaywall.products) { product in
                ProductRow(
                    product: product,
                    isSelected: selectedProduct?.id == product.id
                )
                .onTapGesture {
                    selectedProduct = product
                }
            }
            
            // Кнопка покупки
            Button(action: purchase) {
                if isLoading {
                    ProgressView()
                } else {
                    Text(buttonTitle)
                }
            }
            .disabled(selectedProduct == nil || isLoading)
            
            // Восстановление
            Button("Restore Purchases") {
                Task { await restore() }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    var buttonTitle: String {
        guard let product = selectedProduct else {
            return "Continue & subscribe"
        }
        return premium.availablePaywall.buttonTitle(for: product)
    }
    
    func purchase() {
        guard let product = selectedProduct else { return }
        
        isLoading = true
        Task {
            let result = await premium.purchase(product)
            isLoading = false
            
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                if case .cancelled = error {
                    // Ignore cancellation
                } else {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func restore() async {
        isLoading = true
        let result = await premium.restore()
        isLoading = false
        
        switch result {
        case .success:
            dismiss()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}
```

## Topics

### Service

- ``Premium``
- ``PremiumConfiguration``

### Models

- ``PremiumPaywall``
- ``PremiumProduct``
- ``PremiumError``
- ``PremiumAvailableProducts``
- ``PremiumPaywallID``
- ``PaywallConfiguration``
