import Foundation
import UIKit

@MainActor
enum AvatarStorage {
    private static let prefix = "uploaded-avatar:"

    static func save(imageData: Data, characterID: UUID) throws -> String {
        guard let image = UIImage(data: imageData),
              let jpeg = image.jpegData(compressionQuality: 0.85) else {
            throw AvatarStorageError.unsupportedImage
        }
        let directory = try avatarDirectory()
        let name = "\(characterID.uuidString).jpg"
        try jpeg.write(to: directory.appendingPathComponent(name), options: .atomic)
        return prefix + name
    }

    static func image(for reference: String?) -> UIImage? {
        guard let reference, reference.hasPrefix(prefix),
              let directory = try? avatarDirectory() else { return nil }
        let name = String(reference.dropFirst(prefix.count))
        return UIImage(contentsOfFile: directory.appendingPathComponent(name).path)
    }

    static func duplicate(reference: String?, characterID: UUID) throws -> String? {
        guard let reference, reference.hasPrefix(prefix),
              let directory = try? avatarDirectory() else { return reference }
        let sourceName = String(reference.dropFirst(prefix.count))
        let destinationName = "\(characterID.uuidString).jpg"
        let destination = directory.appendingPathComponent(destinationName)
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(
            at: directory.appendingPathComponent(sourceName),
            to: destination
        )
        return prefix + destinationName
    }

    static func delete(reference: String?) {
        guard let reference, reference.hasPrefix(prefix),
              let directory = try? avatarDirectory() else { return }
        let name = String(reference.dropFirst(prefix.count))
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(name))
    }

    private static func avatarDirectory() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = base.appendingPathComponent("CustomAvatars", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

enum AvatarStorageError: LocalizedError {
    case unsupportedImage

    var errorDescription: String? {
        "The selected item could not be saved as an image."
    }
}
