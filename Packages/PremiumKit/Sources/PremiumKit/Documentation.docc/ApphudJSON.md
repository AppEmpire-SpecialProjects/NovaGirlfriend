# Apphud JSON Configuration

Настройка JSON paywall в Apphud.

## Overview

PremiumKit использует JSON конфигурацию из Apphud для получения информации о продуктах и текстах кнопок.

## Onboarding Paywall

JSON для onboarding пейвола с безтриальным продуктом:

```json
{
  "title": "Unlock Premium",
  "limitedButton": "Or proceed with limited version",
  "tryFreeButton": "Continue",
  "continueButton": "Continue",
  "products": [
    {
      "id": "com.app.week",
      "title": "Optimal",
      "subtitle": "Try 3 days free then",
      "nonTrialSubtitle": "Get full access for just",
      "message": "Enable a 3 days free trial",
      "periodly": "Weekly"
    }
  ]
}
```

JSON для onboarding пейвола с триальным продуктом:

```json
{
  "title": "Unlock Premium",
  "limitedButton": "Or proceed with limited version",
  "tryFreeButton": "Continue",
  "continueButton": "Continue",
  "products": [
    {
      "id": "com.app.weektrial",
      "title": "3 days free trial",
      "subtitle": "Try 3 days free then",
      "nonTrialSubtitle": "Get full access for just",
      "message": "Enable a 3 days free trial",
      "periodly": "Weekly"
    }
  ]
}
```

## Main Paywall

JSON для main пейвола:

```json
{
  "title": "Unlimited access!",
  "tryFreeButton": "Try free & subscribe",
  "continueButton": "Continue & subscribe",
  "purchaseButton": "Purchase & continue",
  "products": [
    {
      "id": "com.app.weektrial",
      "title": "Optimal",
      "subtitle": "Try 3 days free then",
      "periodly": "Weekly"
    },
    {
      "id": "com.app.month",
      "title": "Popular",
      "periodly": "Monthly"
    },
    {
      "id": "com.app.year",
      "title": "Best deal",
      "periodly": "Yearly"
    },
    {
      "id": "com.app.lifetime",
      "title": "Life time deal",
      "periodly": "This is a limited time offer"
    }
  ]
}
```

## Secondary Paywall

JSON для пейвола второй группы подписок. Формат аналогичен основному пейволу:

```json
{
  "title": "Unlock AI",
  "limitedButton": "Maybe later",
  "tryFreeButton": "Start free trial",
  "continueButton": "Continue",
  "purchaseButton": "Purchase",
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

Загрузка:

```swift
extension PremiumPaywallID {
    static let secondGroup = PremiumPaywallID("second_paywall")
}

await Premium.shared.loadPaywall(.secondGroup)
```

> Tip: Режим отображения выбирается автоматически: 1 продукт — без toggle, 2 продукта (trial + non-trial) — с toggle, 3+ — ряд кнопок.

## Поля JSON

### Paywall

| Поле | Описание |
|------|----------|
| `title` | Заголовок пейвола |
| `limitedButton` | Текст кнопки "пропустить" |
| `tryFreeButton` | Текст для продукта с trial |
| `continueButton` | Текст для продукта без trial |
| `purchaseButton` | Текст для lifetime продукта |
| `configurationAB` | Управляет PaywallConfiguration для A/B тестов |
| `showFallback` | `Bool` — если `true`, для всего пейвола принудительно используется fallback (mock) модель, игнорируя данные из Apphud |

### Product

| Поле | Описание |
|------|----------|
| `id` | Product ID из App Store Connect |
| `title` | Название продукта |
| `subtitle` | Подзаголовок (поддерживает `%@` — первый = цена, второй = период) |
| `nonTrialSubtitle` | Подзаголовок без триала (поддерживает `%@` — первый = цена) |
| `message` | Сообщение при выборе |
| `periodly` | Период подписки |
| `consumable` | Количество единиц consumable продукта |
| `consumableUnit` | Единица измерения consumable продукта |
| `locKey` | Ключ локализации продукта |
| `configurationAB` | Управляет PaywallConfiguration для A/B тестов |

## Consumable Paywall

JSON для consumable пейвола:

```json
{
  "title": "Get more videos",
  "purchaseButton": "Purchase",
  "configurationAB": "variant1",
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

## Периоды подписки

Доступные значения для `periodly`:

- `"Weekly"` — еженедельная
- `"Monthly"` — ежемесячная  
- `"Yearly"` — ежегодная
- Произвольный текст для lifetime

## Принудительный fallback (`showFallback`)

Флаг `showFallback: true` на уровне пейвола заставляет PremiumKit использовать локальную fallback (mock) модель для всего пейвола, полностью игнорируя данные из Apphud.

Полезно, когда в Apphud лежит старая модель, где отсутствует часть опциональных полей (`subtitle`, `nonTrialSubtitle`, `message` и т.д.) — вместо частичного заполнения показывается целостный mock.

```json
{
  "title": "Get Premium",
  "showFallback": true,
  "products": [ ... ]
}
```

## Загрузка пейволов

```swift
// Для онбординга
await Premium.shared.loadPaywall(.onboarding)

// Для main флоу
await Premium.shared.loadPaywall(.main)
```

## Topics

### Related

- ``Premium``
- ``PremiumPaywall``
- ``PremiumProduct``
