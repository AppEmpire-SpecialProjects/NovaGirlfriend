import Combine

/// Domain harness only: production compiles PremiumStore from the app target.
/// Existing transport tests exercise paid features with an active entitlement;
/// focused policy tests inject and vary their own entitlement authority.
@MainActor
final class PremiumStore: ObservableObject {
  static let shared = PremiumStore()
  @Published var isPremium = true
}
