//
//  PersistenceController.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import CoreData

struct PersistenceController {
    static var shard = PersistenceController()
    
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "EssayWriter")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData Store failed to initialise \(error)")
            }
        }
    }
}
