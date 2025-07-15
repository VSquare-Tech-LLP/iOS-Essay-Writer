//
//  LibraryGenerateEssayView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI

struct LibraryGenerateEssayView: View {
//    @EnvironmentObject var purchaseManager: PurchaseManager

    @FetchRequest(
        entity: GeenrateEssay.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \GeenrateEssay.createDate, ascending: true)]
    ) private var generatedEssay: FetchedResults<GeenrateEssay>
    
    var gridItem = [GridItem(.flexible())]

    @EnvironmentObject var generateManager: CoreDataManager<GeenrateEssay>
    @EnvironmentObject var favouriteManager: CoreDataManager<FavoriteEssay>

    @Binding var isShowPaywall: Bool
    @Binding var essayCopied: Bool

    @State private var selectedGeneratedEssay: GenerateEssayModel? = nil
    @State private var isShowDetails: Bool = false
    @State private var isFavourite: Bool = false
    @State private var isShowDeleteAlert: Bool = false
    @State private var generatedEssayId: String? = nil
    @State private var isShowFullScreen: Bool = false

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(15)) {
            
            // Header
            Text("Generated Essays")
                .font(.system(size: .scaledFontSize(14), weight: .semibold))
                .foregroundStyle(.appTextBackground)
                .pushOutWidth(.leading)
            
            // Empty State
            if generatedEssay.isEmpty {
                VStack(spacing: ScaleUtility.scaledSpacing(0)) {
                    Spacer()
                        .frame(height: ScaleUtility.scaledSpacing(80))
                    VStack(spacing: ScaleUtility.scaledSpacing(16)) {
                        Image(.essayEmptyGeneratedIcon)
                            .renderingMode(.template)
                            .resizeImage()
                            .square(size: ScaleUtility.scaledValue(73))
                            .foregroundStyle(.appTextBackground.opacity(0.3))
                        Text("No Essays Yet!")
                            .font(.system(size: .scaledFontSize(18), weight: .semibold))
                    }
                    .foregroundStyle(.appTextBackground.opacity(0.3))
                    Spacer()
                }
            }
            // List of Essays
            else {
                ScrollView(.vertical) {
                    LazyVGrid(columns: gridItem, spacing: ScaleUtility.scaledSpacing(15)) {
                        ForEach(generatedEssay, id: \.uuid) { essay in
                            let imageID = URL(string: essay.url ?? "")?.lastPathComponent ?? ""
                            
                            LibraryGeneratedEssayContainerView(
                                generateModel: essay,
                                viewAction: {
                                    isFavourite = favouriteManager.items.contains { $0.id == imageID }
                                    selectedGeneratedEssay = mapToGenerateEssayModel(essay)
                                    isShowDetails = true
                                },
                                copyAction: {
                                    essayCopied = true
                                    UIPasteboard.general.string = essay.essay ?? ""
                                },
                                deleteAction: {
                                    isShowDeleteAlert = true
                                    generatedEssayId = essay.id ?? ""
                                }
                            )
                            .onTapGesture {
                                isFavourite = favouriteManager.items.contains { $0.id == imageID }
                                selectedGeneratedEssay = mapToGenerateEssayModel(essay)
                                isShowDetails = true
                            }
                        }
                    }
                    Spacer()
                        .frame(height: ScaleUtility.scaledSpacing(100))
                }
                .scrollIndicators(.hidden)
            }
        }
        .alert(isPresented: $isShowDeleteAlert) {
            Alert(
                title: Text("Are you sure you want to delete?"),
                primaryButton: .destructive(Text("Delete")) {
//                    AnalyticsManager.shared.log(.deleteGeneratedEssay)
                    generateManager.deleteGeneratedEssay(by: generatedEssayId ?? "")
                },
                secondaryButton: .cancel()
            )
        }
        .navigationDestination(isPresented: $isShowDetails) {
            if let selectedGeneratedEssay {
                EssayDetailScreen(
                    essayDetail: selectedGeneratedEssay,
                    generatedEssayCoreDataManager: generateManager,
                    isFavourite: $isFavourite,
                    isRegenerateFromLibrary: true,
                    isShowDeleteButton: true,
                    favouriteAction: {
//                        AnalyticsManager.shared.log(.likeEssay)
                        let imageID = URL(string: selectedGeneratedEssay.url)?.lastPathComponent ?? ""
                        toggleFavorite(
                            id: imageID,
                            url: selectedGeneratedEssay.url,
                            title: selectedGeneratedEssay.title,
                            category: selectedGeneratedEssay.category,
                            essay: selectedGeneratedEssay.essay,
                            citation: selectedGeneratedEssay.citation
                        )
                    },
                    deleteAction: {
                        generateManager.deleteGeneratedEssay(by: selectedGeneratedEssay.id)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isShowDetails = false
                        }
                    },
                    reGenerateButtonAction: { _ in
                        isShowFullScreen = true
                    },
                    closeButtonAction: {},
                    backButtonAction: {
                        isShowDetails = false
                    }
                )
            }
        }
