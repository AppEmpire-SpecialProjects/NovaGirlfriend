# Localization

Настройка локализации PremiumKit.

## Overview

PremiumKit поддерживает 30 языков из коробки. Тексты кнопок, ошибок и периодов подписки автоматически локализуются на язык устройства.

## Поддерживаемые языки (30)

### Западная Европа
| Код | Язык |
|-----|------|
| `en` | Английский |
| `de` | Немецкий |
| `fr` | Французский |
| `es` | Испанский |
| `it` | Итальянский |
| `pt` | Португальский |
| `nl` | Нидерландский |
| `sv` | Шведский |
| `ca` | Каталанский |

### Восточная Европа
| Код | Язык |
|-----|------|
| `ru` | Русский |
| `uk` | Украинский |
| `pl` | Польский |
| `cs` | Чешский |
| `sk` | Словацкий |
| `hu` | Венгерский |
| `ro` | Румынский |
| `bg` | Болгарский |
| `hr` | Хорватский |
| `sl` | Словенский |

### Азия
| Код | Язык |
|-----|------|
| `ja` | Японский |
| `ko` | Корейский |
| `zh-Hans` | Китайский (упрощённый) |
| `th` | Тайский |
| `vi` | Вьетнамский |
| `id` | Индонезийский |
| `ms` | Малайский |

### Другие
| Код | Язык |
|-----|------|
| `tr` | Турецкий |
| `el` | Греческий |
| `ar` | Арабский |
| `he` | Иврит |

## Настройка

### Базовая настройка

```swift
Premium.shared.configure(PremiumConfiguration(
    apiKey: "app_xxx",
    supportedLanguages: [.en, .ru, .de],
    defaultLanguage: .en
))
```

### Параметры

| Параметр | Описание |
|----------|----------|
| `supportedLanguages` | Массив языков, которые поддерживает ваше приложение |
| `defaultLanguage` | Язык по умолчанию, если язык устройства не поддерживается |

### Пример для глобального приложения

```swift
Premium.shared.configure(PremiumConfiguration(
    apiKey: "app_xxx",
    supportedLanguages: PremiumLanguage.allCases, // все 30 языков
    defaultLanguage: .en
))
```

Или выборочно:

```swift
Premium.shared.configure(PremiumConfiguration(
    apiKey: "app_xxx",
    supportedLanguages: [
        // Западная Европа
        .en, .de, .fr, .es, .it, .pt, .nl, .sv, .ca,
        // Восточная Европа
        .ru, .uk, .pl, .cs, .sk, .hu, .ro, .bg, .hr, .sl,
        // Азия
        .ja, .ko, .zhHans, .th, .vi, .id, .ms,
        // Другие
        .tr, .el, .ar, .he
    ],
    defaultLanguage: .en
))
```

## JSON конфигурация в Apphud

PremiumKit автоматически локализует все тексты через встроенные ключи. В JSON для каждого продукта укажите `id` и `locKey`:

```json
{
  "products": [
    {
      "id": "com.app.weektrial",
      "locKey": "main.weekly_trial",
      "title": "",
      "periodly": ""
    },
    {
      "id": "com.app.month",
      "locKey": "main.monthly",
      "title": "",
      "periodly": ""
    },
    {
      "id": "com.app.year",
      "locKey": "main.yearly",
      "title": "",
      "periodly": ""
    }
  ]
}
```

`locKey` — префикс ключа локализации. PremiumKit добавит `.title`, `.subtitle`, `.message`, `.periodly` автоматически.

### Main Paywall JSON (полный пример с ключами)

Для каждого продукта укажите `locKey` — префикс ключа локализации. PremiumKit автоматически подставит `.title`, `.subtitle`, `.message`, `.periodly` к этому префиксу.

```json
{
  "title": "main.title",
  "tryFreeButton": "main.button.try_free",
  "continueButton": "main.button.continue",
  "purchaseButton": "main.button.purchase",
  "products": [
    {
      "id": "com.app.weektrial",
      "locKey": "main.weekly_trial",
      "title": "",
      "periodly": ""
    },
    {
      "id": "com.app.month",
      "locKey": "main.monthly",
      "title": "",
      "periodly": ""
    },
    {
      "id": "com.app.year",
      "locKey": "main.yearly",
      "title": "",
      "periodly": ""
    },
    {
      "id": "com.app.lifetime",
      "locKey": "main.lifetime",
      "title": "",
      "periodly": ""
    }
  ]
}
```

Например `"locKey": "main.weekly_trial"` резолвится в:
- `main.weekly_trial.title` — название
- `main.weekly_trial.subtitle` — подзаголовок
- `main.weekly_trial.message` — сообщение
- `main.weekly_trial.periodly` — период

