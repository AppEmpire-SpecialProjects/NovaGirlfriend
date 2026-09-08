import Foundation
import SwiftData

@MainActor
protocol GalleryRepositoryProtocol {
  func items() throws -> [GalleryItemRecord]
  func save(_ item: GalleryItem) throws
  func delete(_ item: GalleryItemRecord) throws
}

@MainActor
final class SwiftDataGalleryRepository: GalleryRepositoryProtocol {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func items() throws -> [GalleryItemRecord] {
    try context.fetch(
      FetchDescriptor(sortBy: [SortDescriptor(\GalleryItemRecord.createdAt, order: .reverse)]))
  }

  func save(_ item: GalleryItem) throws {
    context.insert(GalleryItemRecord(item: item))
    try context.save()
  }

  func delete(_ item: GalleryItemRecord) throws {
    context.delete(item)
    try context.save()
  }

  @discardableResult
  func reconcile(
    definitions: [GalleryMomentDefinition]? = nil,
    now: Date = .now
  ) throws -> [UUID: Int] {
    // A separate read context excludes pending, unsaved UI/preview activity.
    let reader = ModelContext(context.container)
    reader.autosaveEnabled = false
    let counts = GalleryActivity.completedExchanges(
      in: try reader.fetch(FetchDescriptor<ConversationRecord>()))
    // Keep the observed context for immediate UI updates when it is clean.
    // Never commit another feature's unsaved edits along with gallery state.
    let writer = context.hasChanges ? ModelContext(context.container) : context
    let records = try writer.fetch(FetchDescriptor<GalleryItemRecord>())
    var inserted: [GalleryItemRecord] = []
    var changed: [(GalleryItemRecord, Bool, Date?)] = []
    for definition in definitions ?? GalleryCatalog.moments {
      let satisfied =
        counts[definition.characterID, default: 0]
        >= definition.unlockRule.requiredExchanges
      if let record = records.first(where: { $0.id == definition.id }) {
        guard record.definitionID == definition.id.uuidString,
          record.characterID == definition.characterID
        else { continue }
        if satisfied && !record.isUnlocked {
          changed.append((record, record.isUnlocked, record.unlockedAt))
          record.isUnlocked = true
          record.unlockedAt = now
        }
      } else {
        let record = GalleryItemRecord(
          item: GalleryItem(
            id: definition.id, characterID: definition.characterID,
            kind: .image, localIdentifier: definition.imageAsset,
            caption: definition.title, createdAt: now,
            definitionID: definition.id.uuidString,
            isUnlocked: satisfied, isSaved: false,
            unlockedAt: satisfied ? now : nil
          ))
        writer.insert(record)
        inserted.append(record)
      }
    }
    if !inserted.isEmpty || !changed.isEmpty {
      do {
        try writer.save()
      } catch {
        for record in inserted { writer.delete(record) }
        for (record, unlocked, date) in changed {
          record.isUnlocked = unlocked
          record.unlockedAt = date
        }
        throw error
      }
    }
    return counts
  }

  func setSaved(_ saved: Bool, id: UUID) throws {
    let writer = context.hasChanges ? ModelContext(context.container) : context
    let descriptor = FetchDescriptor<GalleryItemRecord>(predicate: #Predicate { $0.id == id })
    guard let record = try writer.fetch(descriptor).first, record.isUnlocked else { return }
    let previous = record.isSaved
    record.isSaved = saved
    do {
      try writer.save()
    } catch {
      record.isSaved = previous
      throw error
    }
  }
}
