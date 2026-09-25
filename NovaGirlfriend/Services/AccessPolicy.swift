import Combine
import Foundation

/// App-wide access decisions. Only verified store entitlements grant Premium.
@MainActor
final class AccessPolicy: ObservableObject {
  enum Feature { case scenarios, photoAI, remoteSpeech, additionalCompanions }

  enum Denial: LocalizedError {
    case dailyTextLimit
    case premiumRequired

    var errorDescription: String? {
      switch self {
      case .dailyTextLimit:
        "Your 10 free AI replies for today are used or in progress. Try tomorrow or unlock Premium."
      case .premiumRequired:
        "This feature requires Premium. Your saved conversations and companions remain available."
      }
    }
  }

  static let freeDailyLimit = 10
  static let shared: AccessPolicy = {
    let store = PremiumStore.shared
    let policy = AccessPolicy(isPremium: { store.isPremium })
    policy.entitlementSubscription = store.$isPremium.sink { [weak policy] _ in
      policy?.objectWillChange.send()
    }
    return policy
  }()

  private let defaults: UserDefaults
  private let now: () -> Date
  private let calendar: () -> Calendar
  private let premium: () -> Bool
  private var reservations: [UUID: Bool] = [:]
  private var entitlementSubscription: AnyCancellable?
  private let usageKey = "accessPolicy.successfulTextReplies"
  private let dayKey = "accessPolicy.textReplyDay"

  init(
    defaults: UserDefaults = .standard,
    now: @escaping () -> Date = Date.init,
    calendar: @escaping () -> Calendar = { .current },
    isPremium: @escaping () -> Bool
  ) {
    self.defaults = defaults
    self.now = now
    self.calendar = calendar
    self.premium = isPremium
  }

  var isPremium: Bool { premium() }

  private var today: Date { calendar().startOfDay(for: now()) }

  var successfulRepliesToday: Int {
    guard defaults.object(forKey: dayKey) as? Date == today else { return 0 }
    return defaults.integer(forKey: usageKey)
  }

  var remainingTextReplies: Int {
    max(0, Self.freeDailyLimit - successfulRepliesToday - reservations.values.filter { $0 }.count)
  }

  func require(_ feature: Feature) throws {
    guard isPremium else { throw Denial.premiumRequired }
  }

  func requireCompanionCreation(existingCount: Int) throws {
    if existingCount >= 1 { try require(.additionalCompanions) }
  }

  /// Main-actor admission is atomic across all open conversations. Reservations
  /// are transient: a process exit cannot permanently consume a failed request.
  func reserveTextReply() throws -> UUID {
    guard isPremium || remainingTextReplies > 0 else { throw Denial.dailyTextLimit }
    let token = UUID()
    objectWillChange.send()
    reservations[token] = !isPremium
    return token
  }

  /// Only a successfully persisted, noncancelled reply consumes a slot. The
  /// completion calendar day owns the usage, including requests crossing midnight.
  func finishTextReply(_ token: UUID, succeeded: Bool) {
    guard let wasFree = reservations.removeValue(forKey: token) else { return }
    objectWillChange.send()
    guard succeeded, wasFree else { return }
    let used = successfulRepliesToday
    defaults.set(today, forKey: dayKey)
    defaults.set(used + 1, forKey: usageKey)
  }
}
