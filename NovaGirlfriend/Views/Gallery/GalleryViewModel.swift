import SwiftUI

struct GalleryDisplayItem: Identifiable {
  let id: UUID
  let character: CharacterProfile
  let title: String
  let image: UIImage
  let unlockRule: GalleryUnlockRule
  let isUnlocked: Bool
  let isSaved: Bool

  var isLocked: Bool { !isUnlocked }
}

@MainActor
struct GalleryViewModel {
  func entries(for character: CharacterProfile, records: [GalleryItemRecord])
    -> [GalleryDisplayItem]
  {
    let ownedRecords = records.filter {
      $0.characterID == character.id && $0.kindRawValue == "image"
    }
    let definitions =
      character.origin == .builtIn
      ? GalleryCatalog.moments.filter { $0.characterID == character.id } : []
    let bundled = definitions.compactMap { definition -> GalleryDisplayItem? in
      guard let image = UIImage(named: definition.imageAsset) else { return nil }
      let state = ownedRecords.first {
        $0.id == definition.id && $0.definitionID == definition.id.uuidString
      }
      return GalleryDisplayItem(
        id: definition.id, character: character, title: definition.title, image: image,
        unlockRule: definition.unlockRule,
        isUnlocked: state?.isUnlocked ?? (definition.unlockRule == .initial),
        isSaved: state?.isSaved ?? false
      )
    }
    let savedImages = ownedRecords.compactMap { record -> GalleryDisplayItem? in
      guard record.definitionID == nil,
        let image = localImage(record.localIdentifier, character: character)
      else { return nil }
      return GalleryDisplayItem(
        id: record.id, character: character,
        title: record.caption.flatMap { $0.isEmpty ? nil : $0 } ?? "Saved Moment",
        image: image, unlockRule: .initial,
        isUnlocked: record.isUnlocked, isSaved: record.isSaved
      )
    }
    return bundled + savedImages
  }

  private func localImage(_ reference: String, character: CharacterProfile) -> UIImage? {
    if let image = AvatarStorage.image(for: reference) { return image }
    if character.origin == .builtIn,
      GalleryCatalog.moments.contains(where: {
        $0.characterID == character.id && $0.imageAsset == reference
      })
    {
      return UIImage(named: reference)
    }
    let url =
      reference.hasPrefix("file:") ? URL(string: reference) : URL(fileURLWithPath: reference)
    guard let url, url.isFileURL else { return nil }
    let path = url.standardizedFileURL.resolvingSymlinksInPath().path
    let home = URL(fileURLWithPath: NSHomeDirectory()).resolvingSymlinksInPath().path + "/"
    guard path.hasPrefix(home) else { return nil }
    return UIImage(contentsOfFile: path)
  }
}
