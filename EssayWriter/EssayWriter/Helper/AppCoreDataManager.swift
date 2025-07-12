//
//  AppCoreDataManager.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import CoreData

final class CoreDataManager<T: NSManagedObject>: ObservableObject where T: ObservableObject {
    @Published var items: [T] = []

    private let persistentContainer: NSPersistentContainer
    private let managedObjectContext: NSManagedObjectContext

    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.managedObjectContext = container.viewContext
        fetchAll()
    }

    func create(entity: T.Type, configuration: (T) -> Void) -> T {
        let newEntity = T(context: managedObjectContext)
        configuration(newEntity)
        save()
        return newEntity
    }

    /// Fetch all data with optional predicate and sorting.
    func fetchAll(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        do {
            if let results = try managedObjectContext.fetch(request) as? [T] {
                self.items = results
            }
        } catch {
            print("Failed to fetch entities: \(error)")
        }
    }

    func update(entity: T, configuration: (T) -> Void) {
        configuration(entity)
        save()
    }

    func delete(entity: T) {
        managedObjectContext.delete(entity)
        save()
        fetchAll()
    }

    func save() {
        guard managedObjectContext.hasChanges else { return }
        do {
            try managedObjectContext.save()
            print("Data saved successfully")
        } catch {
            fatalError("Failed to save context: \(error)")
        }
    }

    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        do {
            let result = try managedObjectContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }

            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [managedObjectContext])

            DispatchQueue.main.async {
                self.items.removeAll()
            }

            print("All records deleted for \(T.self)")
        } catch {
            print("Failed to delete all data: \(error)")
        }
    }
}

// MARK: - GeneratedEssay-Specific Operations
extension CoreDataManager where T: GeenrateEssay {
    func fetchGeneratedEssay(by id: String) -> GeenrateEssay? {
        let predicate = NSPredicate(format: "id == %@", id)
        fetchAll(predicate: predicate)
        return items.first
    }

    func fetchAllGeneratedEssays() {
        fetchAll()
    }

    func saveGeneratedEssay(
        id: String,
        url: String,
        title: String,
        category: String,
        essay: String,
        prompt: String,
        length: String,
        academicLevel: String,
        noOfParagraph: String?,
        writingStyle: String?,
        tone: String?,
        citation: String?,
        addReferences: String,
        isFromBasicMode: Bool
    ) {
        if let existingEssay = fetchGeneratedEssay(by: id) {
            update(entity: existingEssay as! T) { updated in
                updated.url = url
                updated.title = title
                updated.category = category
                updated.essay = essay
                updated.prompt = prompt
                updated.length = length
                updated.academicLevel = academicLevel
                updated.noOfParagraph = noOfParagraph
                updated.writingStyle = writingStyle
                updated.tone = tone
                updated.citation = citation
                updated.addReferences = addReferences
                updated.isFromBasicMode = isFromBasicMode
                updated.createDate = Date()
            }
            print("Updated existing essay: \(id)")
        } else {
            let _ = create(entity: GeenrateEssay.self as! T.Type) { newEssay in
                newEssay.uuid = UUID()
                newEssay.id = id
                newEssay.url = url
                newEssay.title = title
                newEssay.category = category
                newEssay.essay = essay
                newEssay.prompt = prompt
                newEssay.length = length
                newEssay.academicLevel = academicLevel
                newEssay.noOfParagraph = noOfParagraph
                newEssay.writingStyle = writingStyle
                newEssay.tone = tone
                newEssay.citation = citation
                newEssay.addReferences = addReferences
                newEssay.isFromBasicMode = isFromBasicMode
                newEssay.createDate = Date()
            }
            print("Saved new essay: \(id)")
        }

        fetchAll()
    }

    func deleteGeneratedEssay(by id: String) {
        if let essay = fetchGeneratedEssay(by: id) {
            delete(entity: essay as! T)
            EssayLocalStorageManager.shared.deleteImage(fromLocalStorage: "\(id).jpg", in: "GeneratedEssay")
        }
        fetchAll()
    }

    func updateEssayContent(id: String, newEssay: String) {
        if let existingEssay = fetchGeneratedEssay(by: id) {
            update(entity: existingEssay as! T) { updated in
                updated.essay = newEssay
                updated.createDate = Date()
            }
            fetchAll()
        }
    }
}

// MARK: - FavoriteEssay-Specific Operations
extension CoreDataManager where T: FavoriteEssay {
    func fetchFavorite(by id: String) -> FavoriteEssay? {
        let predicate = NSPredicate(format: "id == %@", id)
        fetchAll(predicate: predicate)
        return items.first
    }

    func fetchAllFavorites() {
        fetchAll()
    }

    func deleteFavorite(by id: String) {
        if let favorite = fetchFavorite(by: id) {
            delete(entity: favorite as! T)
            EssayLocalStorageManager.shared.deleteImage(fromLocalStorage: id, in: "FavouriteEssay")
        }
        fetchAll()
    }

    func saveFavorite(
        id: String,
        url: String,
        title: String,
        category: String,
        essay: String,
        citation: String?
    ) {
        let _ = create(entity: FavoriteEssay.self as! T.Type) { newFavorite in
            newFavorite.uuid = UUID()
            newFavorite.id = id
            newFavorite.url = url
            newFavorite.title = title
            newFavorite.category = category
            newFavorite.essay = essay
            newFavorite.citation = citation
            newFavorite.createDate = Date()
        }
        fetchAll()
    }
}
