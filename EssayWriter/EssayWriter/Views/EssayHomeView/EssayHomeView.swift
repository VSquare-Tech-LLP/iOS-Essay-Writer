//
//  EssayHomeView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import SwiftUI
import Kingfisher

struct EssayHomeView: View {
    @State var showCategoryDetailView: Bool = false
    @State var showSettingView: Bool = false
    @State var paywallView: Bool = false
    
    @EnvironmentObject var favouriteEssayManager: CoreDataManager<FavoriteEssay>
    @EnvironmentObject var generateEssayManager: CoreDataManager<GeenrateEssay>
    
    @EnvironmentObject var essayHomeViewModel: EssayHomeViewModel
    
    @State var selectedEssay: GenerateEssayModel? = nil
    @State var showEssayDetailView: Bool = false
    
    @State var isFavourite: Bool = false
    @State var selectedEssayId: String? = nil
    @State var selectedCategory: Category? = nil
    
    var gridItem = [
        GridItem(.flexible(), spacing: ScaleUtility.scaledSpacing(15))
    ]
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(10)) {
            AppHeaderView(leadingBarItem: {
                Text("Essay Writer")
                    .font(.system(size: .scaledFontSize(18), weight: .semibold))
                    .foregroundStyle(.appTextBackground.opacity(0.6))
            }, middleBarItem: {
                Spacer()
            }, trailingBarItem: {
                HStack(spacing: ScaleUtility.scaledSpacing(16)) {
                        AppPaywallButtonView(action: {
                            
                        })
//                        .opacity(purchaseManager.hasPro ? 0 : 1)
                    AppSettingsButtonView(action: {
                        self.showSettingView =  true
                    })
                }
            })
            .padding(.horizontal, ScaleUtility.scaledSpacing(25))
            
            VStack(spacing: 0) {
                if essayHomeViewModel.isProcessing {
                    VStack(spacing: 0) {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    ScrollView {
                        Spacer()
                            .frame(height: ScaleUtility.scaledSpacing(13))
                        
                        VStack(spacing: ScaleUtility.scaledSpacing(25)) {
                            TrendingTopicsView(
                                category: essayHomeViewModel.popularCategories,
                                onTapAction: { category in
                                    self.selectedCategory = category
                                    self.showCategoryDetailView = true
                                })
                            
                            if let scienceCategory = essayHomeViewModel.scienceCategory {
                                ScienceAndTechnologyView(
                                    category: scienceCategory,
                                    viewAllAction: {
                                        self.selectedCategory = scienceCategory
                                        self.showCategoryDetailView = true
                                    }, onTapEssayAction: { essayDetail in
                                        self.selectedEssayId = URL(string: essayDetail.image ?? "")?.lastPathComponent ?? ""
                                        self.isFavourite = favouriteEssayManager.items.contains { $0.id == selectedEssayId ?? "" }
                                        self.selectedEssay = selectedEssayDetails(essayDetail: essayDetail)
                                        self.showEssayDetailView = true
                                    })
                            }
                            
                          OtherCategoryView(
                            category: essayHomeViewModel.otherCategories,
                            viewAllAction: { selectedCategory in
                                self.selectedCategory = selectedCategory
                                self.showCategoryDetailView = true
                            }, onTapEssay: { defaultEssay in
                                self.selectedEssayId = URL(string: defaultEssay.image ?? "")?.lastPathComponent ?? ""
                                self.isFavourite = favouriteEssayManager.items.contains { $0.id == selectedEssayId ?? "" }
                                self.selectedEssay = selectedEssayDetails(essayDetail: defaultEssay)
                                self.showEssayDetailView = true
                            })
                        }
                        Spacer()
                            .frame(height: ScaleUtility.scaledSpacing(100))
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationDestination(isPresented: $showCategoryDetailView,
                                   destination: {
                if let selectedCategory = selectedCategory {
                    EssayCategoryDetailView(
                        generateManager: generateEssayManager,
                        favouriteManager: favouriteEssayManager,
                        essayCategory: selectedCategory,
                        backButtonAction: {
                            self.showCategoryDetailView = false
                        })
                }
            })
            .navigationDestination(isPresented: $showEssayDetailView) {
                if let selectedEssay {
                    EssayDetailScreen(
                        essayDetail: selectedEssay,
                        generatedEssayCoreDataManager: generateEssayManager,
                        isFavourite: $isFavourite,
                        favouriteAction: {
                            
                        }, deleteAction: {},
                        reGenerateButtonAction: { _ in},
                        closeButtonAction: {
                            
                        }, backButtonAction: {
                            self.selectedEssay = nil
                            self.selectedEssayId = nil
                            self.selectedCategory = nil
                            self.showEssayDetailView  = false
                        }
                    )
                }
            }
        }
    }
    
    func selectedEssayDetails(essayDetail: DefaultEssay) -> GenerateEssayModel {
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
//    EssayHomeView()
//}

struct TrendingTopicsView: View {
    var category: [Category]
    
    var gridItem = [
        GridItem(.flexible(), spacing: ScaleUtility.scaledSpacing(15))
    ]
    
    let onTapAction: (_ category: Category) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(16)) {
            Text("Trending Topics")
                .font(.system(size: .scaledFontSize(18), weight: .semibold))
                .padding(.horizontal, ScaleUtility.scaledSpacing(25))
            
            ScrollView(.horizontal) {
                LazyHGrid(rows: gridItem, spacing: ScaleUtility.scaledSpacing(15)) {
                    ForEach(category, id: \.self) { categoryData in
                        TradingContainerView(
                            img: categoryData.categoryImage ?? "",
                            title: categoryData.categoryName ?? ""
                        )
                        .onTapGesture {
                            onTapAction(categoryData)
                        }
                    }
                }
                .padding(.horizontal, ScaleUtility.scaledSpacing(25))
                .frame(height: 100 * heightRatio)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, ScaleUtility.scaledSpacing(10))
    }
}

struct ScienceAndTechnologyView: View {
    var category: Category
    let viewAllAction: () -> Void
    let onTapEssayAction: (_ essayDetail: DefaultEssay) -> Void
    
    var gridItem = [
        GridItem(.flexible(), spacing: ScaleUtility.scaledSpacing(15))
    ]

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(10)) {
            CategoryHeaderView(title: "Science & Technology Highlights", viewAllAction: viewAllAction)
            
            ScrollView(.horizontal) {
                LazyHGrid(rows: gridItem, spacing: ScaleUtility.scaledSpacing(15)) {
                    ForEach(category.essayArray, id: \.id) { essayData in
                        ScienceAndTechnologyContainerView(
                            img: essayData.image ?? "",
                            title: essayData.title ?? "",
                            content: essayData.essay ?? "")
                        .onTapGesture {
                            onTapEssayAction(essayData)
                        }
                    }
                }
                .frame(height: 221 * heightRatio)
                .padding(.horizontal, ScaleUtility.scaledSpacing(25))
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct OtherCategoryView: View {
    var category: [Category]
    let viewAllAction: (_ category: Category) -> Void
    let onTapEssay: (_ essayDetail: DefaultEssay) -> Void
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(25)) {
            ForEach(category, id: \.self) { category in
                CommonCategoryView(
                    category: category,
                    viewAllAction: {
                        viewAllAction(category)
                    }, onTapEssayAction: { defaultEssay in
                        onTapEssay(defaultEssay)
                    })
            }
        }
    }
}

struct CommonCategoryView: View {
    var category: Category
    var gridItem = [
        GridItem(.flexible(), spacing: ScaleUtility.scaledSpacing(15))
    ]
    let viewAllAction: () -> Void
    let onTapEssayAction: (_ essayDetail: DefaultEssay) -> Void

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(10)) {
            CategoryHeaderView(
                title: category.categoryName ?? "",
                viewAllAction: viewAllAction
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridItem, spacing: ScaleUtility.scaledSpacing(15)) {
                    ForEach(category.essayArray, id: \.id) { essay in
                        CommonCategoryContainerView(
                            img: essay.image ?? "",
                            title: essay.title ?? ""
                        )
                        .onTapGesture {
                            onTapEssayAction(essay)
                        }
                    }
                }
                .padding(.horizontal, ScaleUtility.scaledSpacing(25))
                .frame(height: 180 * heightRatio)
            }
        }
        .padding(.vertical, ScaleUtility.scaledSpacing(5))
    }
}


