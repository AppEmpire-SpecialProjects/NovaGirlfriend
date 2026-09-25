# Consumable Flow

Работа с consumable токенами в подписках и одноразовых покупках.

## Overview

PremiumKit поддерживает consumable токены — ресурсы, которые пользователь получает при покупке и тратит при использовании функций приложения (например, генерации видео, изображений и т.д.).

Токены могут начисляться:
- При покупке подписки (бонусные токены)
- При покупке consumable продукта (пакеты токенов)

## JSON конфигурация

### Подписки с токенами

Добавьте поля `consumable` и `consumableUnit` к продуктам в Apphud JSON:

```json
{
  "title": "Unlimited access!",
  "tryFreeButton": "Try free & subscribe",
  "continueButton": "Continue & subscribe",
  "purchaseButton": "Purchase & continue",
  "products": [
    {
      "id": "com.yourapp.subscription.weekly",
      "title": "3 days free trial",
      "subtitle": "Try 3 days free then",
      "message": "Unlimited montage",
      "periodly": "Weekly",
      "consumable": 5,
      "consumableUnit": "videos"
    },
    {
      "id": "com.yourapp.subscription.monthly",
      "title": "Popular",
      "message": "Unlimited montage",
      "periodly": "Monthly",
      "consumable": 15,
      "consumableUnit": "videos"
    }
  ]
}
```

### Consumable продукты (пакеты токенов)

Для одноразовых покупок токенов создайте отдельный paywall:

```json
{
  "title": "Get more videos",
  "tryFreeButton": "",
  "continueButton": "",
  "purchaseButton": "Purchase",
  "products": [
    {
      "id": "com.yourapp.tokens.small",
      "title": "Starter Pack",
      "periodly": "",
      "consumable": 10,
      "consumableUnit": "videos"
    },
    {
      "id": "com.yourapp.tokens.large",
      "title": "Pro Pack",
      "periodly": "",
      "consumable": 50,
      "consumableUnit": "videos"
    }
  ]
}
```

## Новые поля JSON

| Поле | Тип | Описание |
|------|-----|----------|
| `consumable` | `Int?` | Количество токенов при покупке |
| `consumableUnit` | `String?` | Единица измерения (videos, credits, tokens) |

## PremiumProduct — новые свойства

| Property | Тип | Описание |
|----------|-----|----------|
| `consumable` | `Int?` | Количество токенов |
| `consumableUnit` | `String?` | Единица измерения |
| `consumableSubtitle` | `String?` | Форматированная строка (например "5 videos/week") |

## Premium Service — работа с токенами

### Получение баланса

```swift
let balance = Premium.shared.tokens
print("У пользователя \(balance) токенов")
```

### Списание токенов

```swift
// Списать 1 токен
let success = Premium.shared.spendTokens()

// Списать несколько токенов
let success = Premium.shared.spendTokens(3)

if success {
    // Токены списаны, выполняем действие
    generateVideo()
} else {
    // Недостаточно токенов
    showBuyTokensPaywall()
}
```

### Загрузка consumable paywall

```swift
// Загрузить paywall с пакетами токенов
await Premium.shared.loadPaywall(.consumable)
```

## Полный пример

```swift
import SwiftUI
import PremiumKit

struct GenerateView: View {
    @ObservedObject private var premium = Premium.shared
    @State private var showTokensPaywall = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Баланс токенов
            HStack {
                Image(systemName: "film")
                Text("\(premium.tokens) videos left")
            }
            .font(.headline)
            
            // Кнопка генерации
            Button("Generate Video") {
                generateVideo()
            }
            .disabled(premium.tokens == 0 && !premium.isPremium)
            
            // Купить токены (показывается когда isPremium && tokens == 0)
            if premium.isPremium && premium.tokens == 0 {
                Button("Buy More Videos") {
                    Task {
                        await premium.loadPaywall(.consumable)
                    }
                    showTokensPaywall = true
                }
            }
        }
        .fullScreenCover(isPresented: $showTokensPaywall) {
            TokensPaywallView()
        }
    }
    
    private func generateVideo() {
        if premium.spendTokens() {
            // Токен списан — генерируем видео
            startVideoGeneration()
        } else if premium.isPremium {
            // Премиум есть, но токены кончились — загружаем и показываем consumable paywall
            Task {
                await premium.loadPaywall(.consumable)
            }
            showTokensPaywall = true
        } else {
            // Нет премиума — показываем основной paywall
            premium.isShowingPaywall = true
        }
    }
}
```

## Отображение токенов в UI

### Подписки с токенами

Для подписок формируйте строку из `message`, `consumable`, `consumableUnit` и периода:

```swift
func consumableString(for product: PremiumProduct) -> String {
    guard let consumable = product.consumable, 
          let unit = product.consumableUnit else {
        return product.pricePerWeek
    }
    
    // "Unlimited montage + 5 videos/week"
    let message = product.message.isEmpty ? "" : "\(product.message) + "
    let period = product.pricePerPeriod.components(separatedBy: "/").last ?? ""
    return "\(message)\(consumable) \(unit)/\(period)"
}
```

### Consumable продукты

Для пакетов токенов показывайте только количество:

```swift
func tokensString(for product: PremiumProduct) -> String {
    guard let consumable = product.consumable,
          let unit = product.consumableUnit else {
        return ""
    }
    
    // "10 videos"
    return "\(consumable) \(unit)"
}
```

## Автоматическое начисление

Токены начисляются автоматически после успешной покупки:
- Подписка с `consumable: 5` → +5 токенов
- Consumable продукт с `consumable: 50` → +50 токенов

Хранение токенов — Keychain (защита от сброса при переустановке).

## Topics

### Service

- ``Premium``

### Models

- ``PremiumProduct``
- ``PremiumPaywallID``
