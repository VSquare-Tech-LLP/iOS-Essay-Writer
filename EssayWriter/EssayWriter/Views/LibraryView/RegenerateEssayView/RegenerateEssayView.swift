//
//  RegenerateEssayView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 16/07/25.
//

import SwiftUI

struct RegenerateEssayView: View {
    @StateObject var regenerateEssayModel = RegenerateEssayViewModel()
    @State var isShowRewardBox: Bool = false
    @State var addRef: Bool = false
    
    @Binding var isShowFullScreen: Bool
    let backButtonAction: () -> Void
    
    @ObservedObject var essayModel: GenerateEssayModel
    @EnvironmentObject var generateManager: CoreDataManager<GeenrateEssay>
    
    @State var showFirst: Bool = true
    
    @Namespace var animation
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(31)) {
            AppBackButtonView(action: backButtonAction)
                .pushOutWidth(.leading)
                .disabled(regenerateEssayModel.isLoading)
                .padding(.horizontal, ScaleUtility.scaledSpacing(25))
            
            if essayModel.isFromBasicMode {
                RegenerateEssayBasicModeView(isProcessing: $regenerateEssayModel.isLoading, generateEssayModel: essayModel, regenerateEssayAction: {
                    Task {
                        _ = try await regenerateEssayModel.basicModeGenerateEssay(
                            essayTitle: essayModel.title,
                            prompt: essayModel.prompt,
                            length: essayModel.length,
                            academicLevel: essayModel.academicLevel
                        ) { model in
                            generateManager.saveGeneratedEssay(
                                id: model.data.uuid,
                                url: regenerateEssayModel.regenerateBasicModeLocalURL,
                                title: model.data.title,
                                category: model.data.category,
                                essay: model.data.essay,
                                prompt: essayModel.prompt,
                                length: essayModel.length,
                                academicLevel: essayModel.academicLevel,
                                noOfParagraph: essayModel.noOfParagraph,
                                writingStyle: essayModel.writingStyle,
                                tone: essayModel.tone,
                                citation: essayModel.citation,
                                addReferences: essayModel.addReferences,
                                isFromBasicMode: true
                            )
                            
                            essayModel.title = model.data.title
                            essayModel.url = regenerateEssayModel.regenerateBasicModeLocalURL
                            essayModel.essay = model.data.essay
                            essayModel.category = model.data.category
                            essayModel.addReferences = addRef ? "true" : "false"
                        }
                        
                        self.isShowFullScreen = false
                        
                    }
                })
            } else {
                RegenerateGuideModeView(generateEssayModel: essayModel, addReference: $addRef, isProcessing: $regenerateEssayModel.isLoading, regenerateEssayAction: {
                    Task {
                        _ = try await regenerateEssayModel.guideModeGenerateEssay(
                            title: essayModel.title,
                            prompt: essayModel.prompt,
                            length: essayModel.length,
                            academicLevel: essayModel.academicLevel,
                            noOfParagraph: essayModel.noOfParagraph,
                            tone: essayModel.tone,
                            writingStyle: essayModel.writingStyle,
                            citation: essayModel.citation,
                            addRef: addRef ? "true" : "false",
                            generatedEssaySaveAction: { model in
                                generateManager.saveGeneratedEssay(
                                    id: model.data.uuid,
                                    url: regenerateEssayModel.regenerateGuidedModeLocalURL,
                                    title: model.data.title,
                                    category: model.data.category,
                                    essay: model.data.essay,
                                    prompt: essayModel.prompt,
                                    length: essayModel.length,
                                    academicLevel: essayModel.academicLevel,
                                    noOfParagraph: essayModel.noOfParagraph,
                                    writingStyle: essayModel.writingStyle,
                                    tone: essayModel.tone,
                                    citation: essayModel.citation,
                                    addReferences: addRef ? "true" : "false",
                                    isFromBasicMode: false
                                )
                                
                                essayModel.title = model.data.title
                                essayModel.url = regenerateEssayModel.regenerateGuidedModeLocalURL
                                essayModel.essay = model.data.essay
                                essayModel.category = model.data.category
                                essayModel.addReferences = addRef ? "true" : "false"
                            }
                        )
                    }
                    self.isShowFullScreen = false
                })
            }
        }
        .padding(.top, ScaleUtility.scaledSpacing(10))
        .alert("An error occurred. Please adjust your prompt and try again.",
               isPresented: $regenerateEssayModel.isEssayGeneratingError, actions: {})
        .background {
            Color.appViewBackground
                .ignoresSafeArea()
        }
        .onAppear {
            if showFirst {
                if essayModel.addReferences == "true" {
                    self.addRef = true
                }
                
                self.showFirst = false
            }
        }
    }
}

//#Preview {
//    RegenerateEssayView()
//}