### Onboarding Paywall JSON (полный пример с ключами)

```json
{
  "title": "onboarding.title",
  "limitedButton": "onboarding.button.limited",
  "tryFreeButton": "onboarding.button.try_free",
  "continueButton": "onboarding.button.continue",
  "products": [
    {
      "id": "com.app.weektrial",
      "locKey": "onboarding.weekly_trial",
      "title": "",
      "periodly": ""
    },
    {
      "id": "com.app.week",
      "locKey": "onboarding.weekly",
      "title": "",
      "periodly": ""
    }
  ]
}
```

## Ключи локализации

### Main Paywall

| Ключ | Описание |
|------|----------|
| `main.title` | Заголовок пейвола |
| `main.button.try_free` | Кнопка с trial |
| `main.button.continue` | Кнопка без trial |
| `main.button.purchase` | Кнопка lifetime |

#### Main Products

| Ключ | Описание |
|------|----------|
| `main.weekly_trial.title` | Название недельного с trial |
| `main.weekly_trial.subtitle` | Подзаголовок |
| `main.weekly_trial.message` | Сообщение |
| `main.weekly_trial.periodly` | Период |
| `main.monthly.title` | Название месячного |
| `main.monthly.subtitle` | Подзаголовок |
| `main.monthly.message` | Сообщение |
| `main.monthly.periodly` | Период |
| `main.yearly.title` | Название годового |
| `main.yearly.subtitle` | Подзаголовок |
| `main.yearly.message` | Сообщение |
| `main.yearly.periodly` | Период |
| `main.lifetime.title` | Название lifetime |
| `main.lifetime.subtitle` | Подзаголовок |
| `main.lifetime.message` | Сообщение |
| `main.lifetime.periodly` | Период |

### Onboarding Paywall

| Ключ | Описание |
|------|----------|
| `onboarding.title` | Заголовок пейвола |
| `onboarding.button.limited` | Кнопка пропуска |
| `onboarding.button.try_free` | Кнопка с trial |
| `onboarding.button.continue` | Кнопка без trial |

#### Onboarding Products

| Ключ | Описание |
|------|----------|
| `onboarding.weekly_trial.title` | Название недельного с trial |
| `onboarding.weekly_trial.subtitle` | Подзаголовок |
| `onboarding.weekly_trial.message` | Сообщение |
| `onboarding.weekly_trial.periodly` | Период |
| `onboarding.weekly.title` | Название недельного |
| `onboarding.weekly.subtitle` | Подзаголовок |
| `onboarding.weekly.message` | Сообщение |
| `onboarding.weekly.periodly` | Период |

### Общие кнопки (fallback)

| Ключ | Описание | EN | RU |
|------|----------|----|----|
| `button.try_free` | Кнопка с trial | Try free & subscribe | Попробовать бесплатно |
| `button.continue` | Кнопка без trial | Continue & subscribe | Продолжить и подписаться |
| `button.purchase` | Кнопка lifetime | Purchase & continue | Купить и продолжить |
| `button.limited` | Кнопка пропуска | or continue with limited version | или продолжить с ограниченной версией |
| `button.next` | Просто продолжить | Continue | Продолжить |

### Периоды

| Ключ | Описание | EN | RU |
|------|----------|----|----|
| `period.week` | Неделя | week | неделя |
| `period.month` | Месяц | month | месяц |
| `period.year` | Год | year | год |
| `period.day` | День | day | день |
| `period.one_time` | Разовая покупка | one-time | разовая |

### Ошибки

| Ключ | Описание |
|------|----------|
| `error.product_unavailable` | Продукт недоступен |
| `error.network` | Ошибка сети |
| `error.cancelled` | Покупка отменена |
| `error.pending` | Покупка ожидает подтверждения |
| `error.verification_failed` | Ошибка верификации |
| `error.nothing_to_restore` | Нечего восстанавливать |
| `error.payment_not_allowed` | Покупки запрещены |
| `error.payment_invalid` | Невалидные данные оплаты |
| `error.billing_issue` | Проблема с оплатой |
| `error.not_entitled` | Нет прав на покупку |
| `error.unknown` | Неизвестная ошибка |

### Ссылки

| Ключ | Описание | EN | RU |
|------|----------|----|----|
| `links.terms` | Условия использования | Terms of Use | Условия использования |
| `links.privacy` | Политика конфиденциальности | Privacy Policy | Политика конфиденциальности |
| `links.restore` | Восстановить покупки | Restore | Восстановить |

### Picker Paywall

Тексты для пикер-пейвола (см. <doc:PickerPaywall-Article>):

