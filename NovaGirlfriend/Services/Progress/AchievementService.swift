import Foundation
import SwiftData

@MainActor
struct AchievementStore {
  let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  // MARK: Unlocked achievements

  func unlockedIDs() throws -> Set<String> {
    Set(try context.fetch(FetchDescriptor<AchievementRecord>()).map(\.definitionID))
  }

  func records() throws -> [AchievementRecord] {
    try context.fetch(
      FetchDescriptor<AchievementRecord>(sortBy: [SortDescriptor(\.unlockedAt)]))
  }

  /// Marks every definition of `kind` whose threshold is now reached.
  /// Returns only the definitions unlocked by this call.
  @discardableResult
  func record(kind: AchievementKind, value: Int) throws -> [AchievementDefinition] {
    let unlocked = try unlockedIDs()
    let newly = AchievementCatalog.definitions(kind)
      .filter { value >= $0.tier && !unlocked.contains($0.id) }
    guard !newly.isEmpty else { return [] }
    for definition in newly {
      context.insert(AchievementRecord(definition: definition))
    }
    try context.save()
    return newly
  }

  // MARK: Daily streak

  func streak() throws -> UserStreakRecord {
    if let existing = try context.fetch(FetchDescriptor<UserStreakRecord>()).first {
      return existing
    }
    let created = UserStreakRecord()
    context.insert(created)
    try context.save()
    return created
  }

  /// Registers today's visit, extending or resetting the streak.
  /// Returns the streak achievements unlocked by this visit.
  @discardableResult
  func registerVisit(now: Date = .now) throws -> [AchievementDefinition] {
    let streak = try streak()
    let today = Self.dayString(for: now)
    guard streak.lastVisitDay != today else { return [] }
    if streak.lastVisitDay == Self.previousDayString(for: now) {
      streak.currentStreak += 1
    } else {
      streak.currentStreak = 1
    }
    streak.lastVisitDay = today
    streak.longestStreak = max(streak.longestStreak, streak.currentStreak)
    streak.updatedAt = now
    try context.save()
    return try record(kind: .streakDays, value: streak.currentStreak)
  }

  // MARK: Day strings

  private static let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    return formatter
  }()

  static func dayString(for date: Date) -> String {
    dayFormatter.string(from: date)
  }

  static func previousDayString(for date: Date) -> String {
    dayFormatter.string(from: date.addingTimeInterval(-86_400))
  }
}
