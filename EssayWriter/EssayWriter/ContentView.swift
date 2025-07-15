//
//  ContentView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import SwiftUI

struct ContentView: View {
    
//    @EnvironmentObject var favouriteEssayManager: CoreDataManager<FavoriteEssay>
//    @EnvironmentObject var generateEssayManager: CoreDataManager<GeenrateEssay>
    
//    @ObservedObject var essayHomeViewModel: EssayHomeViewModel
    var body: some View {
        NavigationStack {
            ZStack {
                EssayHomeView()
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
