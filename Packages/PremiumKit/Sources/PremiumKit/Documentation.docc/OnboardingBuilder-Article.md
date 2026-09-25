# OnboardingBuilder

Создание онбординга с несколькими экранами и встроенным пейволом.

## Overview

``OnboardingBuilder`` — готовый компонент для создания онбординг флоу. Последний экран автоматически показывает пейвол.

## Базовое использование

Минимальная настройка онбординга:

```swift
import SwiftUI
import PremiumKit

struct OnboardingView: View {
    var body: some View {
        OnboardingBuilder(
            screens: [
                OnboardingScreen(
                    id: 0,
                    title1: "Welcome to",
                    title2: "MyApp",
                    subtitle: "Discover amazing features",
                    images: AdaptiveResources(iphone: .onboarding1)
                ),
                OnboardingScreen(
                    id: 1,
                    title1: "Stay",
                    title2: "Organized", 
                    subtitle: "Keep everything in one place",
                    images: AdaptiveResources(iphone: .onboarding2)
                )
            ],
            paywallImages: AdaptiveResources(iphone: .paywall),
            onComplete: {
                // метод завершения онобрдинг флоу
            }
        )
    }
}
```

## OnboardingScreen

Каждый экран описывается структурой ``OnboardingScreen``:

```swift
OnboardingScreen(
    id: 0,                              // Уникальный ID
    title1: "Welcome to",               // Первая строка
    title2: "MyApp",                    // Вторая строка (акцент)
    subtitle: "Discover\namazing",      // Подзаголовок
    message: "Start your journey",      // Сообщение (опционально)
    buttonTitle: "Next",                // Текст кнопки
    images: AdaptiveResources(          // Изображения
        iphone: .onb1,
        iphoneS: .onb1SE,
        ipadL: .onb1Landscape
    ),
    showReviewRequest: false,            // Показать Request Review
    hideContent: [.indicators, .message, .button]  // Скрыть элементы на этом экране
)
```

## Request Review

### На определенном экране

Добавьте `showReviewRequest: true` чтобы показать Request Review при нажатии Continue:

```swift
OnboardingScreen(
    id: 2,
    title1: "Get",
    title2: "Started",
    subtitle: "Begin your journey",
    images: AdaptiveResources(iphone: .onb3),
    showReviewRequest: true  // Покажет Request Review при нажатии Continue
)
```

### После завершения онбординга

По умолчанию Request Review показывается автоматически после завершения онбординга (skip или покупка). Чтобы отключить:

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    showReviewRequestOnComplete: false,  // Отключить авто-показ
    onComplete: { }
)
```

### Отложенный показ на N-й запуск (requestReviewSetup)

По умолчанию Request Review вызывается **сразу** после завершения онбординга. Если приложение получило реджект из-за вызова оценки прямо на онбординге — используйте `requestReviewSetup`, чтобы отложить показ до N-го запуска приложения:

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    requestReviewSetup: RequestReviewSetup(
        isEnabled: true,   // Включить отложенный показ
        launch: 2,         // Показать на следующем запуске после онбординга
        delay: 2.0         // Задержка в секундах после скрытия сплэша
    ),
    onComplete: { }
)
```

Параметры `RequestReviewSetup`:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `isEnabled` | `Bool` | `true` | Включить отложенный показ |
| `launch` | `Int` | `2` | Через сколько запусков после завершения онбординга показать оценку. `2` = следующий запуск приложения, `3` = через один. Минимум — следующий запуск |
| `delay` | `TimeInterval` | `2.0` | Задержка в секундах перед показом, отсчёт стартует после скрытия сплэша (`isShowingSplash == false`) |

- Если `requestReviewSetup` **не задан** (`nil`) — работает старое поведение: оценка вызывается сразу после онбординга (с учётом `showReviewRequestOnComplete`).
- Если задан и `isEnabled: true` — оценка откладывается до `launch`-запуска и показывается через `delay` секунд после исчезновения сплэша.

