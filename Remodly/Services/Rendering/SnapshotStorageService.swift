import Foundation
import UIKit

/// Manages local storage of design snapshot images
struct SnapshotStorageService {

    static let shared = SnapshotStorageService()

    private var snapshotsDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(Constants.Storage.snapshotDirectoryName)
    }

    /// Ensures the snapshots directory exists
    func ensureDirectoryExists() throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: snapshotsDirectory.path) {
            try fm.createDirectory(at: snapshotsDirectory, withIntermediateDirectories: true)
        }
    }

    /// Saves a UIImage as JPEG and returns the file path
    func saveImage(_ image: UIImage, name: String) throws -> String {
        try ensureDirectoryExists()
        let filePath = snapshotsDirectory.appendingPathComponent(name)
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw RenderingError.imageEncodingFailed
        }
        try data.write(to: filePath)
        return filePath.path
    }

    /// Loads an image from a local file path
    func loadImage(at path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }

    /// Deletes all snapshots for a given style
    func deleteSnapshots(forStyleId styleId: String) throws {
        let fm = FileManager.default
        guard fm.fileExists(atPath: snapshotsDirectory.path) else { return }
        let contents = try fm.contentsOfDirectory(atPath: snapshotsDirectory.path)
        for file in contents where file.hasPrefix(styleId) {
            let filePath = snapshotsDirectory.appendingPathComponent(file)
            try fm.removeItem(at: filePath)
        }
    }
}
