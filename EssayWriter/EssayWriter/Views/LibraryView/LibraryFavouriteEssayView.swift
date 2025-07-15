//
//  LibraryFavouriteEssayView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI
import Kingfisher

struct LibraryFavoriteEssayView: View {
    @FetchRequest(
        entity: FavoriteEssay.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteEssay.createDate, ascending: true)]
    ) var favouriteEssay: FetchedResults<FavoriteEssay>
    
    @EnvironmentObject var favouriteManager: CoreDataManager<FavoriteEssay>
    @EnvironmentObject var generateManager: CoreDataManager<GeenrateEssay>
    
    @State private var selectedGeneratedEssay: GenerateEssayModel? = nil
    @State private var isShowDetails: Bool = false
    @State private var isShowAllFavouriteEssay: Bool = false
    @State private var isFavourite: Bool = false

    private let gridItem = [GridItem(.flexible())]

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(20)) {
            HStack(spacing: 0) {
                Text("Your Library")
                    .font(.system(size: .scaledFontSize(14), weight: .semibold))
                    .foregroundStyle(.appTextBackground)
                
                Spacer()
                
                ViewAllButtonView(action: {
                    isShowAllFavouriteEssay = true
                })
                .opacity(favouriteEssay.isEmpty ? 0 : 1)
            }
            .padding(.horizontal, ScaleUtility.scaledSpacing(25))
            
            if favouriteEssay.isEmpty {
                VStack(spacing: 0) {
                    Spacer().frame(height: ScaleUtility.scaledSpacing(7))
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(16)) {
                        Image(.essayEmptyFavoriteIcon)
                            .renderingMode(.template)
                            .resizeImage()
                            .square(size: ScaleUtility.scaledSpacing(50))
                        
                        Text("No Saves Yet!")
                            .font(.system(size: .scaledFontSize(18), weight: .semibold))
                    }
                    .foregroundStyle(.appTextBackground.opacity(0.3))
                    
                    Spacer().frame(height: ScaleUtility.scaledSpacing(28))
                }
            } else {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: gridItem, spacing: ScaleUtility.scaledSpacing(10)) {
                        ForEach(favouriteEssay, id: \.uuid) { essay in
                            EssayBigImageContainerView(
                                img: essay.url ?? "",
                                size: 118,
                                title: essay.title ?? "",
                                content: essay.essay ?? "",
                                fontSize: 8
                            )
                            .onTapGesture {
                                isFavourite = favouriteManager.items.contains { $0.id == essay.id }
                                selectedGeneratedEssay = GenerateEssayModel(
                                    id: essay.id ?? "",
                                    url: essay.url ?? "",
                                    title: essay.title ?? "",
                                    category: essay.category ?? "",
                                    essay: essay.essay ?? "",
                                    citation: essay.citation ?? ""
                                )
                                isShowDetails = true
                            }
                        }
                    }
                    .padding(.horizontal, ScaleUtility.scaledSpacing(25))
                }
                .frame(height: 120 * heightRatio)
                .scrollIndicators(.hidden)
            }
        }
        .frame(height: 161 * heightRatio)
        .navigationDestination(isPresented: $isShowDetails) {
            if let selectedGeneratedEssay {
                EssayDetailScreen(
                    essayDetail: selectedGeneratedEssay,
                    generatedEssayCoreDataManager: generateManager,
                    isFavourite: $isFavourite,
                    favouriteAction: {
                        self.isFavourite.toggle()
                    },
                    deleteAction: {},
                    reGenerateButtonAction: { _ in },
                    closeButtonAction: {},
                    backButtonAction: {
                        if !isFavourite {
                            favouriteManager.deleteFavorite(by: selectedGeneratedEssay.id)
                        }
                        isShowDetails = false
                    }
                )
            }
        }
        .navigationDestination(isPresented: $isShowAllFavouriteEssay) {
            LibraryAllEssayView(
                favouriteManager: favouriteManager,
                generateManager: generateManager,
                backButtonAction: {
                    isShowAllFavouriteEssay = false
                }
            )
        }
    }

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
//    LibraryFavouriteEssayView()
//}

struct EssayBigImageContainerView: View {
    let img: String
    let size: CGFloat
    let title: String
    let content: String
    let fontSize: CGFloat

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
                .frame(width: size * widthRatio, height: size * heightRatio)
                .clipShape(RoundedRectangle(cornerRadius: 5.5))

            Color.appBlackBackground
                .opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(spacing: ScaleUtility.scaledSpacing(10)) {
                Text(title)
                    .font(.system(size: .scaledFontSize(fontSize), weight: .medium))
                    .frame(height: ScaleUtility.scaledSpacing(20))
                    .pushOutWidth(.leading)

                Text(content)
                    .font(.system(size: .scaledFontSize(fontSize), weight: .bold))
                    .frame(maxHeight: .infinity)
                    .lineLimit(4)

                Spacer()
            }
            .foregroundStyle(.white)
            .pushOutWidth(.leading)
            .padding([.horizontal, .bottom], ScaleUtility.scaledSpacing(11))
            .padding(.top, ScaleUtility.scaledSpacing(11))
        }
        .frame(width: size * widthRatio, height: size * heightRatio)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
