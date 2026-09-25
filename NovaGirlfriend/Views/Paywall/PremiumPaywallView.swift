import PremiumKit
import StoreKit
import SwiftUI

struct PremiumPaywallView: View {
  var placement: PremiumPaywallID = .main
  let onComplete: (_ purchased: Bool) -> Void

  @ObservedObject private var store = PremiumStore.shared
  @State private var isReady = false
  @State private var completionHandled = false
  @State private var entitlementError = false
  @State private var trialEligibleIDs: Set<String> = []
  @State private var isCheckingTrial = false

  var body: some View {
    Group {
      if isReady {
        PaywallBuilder(
          images: AdaptiveResources(
            iphone: Image("main_paywall"),
            iphoneS: Image("main_paywall_se"),
            ipadL: Image("main_paywall_landscape")
          ),
          style: style,
          linksConfig: LinksConfiguration(
            termsTitle: "Terms of Use", privacyTitle: "Privacy Policy", restoreTitle: "Restore"
          ),
          edgeToEdge: true,
          termsView: { LegalSheetView(document: .terms) },
          privacyView: { LegalSheetView(document: .privacy) },
          offerView: offerContent,
          subtitleText: paywallDescription,
          buttonText: paywallButtonText,
          onDebugUnlock: { store.enableSessionPremium() },
          hiddenProductIDs: hiddenProductIDs,
          onDismiss: { finish(purchased: false) },
          onSuccess: verifyPurchase
        )
      } else {
        VStack(spacing: 16) {
          if store.isLoading || isCheckingTrial {
            ProgressView("Loading plans…")
          } else {
            Text(store.errorMessage ?? "Plans are unavailable. Please try again.")
            Button("Retry") { Task { await load() } }
            Button("Close") { finish(purchased: false) }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "17191B"))
      }
    }
    .task(id: placement.rawValue) { await load() }
    .onChange(of: store.hasVerifiedEntitlement) { _, active in
      if active && entitlementError { finish(purchased: true) }
    }
    .alert("Purchases", isPresented: $entitlementError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Your purchase is processing. Access will update when Apple verifies it.")
    }
  }

  private func load() async {
    isReady = false
    isCheckingTrial = true
    defer { isCheckingTrial = false }
    await store.load(placement)
    guard !Task.isCancelled else { return }
    trialEligibleIDs = []
    for product in store.products {
      if let subscription = product.subscription,
        subscription.introductoryOffer?.paymentMode == .freeTrial,
        await subscription.isEligibleForIntroOffer
      {
        guard !Task.isCancelled else { return }
        trialEligibleIDs.insert(product.id)
      }
    }
    isReady = !store.products.isEmpty
  }

  private func verifyPurchase() {
    guard !completionHandled else { return }
    Task {
      await store.refreshEntitlements()
      if store.hasVerifiedEntitlement {
        finish(purchased: true)
      } else {
        entitlementError = true
      }
    }
  }

  private func finish(purchased: Bool) {
    guard !completionHandled else { return }
    completionHandled = true
    onComplete(purchased)
  }

  private var hiddenProductIDs: Set<String> {
    let available = Set(store.products.map(\.id))
    return Set(Premium.shared.availablePaywall.products.map(\.id)).subtracting(available)
  }

  private func paywallDescription(productID: String?) -> String {
    guard let product = store.products.first(where: { $0.id == productID }) else {
      return "Choose your plan"
    }
    if trialEligibleIDs.contains(product.id),
      let offer = product.subscription?.introductoryOffer,
      offer.paymentMode == .freeTrial,
      offer.period.unit == .day
    {
      let days = offer.period.value * offer.periodCount
      return "Try \(days) \(days == 1 ? "day" : "days") free then \(cardPrice(for: product))"
    }
    return cardPrice(for: product)
  }

  private func paywallButtonText(productID: String?) -> String? {
    guard let productID else { return nil }
    if trialEligibleIDs.contains(productID) { return "Try free & subscribe" }
    if Premium.shared.availablePaywall.products.contains(where: { $0.id == productID && $0.hasTrial }) {
      return "Continue"
    }
    return nil
  }

