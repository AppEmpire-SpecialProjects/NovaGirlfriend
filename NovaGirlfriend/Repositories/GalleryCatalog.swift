import Foundation

enum GalleryCatalog {
  // Original illustrations and the finished portraits are bundled product art,
  // not generated memories or evidence of a user's relationship progress.
  static let moments: [GalleryMomentDefinition] = [
    collection(1, "Astraea", artwork: "Nova"),
    collection(2, "Zephyra", artwork: "Maya"),
    collection(3, "Elowen", artwork: "Elena"),
    collection(4, "Vespera", artwork: "Sofia"),
    collection(5, "Kaida", artwork: "Aiko"),
    collection(6, "Selene", artwork: "Luna"),
    collection(7, "Aurelia", artwork: "Iris"),
    collection(8, "Miyuki", artwork: "Yuki"),
  ].flatMap { $0 }

  private static func collection(_ index: Int, _ name: String, artwork: String)
    -> [GalleryMomentDefinition]
  {
    let characterID = UUID(uuidString: "A1000000-0000-0000-0000-00000000000\(index)")!
    return [
      GalleryMomentDefinition(
        id: UUID(uuidString: "D1000000-0000-0000-000\(index)-000000000001")!,
        characterID: characterID,
        title: "\(name)'s portrait",
        imageAsset: "\(artwork)Portrait",
        unlockRule: .initial
      ),
      GalleryMomentDefinition(
        id: UUID(uuidString: "D1000000-0000-0000-000\(index)-000000000002")!,
        characterID: characterID,
        title: "Original Illustration",
        imageAsset: "\(artwork)GalleryOriginal",
        unlockRule: .exchanges(5)
      ),
    ]
  }
}
