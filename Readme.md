# NovaGirlfriend

---

## 1. Где находится Apphud
Интеграция подписок — локальный Swift-пакет:
```
Packages/PremiumKit
```
Пакет обфусцирован (см. `skills/premiumkit-integration`): загрузчик фолбэка и ключ декодера генерируются скриптом `scripts/obfuscate_premiumkit.py`.

Инициализация в приложении:
```
NovaGirlfriend/NovaGirlfriendApp.swift          → Premium.shared.configure(PremiumConfiguration(...))
NovaGirlfriend/Services/PurchaseConfiguration.swift → API-ключ и ID продуктов (обфусцированы)
```
API-ключ Apphud хранится в обфусцированном виде:
```
NovaGirlfriend/Services/AI/EndpointVault.swift  → EndpointVault.apphudAPIKey
```

---

## 2. Ограничения подписки и основной функционал

Один уровень подписки — **Premium** (плейсменты `onboarding`, `main`).

### Ограничения подписки:

| Функция | Бесплатно | Снимается |
|---|---|---|
| AI-ответы в чате | 10 в день | Premium |
| Создание компаньонов | 1 | Premium |
| Сценарии | — | Premium |
| Генерация фото | — | Premium |
| Удалённые голоса (TTS) | — | Premium |

Числа лимитов собраны в одном месте:
```
NovaGirlfriend/Services/AccessPolicy.swift
```
Ограничение действует только на **отправку нового** сообщения и создание **нового** объекта. Просмотр, редактирование и удаление уже сохранённых данных доступны всегда.

### Основной функционал:
- AI-чат с компаньонами: текст, голосовые сообщения, генерация фото.
- Галерея моментов с фильтрами и прогрессом отношений.
- Создание собственных компаньонов с загрузкой фото.
- Достижения, память фактов о пользователе, экспорт данных (JSON).

---

## 3. JSON Apphud (фолбэк)

Если плейсмент недоступен (нет сети), пейволл берётся из бандлированного фолбэка. JSON фолбэка **используется напрямую** — из него берутся тексты и состав продуктов:

| Файл | Роль |
|---|---|
| `NovaGirlfriend/Resources/apphud_paywalls_fallback.json` | Исходник для правок. **Не входит в таргет** (membershipExceptions в pbxproj) |
| `NovaGirlfriend/Resources/pk_b394db96455def729bb2de7e.json` | Зашифрованная копия (AES-256-GCM, ключ зашит в декодере PremiumKit). Входит в бандл |

Имя зашифрованного ресурса передаётся в `PremiumConfiguration(fallbackFileName:)` в `NovaGirlfriendApp.swift` и должно совпадать с именем файла.

### Плейсменты и продукты:

| Placement ID | Продукты |
|---|---|
| `onboarding` | `Nova.Girlfriend.app.Week`<br>`Nova.Girlfriend.app.WeekTrial` (3 дня бесплатно) |
| `main` | `Nova.Girlfriend.app.Week`<br>`Nova.Girlfriend.app.Month`<br>`Nova.Girlfriend.app.Year`<br>`Nova.Girlfriend.app.Lifetime` |

Состав карточек берётся **только из `json.products`** каждого плейсмента; `items`/`items_v2` парсер игнорирует.

### После правки фолбэка:
1. Отредактировать `apphud_paywalls_fallback.json` (правки в открытом файле сами по себе в бандл не попадают).
2. Перешифровать тем же ключом декодера PremiumKit:
```
xcrun swift skills/premiumkit-integration/scripts/reencrypt_fallback.swift \
  Packages/PremiumKit/Sources/PremiumKit/Internal/Obfuscation \
  NovaGirlfriend/Resources/apphud_paywalls_fallback.json \
  NovaGirlfriend/Resources/pk_b394db96455def729bb2de7e.json
```
3. Проверить принудительный фолбэк (DEBUG): launch argument `--premium-force-fallback`.

---

## 4. Основные пермишены

| Разрешение | Когда запрашивается |
|---|---|
| `NSMicrophoneUsageDescription` | Запись голосового сообщения |
| `NSPhotoLibraryAddUsageDescription` | Сохранение фото в галерею |

Задаются в `NovaGirlfriend.xcodeproj/project.pbxproj` (`INFOPLIST_KEY_*`).

---

## 5. Основные возможности (Capability)

Дополнительные capability, entitlements и фоновые режимы не используются.

---

## 6. Подключённые SDK

| SDK | Назначение |
|---|---|
| Apphud (через локальный PremiumKit) | Подписки и пейволлы |

Других SDK (аналитика, атрибуция, реклама) нет.

---

## 7. Реклама

Не используется.

---

📩 Telegram: @salakhoff1
