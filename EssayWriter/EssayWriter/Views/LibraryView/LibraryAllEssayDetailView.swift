//
//  LibraryAllEssayDetailView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI
import Kingfisher

struct LibraryAllEssayView: View {
    @FetchRequest(
        entity: FavoriteEssay.entity(),
        sortDescriptors: []
    ) var favouriteEssay: FetchedResults<FavoriteEssay>
    
    @ObservedObject var favouriteManager: CoreDataManager<FavoriteEssay>
    @ObservedObject var generateManager: CoreDataManager<GeenrateEssay>
    
    @State private var selectedGeneratedEssay: GenerateEssayModel? = nil
    @State private var isShowDetails: Bool = false
    @State private var isFavourite: Bool = false
    @State private var isShowSettingView: Bool = false
    @State private var isShowPaywallView: Bool = false
    
    let backButtonAction: () -> Void
    private let gridItem = [GridItem(.flexible())]

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(10)) {
            
            LibraryAllEssayViewHeaderView(
                backButtonAction: { backButtonAction() },
                paywallAction: { isShowPaywallView = true },
                settingAction: { isShowSettingView = true }
            )
            
            if favouriteEssay.isEmpty {
                VStack {
                    Spacer()
                    VStack(spacing: ScaleUtility.scaledSpacing(16)) {
                        Image(.essayEmptyFavoriteIcon)
                            .renderingMode(.template)
                            .resizeImage()
                            .square(size: ScaleUtility.scaledSpacing(50))
                        Text("No Saves Yet!")
                            .font(.system(size: .scaledFontSize(18), weight: .semibold))
                            .foregroundStyle(.appTextBackground.opacity(0.3))
                    }
                    Spacer()
                }
            } else {
                ScrollView(.vertical) {
                    Spacer().frame(height: ScaleUtility.scaledSpacing(30))
                    
                    LazyVGrid(columns: gridItem, spacing: ScaleUtility.scaledSpacing(10)) {
                        ForEach(favouriteEssay, id: \.uuid) { favEssay in
                            LibraryAllEssayContainerView(
                                favouriteEssay: favEssay,
                                favouriteAction: {
                                    if let id = favEssay.id {
                                        favouriteManager.deleteFavorite(by: id)
                                    }
                                }
                            )
                            .pushOutWidth()
                            .onTapGesture {
                                isFavourite = favouriteManager.items.contains { $0.id == favEssay.id }
                                selectedGeneratedEssay = GenerateEssayModel(
                                    id: favEssay.id ?? "",
                                    url: favEssay.url ?? "",
                                    title: favEssay.title ?? "",
                                    category: favEssay.category ?? "",
                                    essay: favEssay.essay ?? "",
                                    citation: favEssay.citation ?? ""
                                )
                                isShowDetails = true
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
        .padding(.top, ScaleUtility.scaledSpacing(10))
        .background(Color.appViewBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        
        // Detail Essay Navigation
        .navigationDestination(isPresented: $isShowDetails) {
            if let selectedEssay = selectedGeneratedEssay {
                EssayDetailScreen(
                    essayDetail: selectedEssay,
                    generatedEssayCoreDataManager: generateManager,
                    isFavourite: $isFavourite,
                    favouriteAction: {
                        isFavourite.toggle()
                    },
                    deleteAction: {},
                    reGenerateButtonAction: { _ in },
                    closeButtonAction: {},
                    backButtonAction: {
                        if !isFavourite {
                            favouriteManager.deleteFavorite(by: selectedEssay.id)
                        }
                        isShowDetails = false
                    }
                )
            }
        }
        
        // Setting View Navigation
//        .navigationDestination(isPresented: $isShowSettingView) {
//            SettingView(
//                favouriteManager: favouriteManager,
//                generateManager: generateManager,
//                backButtonAction: {
//                    isShowSettingView = false
//                }
//            )
//        }
        
        // Paywall Full Screen
//        .fullScreenCover(isPresented: $isShowPaywallView) {
//            PayWall(
//                isInternalOpen: true,
//                closePayAll: {
//                    isShowPaywallView = false
//                },
//                purchaseCompletSuccessfullyAction: {
//                    isShowPaywallView = false
//                }
//            )
//        }
    }
    
    // Unused (but preserved) toggle logic
    func toggleFavorite(id: String, url: String, title: String, category: String, essay: String, citation: String?) {
        if isFavourite {
            isFavourite = false
            favouriteManager.deleteFavorite(by: id)
        } else {
            isFavourite = true
            favouriteManager.saveFavorite(
                id: id,
                url: url,
                title: title,
                category: category,
                essay: essay,
                citation: citation
            )
        }
    }
}


//#Preview {
//    LibraryAllEssayDetailView()
//}

struct LibraryAllEssayViewHeaderView: View {
//    @EnvironmentObject var purchaseManager: PurchaseManager
    let backButtonAction: () -> Void
    let paywallAction: () -> Void
    let settingAction: () -> Void
    
    var body: some View {
        AppHeaderView(
            leadingBarItem: {
                AppBackButtonView(opacity: 0.6, action: backButtonAction)
            },
            middleBarItem: {
                Text("Your Library")
                    .font(.system(size: .scaledFontSize(18), weight: .semibold))
                    .foregroundStyle(.appTextBackground.opacity(0.6))
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

struct LibraryAllEssayContainerView: View {
    let favouriteEssay: FavoriteEssay
    let favouriteAction: () -> Void
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(10)) {
            HStack(spacing: ScaleUtility.scaledSpacing(7.5)) {
                KFImage(URL(string: favouriteEssay.url ?? ""))
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
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(favouriteEssay.title ?? "")
                        .font(.system(size: .scaledFontSize(14)))
                        .foregroundStyle(.appTextBackground)
                        .minimumScaleFactor(0.8)
                        .frame(height: ScaleUtility.scaledValue(17))
                    
                    Text(favouriteEssay.category ?? "")
                        .font(.system(size: .scaledFontSize(12)))
                        .foregroundStyle(.appTextBackground)
                        .frame(height: ScaleUtility.scaledValue(14))
                }
                .pushOutWidth(.leading)
                
                Button(action: favouriteAction) {
                    Image(.essaySaveFillIcon)
                        .renderingMode(.template)
                        .resizeImage()
                        .frame(width: ScaleUtility.scaledValue(12), height: ScaleUtility.scaledValue(14))
                        .foregroundStyle(.appTextBackground)
                }
                .padding(.trailing, ScaleUtility.scaledSpacing(17))
            }
            .padding(.vertical, ScaleUtility.scaledSpacing(5))
            
            Color.appTextBackground
                .opacity(0.15)
                .frame(height: 1)
        }
    }
}