> Important: Отсчёт `launch` идёт от запуска, на котором завершён онбординг. Значение `2` (по умолчанию) покажет оценку при первом возврате в приложение — уже вне экрана онбординга.

## Скрытие элементов (hideContent)

Скрывайте определённые элементы контента на конкретном экране онбординга через `hideContent`:

```swift
OnboardingScreen(
    id: 0,
    title1: "Welcome",
    subtitle: "Get started",
    images: AdaptiveResources(iphone: .onb1),
    hideContent: [.indicators, .message]
)
```

Доступные элементы для скрытия (`OnboardingContentElement`):

| Элемент | Описание |
|---------|----------|
| `.indicators` | Индикаторы прогресса |
| `.title` | Заголовок (title1 + title2) |
| `.subtitle` | Подзаголовок |
| `.message` | Сообщение с toggle |
| `.button` | Основная кнопка перехода |

### Пример: первый экран без индикаторов

```swift
let screens = [
    OnboardingScreen(
        id: 0,
        title1: "Welcome to",
        title2: "MyApp",
        subtitle: "Discover amazing features",
        images: AdaptiveResources(iphone: .onb1),
        hideContent: [.indicators]  // Без индикаторов на первом экране
    ),
    OnboardingScreen(
        id: 1,
        title1: "Stay",
        title2: "Organized",
        subtitle: "Keep everything in one place",
        images: AdaptiveResources(iphone: .onb2)
        // hideContent по умолчанию [] — все элементы видны
    )
]
```

> Tip: `hideContent` работает per-screen. Каждый экран может скрывать свой набор элементов. По умолчанию массив пустой — все элементы видны.

### Скрытие элементов на пейвол-шаге (paywallHideContent)

`hideContent` в `OnboardingScreen` работает только для обычных экранов онбординга. На пейвол-шаге (и на встроенном secondary-шаге) собственного `OnboardingScreen` нет, поэтому для них используется отдельный параметр `paywallHideContent` в инициализаторе `OnboardingBuilder`:

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: AdaptiveResources(iphone: .paywall),
    paywallHideContent: [.indicators],  // скрыть индикаторы на пейвол-шаге
    onComplete: { }
)
```

Принимает тот же набор `OnboardingContentElement` (`.indicators`, `.title`, `.subtitle`, `.message`, `.button`). По умолчанию `[]` — все элементы видны.

## Отключение Cancelled Alert

По умолчанию при отмене покупки на пейвол-шаге показывается алерт с предложением повторить. Используйте `showCancelledAlert: false` чтобы отключить:

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    showCancelledAlert: false,
    onComplete: { }
)
```

## AdaptiveResources

Изображения для разных устройств:

```swift
AdaptiveResources(
    iphone: .mainImage,        // Обязательно
    iphoneS: .mainImageSE,     // iPhone SE (опционально)
    ipadL: .mainImageLandscape // iPad landscape (опционально)
)
```

## View-слоты

Каждый ``OnboardingScreen`` поддерживает 3 опциональных view-слота для расширения UI:

| Слот | Описание |
|------|----------|
| `backgroundView` | Заменяет стандартный Image-фон. Если передан — Image не рендерится |
| `middleView` | Между фоном и основным контентом в ZStack |
| `overlayView` | В `.overlay {}` поверх всего ZStack |

Все слоты опциональны — без них онбординг работает как раньше.

### Пример с кастомным фоном

```swift
OnboardingScreen(
    id: 0,
    title1: "Welcome",
    subtitle: "Get started",
    images: AdaptiveResources(iphone: .onb1),
    backgroundView: {
        LinearGradient(
            colors: [.purple, .black],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    },
    middleView: { EmptyView() },
    overlayView: { EmptyView() }
)
```

### Пример с анимацией и оверлеем