  private func offerContent(productID: String, isSelected: Bool) -> AnyView {
    guard let product = store.products.first(where: { $0.id == productID }) else {
      return AnyView(EmptyView())
    }
    return AnyView(
      HStack(spacing: 0) {
        Circle()
          .fill(
            isSelected
              ? AnyShapeStyle(PaywallPalette.gradient) : AnyShapeStyle(Color.clear)
          )
          .frame(width: 22, height: 22)
          .overlay {
            if isSelected {
              Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "17191B"))
            } else {
              Circle()
                .strokeBorder(Color(hex: "C7C7CC"), lineWidth: 1.25)
            }
          }
          .padding(.leading, 17)

        VStack(alignment: .leading, spacing: 0) {
          Text(cardTitle(for: product))
            .font(.system(size: 15, weight: .bold))
          Text(cardSubtitle(for: product))
            .font(.system(size: 13))
            .opacity(isSelected ? 0.8 : 0.6)
        }
        .foregroundStyle(isSelected ? .white : Color(hex: "F2F2F7"))
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .padding(.leading, 5)
        .frame(height: 38, alignment: .center)

        Spacer(minLength: 12)

        Text(cardPrice(for: product))
          .font(.system(size: 15, weight: .bold))
          .foregroundStyle(isSelected ? .white : Color(hex: "F2F2F7"))
          .padding(.leading, 16)
          .padding(.trailing, 16)
          .lineLimit(1)
          .minimumScaleFactor(0.6)
      }
      .frame(height: UIScreen.main.bounds.height < 740 ? 48 : 54)
      .background {
        Capsule().fill(
          isSelected
            ? AnyShapeStyle(PaywallPalette.gradient.opacity(0.22))
            : AnyShapeStyle(Color(hex: "272A2D"))
        )
      }
      .overlay {
        Capsule().strokeBorder(
          isSelected ? .clear : Color(hex: "3B3C3C"), lineWidth: 1
        )
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(
        "\(cardTitle(for: product)), \(cardSubtitle(for: product)), \(cardPrice(for: product))"
      )
      .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    )
  }

  private func cardTitle(for product: Product) -> String {
    switch cardKey(for: product) {
    case "week":
      if trialEligibleIDs.contains(product.id),
        let offer = product.subscription?.introductoryOffer,
        offer.period.unit == .day
      {
        let days = offer.period.value * offer.periodCount
        return "\(days) \(days == 1 ? "day" : "days") free trial"
      }
      return "Weekly"
    case "month": return "Popular"
    case "year": return "Best deal"
    case "lifetime": return "Lifetime deal"
    default: return product.displayName
    }
  }

  private func cardKey(for product: Product) -> String {
    let key = product.id.split(separator: ".").last.map(String.init)?.lowercased() ?? product.id
    return key == "weektrial" ? "week" : key
  }

  private func cardSubtitle(for product: Product) -> String {
    guard let period = product.subscription?.subscriptionPeriod else {
      return "This is a limited time offer"
    }
    let weeks: Decimal
    switch period.unit {
    case .day: weeks = Decimal(period.value) / 7
    case .week: weeks = Decimal(period.value)
    case .month: weeks = Decimal(period.value) * 52 / 12
    case .year: weeks = Decimal(period.value) * 52
    @unknown default: return "Total \(product.displayPrice) per \(self.period(for: product))"
    }
    let weeklyPrice = (product.price / weeks).formatted(product.priceFormatStyle)
    return "Total \(weeklyPrice) per week"
  }

  private func cardPrice(for product: Product) -> String {
    let suffix = product.subscription == nil ? "one time" : period(for: product)
    return "\(product.displayPrice)/\(suffix)"
  }

  private func period(for product: Product) -> String {
    guard let period = product.subscription?.subscriptionPeriod else { return "one-time payment" }
    var value = period.value
    let unit: String
    switch period.unit {
    case .day where value % 7 == 0:
      value /= 7
      unit = "week"
    case .day: unit = "day"
    case .week: unit = "week"
    case .month: unit = "month"
    case .year: unit = "year"
    @unknown default: unit = "period"
    }
    return value == 1 ? unit : "\(value) \(unit)s"
  }

  private enum PaywallPalette {
    static let gradient = LinearGradient(
      colors: [Color(hex: "6CF9FF"), Color(hex: "41E3FF")],
      startPoint: .leading, endPoint: .trailing
    )
  }

  private var style: PaywallStyle {
    PaywallStyle(
      accentColor: Color(hex: "59EDF4"),
      backgroundColor: Color(hex: "17191B"),
      titleColor: .white,
      subtitleColor: .white.opacity(0.8),
      buttonTextColor: Color(hex: "17191B"),
      buttonBackgroundColor: LinearGradient(
        colors: [Color(hex: "6CF9FF"), Color(hex: "41E3FF")],
        startPoint: .leading, endPoint: .trailing
      ),
      buttonHeight: UIDevice.isSe ? 48 : 56,
      linksColor: .white.opacity(0.8),
      contentSpacing: UIDevice.isSe ? 6 : 12,
      bottomPadding: UIDevice.isSe ? 12 : 34,
      offerCornerRadius: 100,
      offerTitleColor: .white,
      offerSelectedTitleColor: .white,
      offerSubtitleColor: .white.opacity(0.7),
      offerSelectedSubtitleColor: .white.opacity(0.8),
      offerPriceColor: .white,
      offerSelectedPriceColor: .white,
      offerBorderColor: Color(hex: "3B3C3C"),
      offerSelectedBorderColor: Color(hex: "59EDF4"),
      offerBorderWidth: 1,
      offerSelectedBorderWidth: 1,
      offerBackgroundColor: Color(hex: "272A2D"),
      offerSelectedBackgroundColor: LinearGradient(
        colors: [Color(hex: "6CF9FF"), Color(hex: "41E3FF")],
        startPoint: .leading, endPoint: .trailing
      ).opacity(0.22),
      offerCheckmarkActiveBGColor: Color(hex: "59EDF4"),
      offerCheckmarkActiveColor: Color(hex: "17191B"),
      closeButtonIcon: "xmark",
      closeButtonPlacement: .topBarTrailing
    )
  }
}

#Preview {
  PremiumPaywallView { _ in }
}
