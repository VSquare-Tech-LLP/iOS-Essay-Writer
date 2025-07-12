//
//  LocalStorageManager.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import CoreData
import SwiftUI

/// Manages local storage of essay images (backup, save, delete).
class EssayLocalStorageManager {
    static let shared = EssayLocalStorageManager()

    init() {}

    // MARK: - Public Backup Methods

    /// Backs up images from Core Data for both generated and favorite essays.
    func backupAllImages(context: NSManagedObjectContext, completion: @escaping () -> Void) {
        backupGeneratedEssayImages(context: context, completion: completion)
        backupFavoriteEssayImages(context: context, completion: completion)
    }

    /// Backs up generated essay images.
    func backupGeneratedEssayImages(context: NSManagedObjectContext, completion: @escaping () -> Void) {
        let fetchRequest: NSFetchRequest<GeenrateEssay> = GeenrateEssay.fetchRequest()

        do {
            let essays = try context.fetch(fetchRequest)
            let group = DispatchGroup()

            for essay in essays {
                if let urlString = essay.url, let url = URL(string: urlString) {
                    group.enter()
                    downloadAndStoreImage(
                        from: url,
                        for: essay,
                        in: "GeneratedEssay",
                        imageName: url.lastPathComponent,
                        context: context
                    ) {
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                completion()
            }
        } catch {
            print("Failed to fetch generated essays: \(error.localizedDescription)")
        }
    }

    /// Backs up favorite essay images.
    func backupFavoriteEssayImages(context: NSManagedObjectContext, completion: @escaping () -> Void) {
        let fetchRequest: NSFetchRequest<FavoriteEssay> = FavoriteEssay.fetchRequest()

        do {
            let essays = try context.fetch(fetchRequest)
            let group = DispatchGroup()

            for essay in essays {
                if let urlString = essay.url, let url = URL(string: urlString) {
                    group.enter()
                    downloadAndStoreImage(
                        from: url,
                        for: essay,
                        in: "FavouriteEssay",
                        imageName: url.lastPathComponent,
                        context: context
                    ) {
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                completion()
            }
        } catch {
            print("Failed to fetch favorite essays: \(error.localizedDescription)")
        }
    }

    // MARK: - Download & Save Helpers

    func downloadAndStoreImage(
        from url: URL,
        for essay: NSManagedObject,
        in folderName: String,
        imageName: String,
        context: NSManagedObjectContext,
        completion: @escaping () -> Void
    ) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let localURL = self.saveImageData(data, fileName: imageName, in: folderName) {
                    DispatchQueue.main.async {
                        if let generatedEssay = essay as? GeenrateEssay {
                            generatedEssay.url = localURL.absoluteString
                        } else if let favoriteEssay = essay as? FavoriteEssay {
                            favoriteEssay.url = localURL.absoluteString
                        }
                        try? context.save()
                        completion()
                    }
                }
            } else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }

    func saveImageFromURL(_ url: URL, withName fileName: String, in folderName: String) async -> URL? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return saveImageData(data, fileName: fileName, in: folderName)
        } catch {
            print("Error downloading image: \(error.localizedDescription)")
            return nil
        }
    }

    func saveImageData(_ data: Data, fileName: String, in folderName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let folderURL = documentsDirectory.appendingPathComponent(folderName)

        if !fileManager.fileExists(atPath: folderURL.path(percentEncoded: true)) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            } catch {
                print("Failed to create folder \(folderName): \(error.localizedDescription)")
                return nil
            }
        }

        let fileURL = folderURL.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Delete Helpers

    func deleteImage(fromLocalStorage imageID: String, in folderName: String) {
        guard let folderURL = getOrCreateDirectory(for: folderName) else { return }

        let fileURL = folderURL.appendingPathComponent(imageID)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Image deleted from \(folderName): \(fileURL.path)")
            } catch {
                print("Failed to delete image: \(error)")
            }
        }
    }

    func deleteGeneratedEssayBackups() {
        deleteAllFiles(in: "GeneratedEssay")
    }

    func deleteFavoriteEssayBackups() {
        deleteAllFiles(in: "FavouriteEssay")
    }

    private func deleteAllFiles(in folderName: String) {
        guard let folderURL = getOrCreateDirectory(for: folderName) else { return }

        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
            print("\(folderName) backup deleted successfully.")
        } catch {
            print("Error deleting \(folderName) backup: \(error.localizedDescription)")
        }
    }

    // MARK: - Directory Helpers

    func getOrCreateDirectory(for folderName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let folderURL = documentsDirectory.appendingPathComponent(folderName)

        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            } catch {
                print("Error creating \(folderName) folder: \(error.localizedDescription)")
                return nil
            }
        }

        return folderURL
    }

    func getFolderURL(for folderName: String) -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent(folderName)

        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            } catch {
                print("Error creating folder \(folderName): \(error.localizedDescription)")
            }
        }

        return folderURL
    }

    // MARK: - Copy Helpers

    func copyImageToFavorites(originalURL: String?, id: String) -> URL? {
        guard let originalURL = originalURL,
              let sourceURL = URL(string: originalURL),
              FileManager.default.fileExists(atPath: sourceURL.path) else {
            return nil
        }

        let destinationURL = getFavoriteImagePath(for: id)

        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        } catch {
            print("Failed to copy favorite image: \(error)")
            return nil
        }
    }

    func getFavoriteImagePath(for id: String) -> URL {
        let favFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("FavouriteEssay", isDirectory: true)

        if !FileManager.default.fileExists(atPath: favFolder.path) {
            try? FileManager.default.createDirectory(at: favFolder, withIntermediateDirectories: true)
        }

        return favFolder.appendingPathComponent(id)
    }
}