```swift
OnboardingScreen(
    id: 1,
    title1: "Discover",
    title2: "Features",
    subtitle: "Everything you need",
    images: AdaptiveResources(iphone: .onb2),
    backgroundView: { Color.black.ignoresSafeArea() },
    middleView: { FeatureAnimationView() },
    overlayView: { ParticlesOverlay() }
)
```

### Комбинирование с обычными экранами

View-слоты задаются на каждый экран отдельно. Экраны без слотов используют стандартный Image-фон:

```swift
let screens = [
    // Экран с кастомным фоном
    OnboardingScreen(
        id: 0,
        title1: "Welcome",
        subtitle: "Get started",
        images: AdaptiveResources(iphone: .onb1),
        backgroundView: { Color.black.ignoresSafeArea() },
        middleView: { LottieAnimationView("welcome") },
        overlayView: { EmptyView() }
    ),
    // Обычный экран — стандартный Image-фон
    OnboardingScreen(
        id: 1,
        title1: "Stay",
        title2: "Organized",
        subtitle: "Keep everything in one place",
        images: AdaptiveResources(iphone: .onb2)
    )
]
```

### Paywall View-слоты

Помимо view-слотов на каждом экране, ``OnboardingBuilder`` поддерживает 3 опциональных `AnyView?` параметра для **пейвол-шага** (последний экран, который показывает пейвол). Они передаются в init `OnboardingBuilder`, а не в `OnboardingScreen`:

| Параметр | Описание |
|----------|----------|
| `paywallBackgroundView` | Заменяет стандартный Image-фон на пейвол-шаге |
| `paywallMiddleView` | Между фоном и контентом на пейвол-шаге |
| `paywallOverlayView` | В `.overlay {}` поверх всего на пейвол-шаге |

Все параметры по умолчанию `nil`. Можно передавать любую комбинацию — не обязательно все три сразу.

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: AdaptiveResources(iphone: .paywall),
    paywallMiddleView: AnyView(FeaturesScrollView()),
    paywallOverlayView: AnyView(BadgeView()),
    onComplete: { }
)
```

> Tip: Оборачивайте view в `AnyView(...)` при передаче. Фон (Image) останется стандартным, если `paywallBackgroundView` не передан.

## Вторичный пейвол (Secondary Paywall)

После успешной покупки на пейвол-шаге можно показать **вторичный пейвол** с другим оффером. Есть два режима — они взаимоисключающие.

### Режим 1: Готовый view (`secondaryPaywallView`)

Передайте любой готовый экран (например ``SecondaryPaywallBuilder``) как `AnyView?`. После покупки на онбординг-пейволе он показывается вместо контента онбординга.

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: AdaptiveResources(iphone: .paywall),
    secondaryPaywallView: AnyView(
        SecondaryPaywallBuilder(paywallID: .aiChat, images: ..., ...)
    ),
    onComplete: { }
)
```

### Режим 2: Встроенный шаг (embedded)

