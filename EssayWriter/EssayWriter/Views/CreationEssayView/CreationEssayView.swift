//
//  CreationEssayView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI

struct CreationEssayView: View {
    @EnvironmentObject var essayGenerateViewModel: EssayCreationViewModel
    @EnvironmentObject var generatedEssayDataManager: CoreDataManager<GeenrateEssay>
    @EnvironmentObject var favouriteEssayDataManager: CoreDataManager<FavoriteEssay>
    @State var isShowSettingView: Bool
    @State var isShowPaywall: Bool = false
    @State var isFavouriteEssay: Bool = false
    let backButtonAcion: () -> Void
    @Namespace var animation
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(31))
        {
            CreationEssayHeaderView(
                purchaseHasPro: false,
                backButtonAction: backButtonAcion,
                paywallAction: {},
                settingAction: {
                    self.isShowSettingView = true
                })
            .disabled(essayGenerateViewModel.isLoading)
            .padding(.horizontal, ScaleUtility.scaledSpacing(25))
            
            VStack(spacing: ScaleUtility.scaledSpacing(40)) {
                CustomPicker(selectedTab: $essayGenerateViewModel.selectedTab, animation: animation)
                    .disabled(essayGenerateViewModel.isLoading)
                    .padding(.horizontal, ScaleUtility.scaledSpacing(25))
                
                TabView(selection: $essayGenerateViewModel.selectedTab) {
                    CreationEssayBaiscModeView()
                        .tag(EssayGeneratorMode.basic)
                    
                    CreationEssayGuidedModeView()
                        .tag(EssayGeneratorMode.guided)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .disabled(essayGenerateViewModel.isLoading)
            }
            .animation(.easeInOut, value: essayGenerateViewModel.selectedTab)
            .navigationDestination(isPresented: $essayGenerateViewModel.isEssayGenerated) {
                if let generateEssayModel = essayGenerateViewModel.generatedEssayModel {
                    EssayDetailScreen(
                        essayDetail: generateEssayModel,
                        generatedEssayCoreDataManager: generatedEssayDataManager,
                        isFavourite: $isFavouriteEssay, favouriteAction: {
                            let imageID = URL(string: generateEssayModel.url)?.lastPathComponent ?? ""
                            toggleFavorite(
                                id: imageID,
                                url: generateEssayModel.url,
                                title: generateEssayModel.title,
                                category: generateEssayModel.category,
                                essay: generateEssayModel.essay,
                                citation: generateEssayModel.citation)
                        }, deleteAction: {
                            
                        }, reGenerateButtonAction: { essayID in
                            if self.essayGenerateViewModel.selectedTab == .basic {
                                self.essayGenerateViewModel.regenerateEssayBasicModeId = essayID
                            } else {
                                self.essayGenerateViewModel.regenerateEssayGuideModeId = essayID
                            }
                            self.essayGenerateViewModel.isEssayGenerated = false
                        }, closeButtonAction: {
                            self.essayGenerateViewModel.regenerateEssayBasicModeId = nil
                            self.essayGenerateViewModel.regenerateEssayGuideModeId = nil
                            backButtonAcion()
                        }, backButtonAction: {
                            self.essayGenerateViewModel.regenerateEssayBasicModeId = nil
                            self.essayGenerateViewModel.regenerateEssayGuideModeId = nil
                            self.essayGenerateViewModel.isEssayGenerated = false
                            self.isFavouriteEssay = false
                        })
                }
            }
           

         }
        .onChange(of: essayGenerateViewModel.selectedTab) { _, _ in
            dismissKeyboard()
        }
        .padding(.top, ScaleUtility.scaledSpacing(13))
        .ignoresSafeArea(edges: .bottom)
        .background {
            Color.appViewBackground
                .ignoresSafeArea()
        }
        .alert(
            "An error occurred. Please adjust your prompt and try again.",
            isPresented: $essayGenerateViewModel.isEssayGeneratingError,
            actions: {}
        )
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    dismissKeyboard()
                } label: {
                    Text("Done")
                }
                .foregroundStyle(.appTextBackground)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    func toggleFavorite(
        id: String,
        url: String,
        title: String,
        category: String,
        essay: String,
        citation: String?
    ) {
        if isFavouriteEssay {
            isFavouriteEssay = false
            favouriteEssayDataManager.deleteFavorite(by: id)
        } else {
            isFavouriteEssay = true
            let newFavURL = EssayLocalStorageManager.shared.copyImageToFavorites(originalURL: url, id: id)
            favouriteEssayDataManager.saveFavorite(
                id: id,
                url: newFavURL?.absoluteString ?? "",
                title: title,
                category: category,
                essay: essay,
                citation: citation
            )
        }
    }
}

//#Preview {
//    CreationEssayView()
//}

