//
//  RegenerateEssayGuideModeView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 16/07/25.
//

import SwiftUI

import SwiftUI

struct RegenerateGuideModeView: View {
    @ObservedObject var generateEssayModel: GenerateEssayModel

    @State private var isShowLengthSheet = false
    @State private var isShowParagraphsSheet = false
    @State private var isShowAcademicLevelSheet = false
    @State private var isShowWritingSheet = false
    @State private var isShowToneSheet = false
    @State private var isShowCitationSheet = false

    @Binding var addReference: Bool
    @Binding var isProcessing: Bool

    let regenerateEssayAction: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: ScaleUtility.scaledSpacing(28)) {
                
                VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                    
                    CreationEssayTitleView(title: $generateEssayModel.title)
                    
                    CreationEssayShortDescriptionTextView(text: $generateEssayModel.prompt)
                    
                    CreationEssayLengthView(
                        title: "Length",
                        selectedText: generateEssayModel.length
                    ) {
                        isShowLengthSheet = true
                    }
                    
                    CreationEssayLengthView(
                        title: "No. of Paragraphs",
                        selectedText: generateEssayModel.noOfParagraph
                    ) {
                        isShowParagraphsSheet = true
                    }
                    
                    CreationEssayLengthView(
                        title: "Academic Level",
                        selectedText: generateEssayModel.academicLevel
                    ) {
                        isShowAcademicLevelSheet = true
                    }
                    
                    CreationEssayLengthView(
                        title: "Writing Style",
                        selectedText: generateEssayModel.writingStyle
                    ) {
                        isShowWritingSheet = true
                    }
                    
                    CreationEssayLengthView(
                        title: "Tone",
                        selectedText: generateEssayModel.tone
                    ) {
                        isShowToneSheet = true
                    }
                    
                    CreationEssayLengthView(
                        title: "Citation",
                        selectedText: generateEssayModel.citation
                    ) {
                        isShowCitationSheet = true
                    }
                    
                    HStack(spacing: 0) {
                        Text("Add References")
                            .font(.system(size: .scaledFontSize(14)))
                            .foregroundStyle(.appTextBackground.opacity(0.7))
                            .pushOutWidth(.leading)

                        Spacer()

                        Toggle("", isOn: $addReference)
                            .toggleStyle(.appToggleStyle)
                            .labelsHidden()
                    }
                    .padding(.horizontal, ScaleUtility.scaledSpacing(28))
                    .padding(.leading, ScaleUtility.scaledSpacing(15))
                    .padding(.vertical, ScaleUtility.scaledSpacing(17))
                    .frame(height: ScaleUtility.scaledSpacing(51))
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.appEssayBackground)
                    }
                }
                .padding(.horizontal, ScaleUtility.scaledSpacing(25))
                
                Button {
                    regenerateEssayAction()
                } label: {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Text("Generate")
                    }
                }
                .buttonStyle(.customButtonStyle)
                .padding(.horizontal, ScaleUtility.scaledSpacing(80))
            }
            
            Spacer().frame(height: 40)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        
        .sheet(isPresented: $isShowLengthSheet) {
            EssayLengthContainerView(
                selectedLength: $generateEssayModel.length,
                isShowLengthSheet: $isShowLengthSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(188))])
        }
        
        .sheet(isPresented: $isShowParagraphsSheet) {
            CreationEssayParagraphSheetView(
                selectedParagraph: $generateEssayModel.noOfParagraph,
                isShowParagraphSheet: $isShowParagraphsSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(188))])
        }
        
        .sheet(isPresented: $isShowAcademicLevelSheet) {
            EssayAcademicContainerView(
                selectedAcademicLevel: $generateEssayModel.academicLevel,
                isShowAcademicSheet: $isShowAcademicLevelSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(281))])
        }
        
        .sheet(isPresented: $isShowWritingSheet) {
            CreationEssayWritingStyleSheetView(
                selectedWritingStyle: $generateEssayModel.writingStyle,
                isShowWritingStyleSheet: $isShowWritingSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(327))])
        }
        
        .sheet(isPresented: $isShowToneSheet) {
            CreationEssayToneSheetView(
                selectedTone: $generateEssayModel.tone,
                isShowToneSheet: $isShowToneSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(414))])
        }
        
        .sheet(isPresented: $isShowCitationSheet) {
            CreationEssayCitationView(
                selectedCitation: $generateEssayModel.citation,
                isShowCitationSheet: $isShowCitationSheet,
                onCloseCitation: { citation in
                    // Future handler if needed
                }
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(512))])
        }
    }
}


//#Preview {
//    RegenerateEssayGuideModeView()
//}