Вместо отдельного view вторичный пейвол становится **обычным шагом онбординга** — полностью повторяет стиль онбординг-пейвола (индикаторы, toggle/picker, кнопка, links), но с продуктами и текстами из другого пейвола. Включается передачей `secondaryPaywallID` + `secondaryPaywallImages`.

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: AdaptiveResources(iphone: .paywall),
    secondaryPaywallID: .aiChat,
    secondaryPaywallImages: AdaptiveResources(iphone: .aiChatBG),
    secondaryPaywallMiddleView: AnyView(AIFeaturesView()),
    secondaryPaywallCountsAsStep: true,
    onComplete: { }
)
```

Параметры встроенного режима:

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `secondaryPaywallID` | `PremiumPaywallID?` | `nil` | ID пейвола, из которого берутся продукты, title/subtitle/message/button |
| `secondaryPaywallImages` | `AdaptiveResources?` | `nil` | Ассеты фона для встроенного шага |
| `secondaryPaywallBackgroundView` | `AnyView?` | `nil` | Заменяет Image-фон на встроенном шаге |
| `secondaryPaywallMiddleView` | `AnyView?` | `nil` | Между фоном и контентом на встроенном шаге |
| `secondaryPaywallOverlayView` | `AnyView?` | `nil` | В `.overlay {}` поверх всего на встроенном шаге |
| `secondaryPaywallCountsAsStep` | `Bool` | `false` | `true` — добавляет ещё одну точку в индикатор шагов; `false` — индикатор не растёт |

- **Данные** (title / subtitle / message / продукты / кнопка / цена) берутся из `secondaryPaywallID`, а не из онбординг-пейвола.
- **Выход**: покупка или skip-link → `onComplete()` (как на онбординг-пейволе).
- **Загрузка**: продукты пейвола `secondaryPaywallID` грузит хост (`Premium.shared.loadPaywall(_:)`) до показа онбординга.

> Important: Встроенный режим имеет приоритет. Если переданы и `secondaryPaywallID` + `secondaryPaywallImages`, и `secondaryPaywallView` — используется встроенный шаг, `secondaryPaywallView` игнорируется.

## Анимация кнопки покупки

Добавьте `showPaywallButtonAnimation: true` для плавной пульсации кнопки на пейвол-шаге. На обычных шагах онбординга кнопка остаётся статичной. В `OnboardingStyle` этот параметр включён по умолчанию.

Чтобы пульсация шла на **каждом** экране онбординга, добавьте `showButtonAnimationAlways: true` (по умолчанию `false`).

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    style: OnboardingStyle(
        showPaywallButtonAnimation: true,
        showButtonAnimationAlways: true,
        buttonAnimationDuration: 0.8,
        buttonAnimationScale: 0.92
    ),
    onComplete: { }
)
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `showPaywallButtonAnimation` | `Bool` | `true` | Мастер-выключатель пульсации |
| `showButtonAnimationAlways` | `Bool` | `false` | Анимация на всех шагах, а не только на пейвол-шаге |
| `buttonAnimationDuration` | `CGFloat` | `0.8` | Длительность одного цикла (секунды) |
| `buttonAnimationScale` | `CGFloat` | `0.92` | Минимальный масштаб при пульсации |

> Note: `showPaywallButtonAnimation: false` полностью отключает анимацию, даже если `showButtonAnimationAlways: true`.

## Чекмарка вместо Toggle (showNewToggle)

По умолчанию на пейвол-шаге рядом с сообщением показывается нативный `Toggle`. Если `showNewToggle: true` — вместо него отображается кастомная чекмарка (круг с галочкой), как в ``PaywallBuilder``.

Логика переключения триала остаётся прежней — меняется только визуал.

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    style: OnboardingStyle(
        showNewToggle: true,
        checkmarkSize: 24,
        checkmarkActiveBGColor: .blue,
        checkmarkInactiveBGColor: .clear,
        checkmarkActiveColor: .white,
        checkmarkActiveBorderColor: Color.secondary.opacity(0.3),
        checkmarkInactiveBorderColor: .clear,
        checkmarkIconSize: 14,
        checkmarkIconWeight: .semibold
    ),
    onComplete: { }
)
```

## Picker и кастомный subtitle для Today

Чтобы заменить стандартный toggle на picker, установите `toggleType: .picker` и передайте ``PickerPaywallStyle``. Поля `pickerTodayTrialSubtitle` и `pickerTodayNonTrialSubtitle` задают разные subtitle первой строки **Today** для триального и безтриального продуктов:

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    style: OnboardingStyle(
        toggleType: .picker,
        pickerStyle: PickerPaywallStyle(
            pickerTodayTrialSubtitle: "Триал начнётся без списания",
            pickerTodayNonTrialSubtitle: "Полный доступ начинается сегодня"
        )
    ),
    onComplete: { }
)
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `pickerTodayTrialSubtitle` | `String?` | `nil` | Subtitle строки Today при выборе триального продукта |
| `pickerTodayNonTrialSubtitle` | `String?` | `nil` | Subtitle строки Today при выборе продукта без триала |

