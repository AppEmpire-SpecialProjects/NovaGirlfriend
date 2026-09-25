import Foundation
import SwiftData

@MainActor
struct AffinityStore {
  let context: ModelContext

  func record(for characterID: UUID) throws -> AffinityRecord? {
    let descriptor = FetchDescriptor<AffinityRecord>(
      predicate: #Predicate { $0.characterID == characterID })
    return try context.fetch(descriptor).first
  }

  func points(for characterID: UUID) throws -> Int {
    try record(for: characterID)?.points ?? 0
  }

  func stage(for characterID: UUID) throws -> AffinityStage {
    AffinityStage.stage(forPoints: try points(for: characterID))
  }

  /// Number of companions currently at or beyond the given stage.
  func companions(atLeast stage: AffinityStage) throws -> Int {
    try context.fetch(FetchDescriptor<AffinityRecord>())
      .filter { AffinityStage.stage(forPoints: $0.points) >= stage }
      .count
  }

  /// Awards the points for one completed exchange and persists them.
  /// Returns the new stage when this exchange crossed into it.
  @discardableResult
  func awardExchange(to characterID: UUID) throws -> AffinityStage? {
    let record = try record(for: characterID)
      ?? {
        let created = AffinityRecord(characterID: characterID)
        context.insert(created)
        return created
      }()
    let previous = AffinityStage.stage(forPoints: record.points)
    let ceiling = AffinityStage.allCases.last!.threshold
    record.points = min(record.points + AffinityStage.pointsPerExchange, ceiling)
    record.updatedAt = .now
    try context.save()
    let current = AffinityStage.stage(forPoints: record.points)
    return current > previous ? current : nil
  }
}