| Ключ | Описание | EN | RU |
|------|----------|----|----|
| `picker.badge.trial` | Бейдж триала | Trial | Пробный |
| `picker.today` | Заголовок "Сегодня" | Today | Сегодня |
| `picker.today.subtitle` | Описание "Сегодня" | Enjoy unlimited access | Наслаждайтесь неограниченным доступом |
| `picker.future.title` | Заголовок периода (%@ = период) | In %@ | Через %@ |
| `picker.future.subtitle.trial` | Описание с триалом (%1 = цена, %2 = период) | Subscription auto-renews at %@ after the %@ trial. Cancel anytime | Подписка автоматически продлевается за %@ после пробного периода %@. Отмена в любое время |
| `picker.future.subtitle.nonTrial` | Описание без триала (%@ = цена) | Subscription auto-renews at %@. Cancel anytime | Подписка автоматически продлевается за %@. Отмена в любое время |
| `onboarding.weekly_picker_trial` | Подзаголовок с триалом (%1 = цена, %2 = период) | Subscribe to unlock all the features, just for %@ + %@ free trial | Подпишитесь на все функции, всего за %@ + %@ бесплатный пробный период |
| `onboarding.weekly_picker_nonTrial` | Подзаголовок без триала (%@ = цена) | Subscribe to unlock all the features, just for %@ | Подпишитесь на все функции, всего за %@ |
| `picker.segment.trial` | Заглушка сегмента триала (когда триал использован) | 3 days | 3 дня |
| `onboarding.message.trial` | Сообщение под кнопкой (с триалом), опционально из JSON | Start A Free Trial | Начать бесплатный период |
| `onboarding.message.nonTrial` | Сообщение под кнопкой (без триала), опционально из JSON | Not sure yet? Start a free trial | Ещё не уверены? Начните бесплатный период |

### Trial Expired Alert

| Ключ | Описание | EN | RU |
|------|----------|----|----|
| `alert.trial_expired.title` | Заголовок алерта | Trial Unavailable | Пробный период недоступен |
| `alert.trial_expired.message` | Сообщение алерта | You've already used your free trial. You can subscribe without a trial period. | Вы уже использовали бесплатный пробный период. Вы можете оформить подписку без пробного периода. |

## Свои ключи локализации

Можно использовать собственные ключи из бандла приложения — PremiumKit подхватит их автоматически.

### 1. Добавьте строки в свой app-таргет

Создайте `Localizable.xcstrings` (или `Localizable.strings`) в проекте приложения и добавьте нужные языки:

```
// en.lproj/Localizable.strings
"myapp.paywall.title" = "Unlock everything";
"myapp.product.weekly.title" = "Weekly";

// ru.lproj/Localizable.strings
"myapp.paywall.title" = "Открой всё";
"myapp.product.weekly.title" = "Неделя";
```

### 2. Способ А — без кода (рекомендуется)

Укажите ключ как значение поля в Apphud JSON или fallback JSON:

```json
{
  "title": "myapp.paywall.title",
  "products": [
    { "id": "weekly_trial", "title": "myapp.product.weekly.title" }
  ]
}
```

Поля, проходящие через локализацию: заголовок пейвола, кнопки, а у продукта — `title`, `subtitle`, `nonTrialSubtitle`, `message`, `periodly`.

### 3. Способ Б — через extension

Если строка нужна в собственном коде:

```swift
import PremiumKit

extension L10n {
    enum MyApp {
        static var paywallTitle: String { localized("myapp.paywall.title") }
    }
}

Text(L10n.MyApp.paywallTitle)
```

> Tip: Публичные методы ``L10n``: `localized(_:)`, `localized(_:_:)`, `localizedOrNil(_:)`, `resolve(_:)`, `resolveOptional(_:)`.

### Важно

- Язык **своих** ключей определяется локализациями app-таргета, а не `supportedLanguages` из `PremiumConfiguration`. Если в приложении нет `ru.lproj`, пользователь увидит базовый язык, даже когда PremiumKit показывает свои строки на русском.
- Не используйте префиксы системных ключей PremiumKit (`button.`, `error.`, `alert.`, `period.`, `price.`, `links.`, `product.`, `picker.`) — возьмите свой, например `myapp.`.
- Если ключ не найден нигде, вернётся сам ключ — на экране будет `myapp.paywall.title`.

## Как работает локализация

1. PremiumKit определяет язык устройства
2. Если язык есть в `supportedLanguages` — используется он
3. Иначе используется `defaultLanguage`
4. Все тексты берутся из встроенных ключей локализации
5. Если ключ не найден в бандле PremiumKit — поиск повторяется в `Bundle.main` (бандл приложения)

## Topics

### Related

- ``PremiumConfiguration``
- ``PremiumLanguage``
- <doc:ApphudJSON>
- <doc:PickerPaywall-Article>