Каждое незаполненное поле независимо использует локализованный текст `picker.today.subtitle`.

Остальные параметры и пример настройки для secondary paywall описаны в <doc:PickerPaywall-Article>.

## Кастомизация стиля

Используйте ``OnboardingStyle`` для кастомизации. Цвета и градиенты передаются напрямую:

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    style: OnboardingStyle(
        backgroundColor: .black,
        contentBackgroundShow: true,
        contentBackgroundColor: Color.white.opacity(0.95),
        contentBackgroundCornerRadius: 32,
        contentBackgroundBorderColor: Color.clear,
        contentBackgroundBorderWidth: 0.5,
        contentBackgroundShadow: nil,
        contentBackgroundPadding: BackgroundPadding(horizontal: 20, bottom: 20),
        title1Color: .white,
        title2Color: LinearGradient(
            colors: [.pink, .purple],
            startPoint: .leading,
            endPoint: .trailing
        ),
        buttonBackgroundColor: LinearGradient(
            colors: [.pink, .purple],
            startPoint: .leading,
            endPoint: .trailing
        )
    ),
    onComplete: { }
)
```

## Background Padding

Используйте `contentBackgroundPadding` чтобы фон "отлипал" от краёв экрана:

```swift
OnboardingStyle(
    contentBackgroundShow: true,
    contentBackgroundPadding: BackgroundPadding(horizontal: 20, bottom: 20)
)
```

При наличии отступов фон автоматически использует скругление всех углов (RoundedRectangle). Без отступов — только верхние углы (UnevenRoundedRectangle).

## Фон прогресс-индикаторов

Область прогресс-индикаторов поддерживает отдельный фон и внутренние отступы. Фон принимает любой `ShapeStyle`, включая цвет или градиент:

```swift
OnboardingStyle(
    indicatorBackgroundColor: LinearGradient(
        colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
        startPoint: .leading,
        endPoint: .trailing
    ),
    indicatorBackgroundCornerRadius: 12,
    indicatorHorizontalPadding: 16,
    indicatorVerticalPadding: 8
)
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `indicatorBackgroundColor` | `any ShapeStyle` | `Color.clear` | Фон всей области индикаторов |
| `indicatorBackgroundCornerRadius` | `CGFloat` | `0` | Радиус скругления фона индикаторов |
| `indicatorHorizontalPadding` | `CGFloat` | `0` | Горизонтальный внутренний отступ фона |
| `indicatorVerticalPadding` | `CGFloat` | `0` | Вертикальный внутренний отступ фона |
| `indicatorCornerRadius` | `CGFloat` | `100` | Радиус углов самих индикаторов: `100` — капсула (по умолчанию), `0` — квадратные |

Сначала к индикаторам применяются отступы, затем фон заполняет получившуюся увеличенную область.

### Квадратные индикаторы

По умолчанию индикаторы — скруглённая «капсула». Для квадратного вида задайте `indicatorCornerRadius: 0`:

```swift
OnboardingStyle(
    indicatorCornerRadius: 0,      // квадратные индикаторы
    indicatorActiveWidth: 20,
    indicatorInactiveWidth: 8,
    indicatorHeight: 8
)
```

Подходит любое промежуточное значение радиуса; стиль применяется ко всем состояниям индикатора (активный, пройденные, будущие).

## Порядок элементов (Content Order)

Используйте `contentOrder` для изменения порядка элементов контента:

```swift
OnboardingStyle(
    contentOrder: [.title, .subtitle, .indicators, .message]
)
```

Доступные элементы `OnboardingContentElement`:

| Элемент | Описание |
|---------|----------|
| `.indicators` | Индикаторы прогресса |
| `.title` | Заголовок (title1 + title2) |
| `.subtitle` | Подзаголовок |
| `.message` | Сообщение с toggle |

По умолчанию: `[.indicators, .title, .subtitle, .message]`