struct TradingContainerView: View {
    let img: String
    let title: String
    var body: some View {
        ZStack {
            KFImage(URL(string: img))
                .placeholder {
                    Color.gray
                        .overlay {
                            ProgressView()
                        }
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 74 * widthRatio, height: 100 * heightRatio)
                .clipShape(RoundedRectangle(cornerRadius: 4.75 * heightRatio))
            Color.appBlackBackground
                .opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 4.75))
        }
        .frame(width: 74 * widthRatio, height: 100 * heightRatio)
        .overlay(alignment: .top) {
            Text(title)
                .font(.system(size: .scaledFontSize(8), weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, ScaleUtility.scaledSpacing(7))
                .padding(.horizontal, ScaleUtility.scaledSpacing(2))
        }
    }
}

struct ScienceAndTechnologyContainerView: View {
    let img: String
    let title: String
    let content: String

    var body: some View {
        ZStack {
            KFImage(URL(string: img))
                .placeholder {
                    Color.gray
                        .overlay {
                            ProgressView()
                        }
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 221 * widthRatio, height: 221 * heightRatio)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Color.black.opacity(0.45)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(16)) {
                Text(title)
                    .font(.system(size: .scaledFontSize(16), weight: .semibold))
                    .lineLimit(2)
                    .pushOutWidth(.leading)
                
                Text(content)
                    .font(.system(size: .scaledFontSize(13), weight: .regular))
                    .lineLimit(3)
                    .opacity(0.85)
                
                Spacer()
            }
            .foregroundStyle(.white)
            .padding([.horizontal, .bottom], ScaleUtility.scaledSpacing(20))
            .padding(.top, ScaleUtility.scaledSpacing(24))
        }
        .frame(width: 221 * widthRatio, height: 221 * heightRatio)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CommonCategoryContainerView: View {
    let img: String
    let title: String

    var body: some View {
        ZStack {
            KFImage(URL(string: img))
                .placeholder {
                    Color.gray
                        .overlay {
                            ProgressView()
                        }
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100 * widthRatio, height: 180 * heightRatio)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Color.appBlackBackground
                .opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack {
                Text(title)
                    .font(.system(size: .scaledFontSize(12), weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ScaleUtility.scaledSpacing(11))
                    .padding(.top, ScaleUtility.scaledSpacing(13))
                Spacer()
            }
        }
        .frame(width: 100 * widthRatio, height: 180 * heightRatio)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct CategoryHeaderView: View {
    let title: String
    let viewAllAction: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: .scaledFontSize(16), weight: .semibold))
                .foregroundStyle(.appTextBackground)
            
            Spacer()
            
            ViewAllButtonView(action: viewAllAction)
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
        .padding(.top, ScaleUtility.scaledSpacing(5))
    }
}

struct ViewAllButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ScaleUtility.scaledSpacing(4)) {
                Text("View All")
                    .font(.system(size: ScaleUtility.scaledValue(13), weight: .medium))
                    .foregroundStyle(.appTextBackground.opacity(0.7))
                
                Image(.backButtonIcon)
                    .renderingMode(.template)
                    .resizeImage()
                    .square(size: ScaleUtility.scaledValue(12))
                    .foregroundStyle(.appTextBackground.opacity(0.5))
                    .rotationEffect(.degrees(-90))
            }
            .contentShape(Rectangle()) // Better tap area
        }
        .buttonStyle(.plain) // Prevents default button styling
    }
}