//        .fullScreenCover(isPresented: $isShowFullScreen) {
//            if let selectedGeneratedEssay {
//                LibraryRegenerateEssayView(
//                    isShowFullScreen: $isShowFullScreen,
//                    backButtonAction: {
//                        isShowFullScreen = false
//                    },
//                    essayModel: selectedGeneratedEssay,
//                    generatedEssayCoreDataManager: generateManager
//                )
//            }
//        }
    }

    // MARK: - Helper Methods

    private func toggleFavorite(id: String, url: String, title: String, category: String, essay: String, citation: String?) {
        if isFavourite {
            isFavourite = false
            favouriteManager.deleteFavorite(by: id)
        } else {
            isFavourite = true
            let newFavURL = EssayLocalStorageManager.shared.copyImageToFavorites(originalURL: url, id: id)
            favouriteManager.saveFavorite(
                id: id,
                url: newFavURL?.absoluteString ?? "",
                title: title,
                category: category,
                essay: essay,
                citation: citation
            )
        }
    }

    private func mapToGenerateEssayModel(_ essay: GeenrateEssay) -> GenerateEssayModel {
        return GenerateEssayModel(
            id: essay.id ?? "",
            url: essay.url ?? "",
            title: essay.title ?? "",
            category: essay.category ?? "",
            essay: essay.essay ?? "",
            prompt: essay.prompt ?? "",
            length: essay.length ?? "",
            academicLevel: essay.academicLevel ?? "",
            noOfParagraph: essay.noOfParagraph ?? "",
            writingStyle: essay.writingStyle ?? "",
            tone: essay.tone ?? "",
            citation: essay.citation ?? "",
            addReferences: essay.addReferences ?? "",
            isFromBasicMode: essay.isFromBasicMode
        )
    }
}

//#Preview {
//    LibraryGenerateEssayView()
//}

struct LibraryGeneratedEssayContainerView: View {
    var generateModel: GeenrateEssay
    let viewAction: () -> Void
    let copyAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(10)) {
            
            // Header with Title and Date
            HStack(spacing: ScaleUtility.scaledSpacing(4)) {
                Text(generateModel.title ?? "")
                    .font(.system(size: .scaledFontSize(14), weight: .semibold))
                    .foregroundStyle(.appTextBackground)
                    .pushOutWidth(.leading)
                
                Text(formattedDate(from: generateModel.createDate ?? Date.now))
                    .font(.system(size: .scaledFontSize(10), weight: .medium))
                    .foregroundStyle(.appTextBackground.opacity(0.7))
            }
            
            // Essay preview
            Text(generateModel.essay ?? "No essay")
                .font(.system(size: .scaledFontSize(13), weight: .regular))
                .foregroundStyle(.appTextBackground.opacity(0.8))
                .minimumScaleFactor(0.8)
                .frame(width: 222 * widthRatio, alignment: .leading)
                .frame(height: 25 * heightRatio, alignment: .top)
                .lineLimit(2)
                .truncationMode(.tail)

            // Action buttons
            HStack(spacing: ScaleUtility.scaledSpacing(4)) {
                
                Button(action: viewAction) {
                    Text("View")
                        .font(.system(size: .scaledFontSize(12)))
                        .foregroundStyle(.appTextBackground)
                }
                .pushOutWidth(.leading)
                
                Spacer()
                
                HStack(spacing: ScaleUtility.scaledSpacing(8)) {
                    
                    Button(action: copyAction) {
                        VStack(spacing: ScaleUtility.scaledSpacing(3)) {
                            Image(.essayCopyIcon)
                                .renderingMode(.template)
                                .resizeImage()
                                .square(size: ScaleUtility.scaledValue(12))
                            
                            Text("Copy")
                                .font(.system(size: .scaledFontSize(6.4)))
                                .foregroundStyle(.appTextBackground)
                        }
                        .frame(height: ScaleUtility.scaledValue(20))
                    }
                    
                    Button(action: deleteAction) {
                        VStack(spacing: ScaleUtility.scaledSpacing(3)) {
                            Image(.essayDeleteIcon)
                                .renderingMode(.template)
                                .resizeImage()
                                .square(size: ScaleUtility.scaledValue(12))
                            
                            Text("Delete")
                                .font(.system(size: .scaledFontSize(6.4)))
                                .foregroundStyle(.appTextBackground)
                        }
                        .frame(height: ScaleUtility.scaledValue(20))
                    }
                }
            }
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(15))
        .padding(.top, ScaleUtility.scaledSpacing(15))
        .padding(.bottom, ScaleUtility.scaledSpacing(8))
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appEssayBackground)
        }
        .frame(height: 105 * heightRatio)
    }

    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}