## Кастомизация цены (Price Customization)

На пейвол-шаге подзаголовок состоит из `subtitle` + `pricePerPeriod`. Используйте `priceCustomization` для стилизации цены:

```swift
OnboardingStyle(
    priceCustomization: [.heavy, .underline]  // жирная + подчёркнутая
)
```

Доступные опции `PriceCustomization`:

| Опция | Описание |
|-------|----------|
| `.heavy` | Жирный шрифт для цены |
| `.underline` | Подчёркивание цены |

Примеры:
```swift
priceCustomization: .heavy           // только жирная
priceCustomization: .underline       // только подчёркивание
priceCustomization: [.heavy, .underline]  // оба
priceCustomization: nil              // без кастомизации (по умолчанию)
```

Дополнительно можно задать свой шрифт и цвет цены (применяются поверх `priceCustomization`):

```swift
OnboardingStyle(
    priceCustomizationFont: .system(size: 15, weight: .bold),
    priceCustomizationColor: .red
)
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `priceCustomizationFont` | `Font?` | `nil` | Шрифт цены |
| `priceCustomizationColor` | `Color?` | `nil` | Цвет цены |

## Разделение подзаголовка (Split Subtitle)

Разбивает `subtitle` по индексу слова и стилизует часть **до** слова и часть **от** слова (включая само слово) по-разному. Полезно для визуального разделения текста под требования App Store review:

```swift
// "Unlimited access to all premium features"
//  слова:   0        1     2  3    4       5
// splitSubtitleBy: 2 → до = "Unlimited access", от = "to all premium features"
OnboardingStyle(
    splitSubtitleBy: 2,
    subtitleBeforeFont: .system(size: 15, weight: .regular),
    subtitleBeforeColor: Color.secondary.opacity(0.4),
    subtitleAfterFont: .system(size: 15, weight: .semibold),
    subtitleAfterColor: Color.secondary.opacity(0.9)
)
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `splitSubtitleBy` | `Int?` | `nil` | Индекс слова, по которому делится подзаголовок |
| `subtitleBeforeFont` | `Font?` | `nil` | Шрифт части до слова (`words[0..<index]`) |
| `subtitleBeforeColor` | `Color?` | `nil` | Цвет части до слова |
| `subtitleAfterFont` | `Font?` | `nil` | Шрифт части от слова включительно (`words[index...]`) |
| `subtitleAfterColor` | `Color?` | `nil` | Цвет части от слова включительно |

> Note: Split-стилизация применяется первой, затем поверх диапазона цены накладывается `priceCustomization` (если цена присутствует в подзаголовке).

## Кнопка Limited Button

Кнопка "Limited version" на пейвол-шаге. По умолчанию использует `subtitleFont` / `subtitleColor`. Можно переопределить шрифт, цвет и подчёркивание:

```swift
OnboardingStyle(
    limitedButtonUnderline: true,
    limitedButtonFont: .system(size: 15, weight: .semibold),
    limitedButtonColor: Color.secondary.opacity(0.6)
)
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `limitedButtonUnderline` | `Bool` | `false` | Подчёркивание кнопки |
| `limitedButtonFont` | `Font?` | `nil` | Шрифт кнопки (fallback — `subtitleFont`) |
| `limitedButtonColor` | `(any ShapeStyle)?` | `nil` | Цвет кнопки (fallback — `subtitleColor`) |

## Колбэки для метрик

Опциональные замыкания для аналитики. Все с дефолтом `nil` — можно указывать только нужные.

| Параметр | Тип | Когда вызывается |
|----------|-----|------------------|
| `onScreenShown` | `((Int, Int) -> Void)?` | Показан экран онбординга |
| `onNextTapped` | `((Int, Int) -> Void)?` | Тап по кнопке на обычном экране |
| `onLimitedTapped` | `(() -> Void)?` | Тап по limited-кнопке на пейвол-шаге |
| `onSecondaryLimitedTapped` | `(() -> Void)?` | Тап по limited-кнопке на вторичном пейволе |
| `onPaywallShown` | `(() -> Void)?` | Показан основной пейвол-шаг |
| `onSecondaryPaywallShown` | `(() -> Void)?` | Показан вторичный пейвол |

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    onScreenShown: { index, screenID in
        Analytics.log("onb_screen", ["index": index, "id": screenID])
    },
    onNextTapped: { index, screenID in
        Analytics.log("onb_next", ["index": index, "id": screenID])
    },
    onLimitedTapped: { Analytics.log("onb_limited") },
    onSecondaryLimitedTapped: { Analytics.log("onb_secondary_limited") },
    onPaywallShown: { Analytics.log("onb_paywall_shown") },
    onSecondaryPaywallShown: { Analytics.log("onb_secondary_shown") },
    onComplete: { }
)
```

