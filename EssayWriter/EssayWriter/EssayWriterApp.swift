//
//  EssayWriterApp.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import SwiftUI

@main
struct EssayWriterApp: App {
    @StateObject var essayHomeViewModel = EssayHomeViewModel(container: PersistenceController.shard.container)
    @StateObject var generateEssayManager = CoreDataManager<GeenrateEssay>(container: PersistenceController.shard.container)
    @StateObject var favouriteEssayManager = CoreDataManager<FavoriteEssay>(container: PersistenceController.shard.container)
    
    let persistenceController = PersistenceController.shard

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(generateEssayManager)
                .environmentObject(favouriteEssayManager)
                .environmentObject(essayHomeViewModel)
                .onAppear {
                    Task {
                        await essayHomeViewModel.fetchDefaultEssay()
                    }
                }
        }
    }
}
