import Foundation

enum ChatPhotoError: LocalizedError {
  case invalidData
  case invalidName

  var errorDescription: String? {
    switch self {
    case .invalidData: "The selected photo could not be read."
    case .invalidName: "Invalid photo reference."
    }
  }
}

/// Stores downscaled JPEG copies of photos the user shares in chat.
/// Files live in the app's Application Support directory; only file names are
/// persisted on `MessageRecord`.
@MainActor
enum ChatPhotoStore {
  private static let directoryName = "ChatPhotos"

  static func photoDirectory() throws -> URL {
    let base = try FileManager.default.url(
      for: .applicationSupportDirectory, in: .userDomainMask,
      appropriateFor: nil, create: true)
    let directory = base.appendingPathComponent(directoryName, isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }

  static func url(for file: String) throws -> URL {
    guard file == URL(fileURLWithPath: file).lastPathComponent, !file.isEmpty else {
      throw ChatPhotoError.invalidName
    }
    return try photoDirectory().appendingPathComponent(file)
  }

  @discardableResult
  static func save(data: Data) throws -> String {
    guard data.starts(with: [0xFF, 0xD8]) else { throw ChatPhotoError.invalidData }
    let name = UUID().uuidString + ".jpg"
    try data.write(to: try photoDirectory().appendingPathComponent(name), options: .atomic)
    return name
  }

  static func remove(_ file: String) {
    guard let url = try? url(for: file) else { return }
    try? FileManager.default.removeItem(at: url)
  }

  static func removeAll() throws {
    let directory = try photoDirectory()
    let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
    for url in contents { try FileManager.default.removeItem(at: url) }
  }
}