У `onScreenShown` и `onNextTapped` первый параметр — индекс шага, второй — `id` вашего ``OnboardingScreen``.

> Note: Оба значения берутся **до** перехода, то есть относятся к экрану, на котором нажали кнопку. `onNextTapped` приходит только на обычных экранах — на пейвол-шаге кнопка запускает покупку.

## Внешний вызов next (OnboardingController)

``OnboardingController`` позволяет листать онбординг из своего кода — например по кнопке в собственном оверлее.

```swift
struct RootView: View {
    @StateObject private var controller = OnboardingController()

    var body: some View {
        OnboardingBuilder(
            screens: screens,
            paywallImages: paywallImages,
            controller: controller,
            onComplete: { }
        )
        .overlay(alignment: .topTrailing) {
            Button("Skip") { controller.next() }
        }
    }
}
```

- Держите контроллер в `@StateObject`, иначе он пересоздастся при перерисовке.
- Связка происходит в `.onAppear` билдера — вызывать `next()` можно после появления онбординга.
- `next()` делает то же, что тап по кнопке: на обычном шаге листает дальше, **на пейвол-шаге запускает покупку**.

## Два триала или два безтриала на пейвол-шаге

Если из Apphud приходят **два продукта одного типа** — два триальных или два безтриальных, — toggle/checkmark и пикер работают как переключатель между этими продуктами:

- **Первый продукт** (порядок — из JSON пейволла, с учётом `hiddenProductIDs`) занимает положение «выключено»: в пикере — левый сегмент, выбранный по умолчанию; в toggle/checkmark — выключенное состояние.
- **Второй продукт** — положение «включено»: правый сегмент пикера, включённый toggle/checkmark.
- По умолчанию toggle/checkmark **выключены**, выбран первый продукт.
- При переключении обновляются все данные выбранного продукта: message, subtitle, цена, кнопка и секция периодов пикера.
- В пикере бейдж «Trial» показывается над каждым сегментом, чей продукт триальный: при двух триалах — над обоими, при двух безтриальных — нет.
- Алерт «Trial Unavailable» для такой пары не показывается.

Работает одинаково на основном пейвол-шаге и на встроенном secondary-шаге (`secondaryPaywallID`). При классическом наборе (триал + безтриальный) поведение не меняется: безтриальный слева выбран по умолчанию, триальный справа с бейджем.

## Trial Expired Alert

Если пользователь уже использовал триал (Apphud/StoreKit возвращает продукт без `hasTrial`), при попытке включить toggle/checkmark/picker на триальный продукт переключение блокируется и показывается локализованный алерт. Работает автоматически, не требует дополнительной настройки. Исключение — пара продуктов одного типа (два триала или два безтриальных): переключение между ними не требует триала, алерт не показывается.

## Terms и Privacy

### Вариант 1: View (sheet/fullScreenCover)

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    legalPresentation: .fullScreenCover,
    termsView: { TermsView() },
    privacyView: { PrivacyView() },
    onComplete: { }
)
```

### Вариант 2: URL (открывается в браузере)

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    termsURL: "https://example.com/terms",
    privacyURL: "https://example.com/privacy",
    onComplete: { }
)
```

