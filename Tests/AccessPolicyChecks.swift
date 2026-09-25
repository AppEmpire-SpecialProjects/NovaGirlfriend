import Foundation

@main
@MainActor
struct AccessPolicyChecks {
  static func denied(_ action: () throws -> Void) {
    do {
      try action()
      preconditionFailure("Expected access denial")
    } catch is AccessPolicy.Denial {
    } catch {
      preconditionFailure("Unexpected error: \(error)")
    }
  }

  static func main() throws {
    let suite = "AccessPolicyChecks.\(UUID())"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    var date = Date(timeIntervalSince1970: 1_800_000_000)
    var premium = false
    let policy = AccessPolicy(
      defaults: defaults, now: { date }, calendar: { calendar }, isPremium: { premium })

    var tokens: [UUID] = []
    for _ in 0..<10 { tokens.append(try policy.reserveTextReply()) }
    precondition(policy.remainingTextReplies == 0)
    denied { _ = try policy.reserveTextReply() }
    policy.finishTextReply(tokens.removeLast(), succeeded: false)
    precondition(policy.remainingTextReplies == 1)
    tokens.append(try policy.reserveTextReply())
    for token in tokens { policy.finishTextReply(token, succeeded: true) }
    precondition(policy.successfulRepliesToday == 10)
    policy.finishTextReply(tokens[0], succeeded: true)
    precondition(policy.successfulRepliesToday == 10)
    denied { _ = try policy.reserveTextReply() }
    let restored = AccessPolicy(
      defaults: defaults, now: { date }, calendar: { calendar }, isPremium: { premium })
    precondition(restored.remainingTextReplies == 0)
    print(
      "PASS: ten atomic reservations, failure release, success-only accounting, idempotence, persistence"
    )

    premium = true
    for _ in 0..<25 {
      let token = try policy.reserveTextReply()
      policy.finishTextReply(token, succeeded: true)
    }
    precondition(policy.successfulRepliesToday == 10)
    for feature in [AccessPolicy.Feature.scenarios, .photoAI, .remoteSpeech, .additionalCompanions]
    {
      try policy.require(feature)
    }
    try policy.requireCompanionCreation(existingCount: 50)
    premium = false
    denied { _ = try policy.reserveTextReply() }
    try policy.requireCompanionCreation(existingCount: 0)
    denied { try policy.requireCompanionCreation(existingCount: 1) }
    for feature in [AccessPolicy.Feature.scenarios, .photoAI, .remoteSpeech, .additionalCompanions]
    {
      denied { try policy.require(feature) }
    }
    print(
      "PASS: unlimited Premium, immediate expiry enforcement, one free companion, paid feature decisions"
    )

    date = calendar.date(byAdding: .day, value: 1, to: date)!
    precondition(policy.remainingTextReplies == 10)
    let crossing = try policy.reserveTextReply()
    date = calendar.date(byAdding: .day, value: 1, to: date)!
    precondition(policy.remainingTextReplies == 9)
    policy.finishTextReply(crossing, succeeded: true)
    precondition(policy.successfulRepliesToday == 1)
    precondition(policy.remainingTextReplies == 9)
    print("PASS: calendar-day reset and in-flight reservation across midnight")
  }
}
