//
//  EssayHomeViewModel.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import CoreData

final class EssayHomeViewModel: ObservableObject {
    @Published var defaultEssay: [Category]? = nil

    @Published var popularCategories: [Category] = []
    @Published var scienceCategory: Category? = nil
    @Published var otherCategories: [Category] = []

    @Published var isProcessing: Bool = false

    private let persistentContainer: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }

    @MainActor
    func fetchDefaultEssay() async {
        isProcessing = true
        defer { isProcessing = false }

        let lastFetchTime = UserDefaults.standard.object(forKey: "lastFetchTime") as? Date ?? .distantPast
        let currentTime = Date()

        // Check if cached data is still valid
        if currentTime.timeIntervalSince(lastFetchTime) < 86400 {
            print("Using cached Core Data, no fetch needed.")
            fetchFromCoreData()
            return
        }

        let apiURL = "https://api.quillpen.app/api/home"
        let result: Result<[DefaultEssayCategory], NetworkError> = await APIManager.shared.getPostData(fromURL: apiURL)

        switch result {
        case .success(let response):
            saveToCoreData(categoriesData: response)
            fetchFromCoreData()
            UserDefaults.standard.set(Date(), forKey: "lastFetchTime")
            print(defaultEssay as Any)
        case .failure(let error):
            print("Error fetching data: \(error)")
        }
    }

    private func saveToCoreData(categoriesData: [DefaultEssayCategory]) {
        let categoryManager = CoreDataManager<Category>(container: persistentContainer)
        let essayManager = CoreDataManager<DefaultEssay>(container: persistentContainer)

        categoryManager.deleteAll() // Clear old data

        for category in categoriesData {
            let categoryEntity = categoryManager.create(entity: Category.self) { newCategory in
                newCategory.id = UUID()
                newCategory.categoryName = category.categoryName
                newCategory.categoryImage = category.categoryImage
                newCategory.isPopular = category.isPopular
            }

            for essay in category.essays {
                _ = essayManager.create(entity: DefaultEssay.self) { newEssay in
                    newEssay.id = UUID()
                    newEssay.title = essay.title
                    newEssay.image = essay.img
                    newEssay.essay = essay.text
                    newEssay.isPopular = essay.isPopular
                    newEssay.category = categoryEntity
                }
            }
        }
    }

    private func fetchFromCoreData() {
        defer { self.isProcessing = false }

        let categoryManager = CoreDataManager<Category>(container: persistentContainer)
        let fetchedCategories = categoryManager.items

        self.isProcessing = true

        // Categorize fetched data
        let popular = fetchedCategories.filter { $0.isPopular }
        let science = fetchedCategories.first { $0.categoryName == "Science & Technology" }
        let others = fetchedCategories
            .filter { $0.categoryName != "Science & Technology" }
            .sorted { ($0.categoryName ?? "") < ($1.categoryName ?? "") }

        self.popularCategories = popular
        self.scienceCategory = science
        self.otherCategories = others
    }
}

// MARK: - DefaultCategory Helper
extension Category {
    var essayArray: [DefaultEssay] {
        let set = essay as? Set<DefaultEssay> ?? []
        return set.sorted { ($0.title ?? "") < ($1.title ?? "") }
    }
}