## Footer

Настройте текст и порядок кнопок:

```swift
OnboardingBuilder(
    screens: screens,
    paywallImages: paywallImages,
    linksConfig: LinksConfiguration(
        termsTitle: "Terms of Use",
        privacyTitle: "Privacy Policy",
        restoreTitle: "Restore",
        order: [.restore, .terms, .privacy]
    ),
    termsURL: "https://example.com/terms",
    privacyURL: "https://example.com/privacy",
    onComplete: { }
)
```

## Полный пример

```swift
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        OnboardingBuilder(
            screens: [
                OnboardingScreen(
                    id: 0,
                    title1: "Welcome to",
                    title2: "MyApp",
                    subtitle: "Discover\namazing features",
                    message: "Start your journey",
                    buttonTitle: "Next",
                    images: AdaptiveResources(
                        iphone: .onb1,
                        iphoneS: .onb1SE,
                        ipadL: .onb1Landscape
                    )
                ),
                OnboardingScreen(
                    id: 1,
                    title1: "Stay",
                    title2: "Organized",
                    subtitle: "Keep everything\nin one place",
                    message: "Manage with ease",
                    buttonTitle: "Next",
                    images: AdaptiveResources(
                        iphone: .onb2,
                        iphoneS: .onb2SE,
                        ipadL: .onb2Landscape
                    )
                ),
                OnboardingScreen(
                    id: 2,
                    title1: "Get",
                    title2: "Started",
                    subtitle: "Begin your\njourney today",
                    message: "Let's go!",
                    buttonTitle: "Continue",
                    images: AdaptiveResources(
                        iphone: .onb3,
                        iphoneS: .onb3SE,
                        ipadL: .onb3Landscape
                    ),
                    showReviewRequest: true
                )
            ],
            paywallImages: AdaptiveResources(
                iphone: .paywall,
                iphoneS: .paywallSE,
                ipadL: .paywallLandscape
            ),
            style: customStyle,
            linksConfig: LinksConfiguration(
                termsTitle: "Terms",
                privacyTitle: "Privacy",
                restoreTitle: "Restore",
                order: [.terms, .privacy, .restore]
            ),
            termsURL: "https://example.com/terms",
            privacyURL: "https://example.com/privacy",
            onComplete: {
                hasSeenOnboarding = true
            }
        )
    }
    
    var customStyle: OnboardingStyle {
        OnboardingStyle(
            toggleColor: .pink,
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
            messageBorderColor: Color.gray.opacity(0.3),
            messageBorderWidth: 1,
            messageShowBorder: true,
            messageBottomPadding: 0,
            buttonFont: .system(size: 20, weight: .bold),
            buttonTextColor: .white,
            buttonBackgroundColor: LinearGradient(
                colors: [.pink, .purple],
                startPoint: .leading,
                endPoint: .trailing
            ),
            buttonCornerRadius: 100,
            buttonBorderColor: .purple,
            buttonBorderWidth: 1,
            buttonShowBorder: false,
            buttonBottomPadding: 0,
            linksFont: .system(size: 13, weight: .regular),
            linksColor: Color.secondary.opacity(0.3),
            linksBottomPadding: 0,
            indicatorActiveColor: LinearGradient(
                colors: [.pink, .purple],
                startPoint: .leading,
                endPoint: .trailing
            ),
            indicatorInactiveColor: Color.pink.opacity(0.2),
            indicatorFutureColor: Color.pink.opacity(0.2),
            indicatorActiveHeight: 6,
            indicatorInactiveHeight: 6,
            indicatorsBottomPadding: 0
        )
    }
}
```

## Topics

### Related

- ``OnboardingBuilder``
- ``OnboardingScreen``
- ``OnboardingStyle``
- ``AdaptiveResources``
- <doc:Customization-Article>
- <doc:PickerPaywall-Article>
