//
//  EssayCategoryDetailView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import SwiftUI
import Kingfisher

struct EssayCategoryDetailView: View {
    @State var selectedEssay: GenerateEssayModel? = nil
    @State var shoEssayDetail: Bool = false
    @State var selectedId: String? = nil
    @State var isFavourite: Bool = false
    @State var showSettingView: Bool = false
    
    @ObservedObject var generateManager: CoreDataManager<GeenrateEssay>
    @ObservedObject var favouriteManager: CoreDataManager<FavoriteEssay>
    
    var essayCategory: Category
    
    var gridItem = [GridItem(.flexible(), spacing: ScaleUtility.scaledSpacing(0))]
    let backButtonAction: () -> Void
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(19)) {
            EssayCategoryHeaderDetailView(
                categoryName: essayCategory.categoryName ?? "",
                backButtonAction: {
                    backButtonAction()
                }, paywallAction: {
                    
                }, settingAction: {
                    self.showSettingView = true
                })
            
            ScrollView {
                Spacer()
                    .frame(height: ScaleUtility.scaledSpacing(19))
                
                LazyVGrid(columns: gridItem, spacing: ScaleUtility.scaledSpacing(9)) {
                    ForEach(essayCategory.essayArray, id: \.id) { data in
                        CategoryInfoDetailContainerView(
                            url: data.image ?? "",
                            title: data.title ?? "",
                            category: essayCategory.categoryName ?? "")
                        .onTapGesture {
                            self.selectedId = URL(string: data.image ?? "")?.lastPathComponent ?? ""
                            self.isFavourite = favouriteManager.items.contains { $0.id == selectedId ?? "" }
                            self.selectedEssay = selectedGeneratedEssay(essayDetail: data)
                            self.shoEssayDetail = true
                        }
                        
                    }
                }
            }
            .scrollIndicators(.hidden)
            .navigationDestination(isPresented: $shoEssayDetail) {
                if let selectedEssay {
                    EssayDetailScreen(
                        essayDetail: selectedEssay,
                        generatedEssayCoreDataManager: generateManager,
                        isFavourite: $isFavourite,
                        favouriteAction: {
                            let imageID = URL(string: selectedEssay.url)?.lastPathComponent ?? ""
                            toggleFavorite(id: imageID,
                                           url: selectedEssay.url,
                                           title: selectedEssay.title,
                                           category: selectedEssay.category,
                                           essay: selectedEssay.essay)
                        }, deleteAction: {}, reGenerateButtonAction: { essayID in},
                        closeButtonAction: {
                            
                        }, backButtonAction: {
                            self.selectedEssay = nil
                            self.shoEssayDetail = false
                        })
                }
            }
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
        .padding(.top, ScaleUtility.scaledSpacing(14))
        .background {
            Color.appViewBackground
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden()
    }
    
    func toggleFavorite(id: String, url: String, title: String, category: String, essay: String) {
        if isFavourite {
            self.isFavourite = false
            favouriteManager.deleteFavorite(by: id)
        } else {
            self.isFavourite = true
            
            guard let imageURL = URL(string: url) else {
                print("Invalid image URL")
                return
            }
            
            let imageName = "\(id)"
            
            let folderName = "FavouriteEssay"

            Task {
                if let localURL = await EssayLocalStorageManager.shared.saveImageFromURL(imageURL, withName: imageName, in: folderName) {
                    DispatchQueue.main.async {
                        favouriteManager.saveFavorite(
                            id: id,
                            url: localURL.absoluteString,
                            title: title,
                            category: category,
                            essay: essay,
                        citation: nil)
                    }
                }
            }
//            favouriteManager.saveFavourite(id: id, url: url, title: title, category: Category, essay: essay, citation: nil)
        }
    }

    func selectedGeneratedEssay(essayDetail: DefaultEssay) -> GenerateEssayModel {
        let id = essayDetail.id?.uuidString ?? ""
        let url = essayDetail.image ?? ""
        let title = essayDetail.title ?? ""
        let category = essayDetail.category?.categoryName ?? ""
        let essay = essayDetail.essay ?? ""
        
        return GenerateEssayModel(
            id: id,
            url: url,
            title: title,
            category: category,
            essay: essay,
            prompt: "",
            length: "",
            academicLevel: "",
            noOfParagraph: "",
            writingStyle: "",
            tone: "",
            citation: "",
            addReferences: "",
            isFromBasicMode: false
        )
    }

}

//#Preview {
//    EssayCategoryDetailView()
//}

struct EssayCategoryHeaderDetailView: View {
//    @EnvironmentObject var purchaseManager: PurchaseManager
    let categoryName: String
    let backButtonAction: () -> Void
    let paywallAction: () -> Void
    let settingAction: () -> Void
    
    var body: some View {
        AppHeaderView(
            leadingBarItem: {
                AppBackButtonView(action: backButtonAction)
            },
            middleBarItem: {
                Text(categoryName)
                    .font(.system(size: .scaledFontSize(18), weight: .semibold))
                    .foregroundStyle(.appTextBackground.opacity(0.6))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .pushOutWidth(.leading)
            },
            trailingBarItem: {
                HStack(spacing: ScaleUtility.scaledSpacing(16)) {
                    AppPaywallButtonView(action: paywallAction)
//                        .opacity(purchaseManager.hasPro ? 0 : 1)
                    AppSettingsButtonView(action: settingAction)
                }
            }
        )
    }
}

struct CategoryInfoDetailContainerView: View {
    let url: String
    let title: String
    let category: String
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(10)) {
            HStack(spacing: ScaleUtility.scaledSpacing(8)) {
                KFImage(URL(string: url))
                    .placeholder {
                        Color.gray
                            .overlay {
                                ProgressView()
                            }
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .square(size: ScaleUtility.scaledValue(40))
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                VStack(alignment: .leading, spacing: isIPad ? 4 : 0) {
                    Text(title)
                        .font(.system(size: .scaledFontSize(14), design: .rounded))
                        .foregroundStyle(.appTextBackground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(height: ScaleUtility.scaledValue(17))
                    Text(category)
                        .font(.system(size: .scaledFontSize(12), design: .rounded))
                        .foregroundStyle(.appTextBackground.opacity(0.5))
                        .frame(height: ScaleUtility.scaledValue(14))
                }
            }
            .pushOutWidth(.leading)
            .padding(.vertical, ScaleUtility.scaledSpacing(5))
            
            Color.appTextBackground
                .opacity(0.15)
                .frame(height: 1)
        }
    }
}
