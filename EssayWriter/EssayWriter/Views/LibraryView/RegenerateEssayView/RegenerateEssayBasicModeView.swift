//
//  RegenerateEssayBasicModeView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 16/07/25.
//

import SwiftUI

struct RegenerateEssayBasicModeView: View {
    @State var showLength: Bool = false
    @State var showAcademySheet: Bool = false
    
    @Binding var isProcessing: Bool
    
    @ObservedObject var generateEssayModel: GenerateEssayModel
    
    let regenerateEssayAction: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: ScaleUtility.scaledSpacing(48)) {
                VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                    CreationEssayTitleView(title: $generateEssayModel.title)
                    
                    CreationEssayShortDescriptionTextView(text: $generateEssayModel.prompt)
                    
                    CreationEssayLengthView(title: "Length", selectedText: generateEssayModel.length, action: {
                        self.showLength = true
                    })
                    
                    CreationEssayLengthView(title: "Academic Level", selectedText: generateEssayModel.academicLevel, action: {
                        self.showAcademySheet = true
                    })
                }
                .padding(.horizontal, ScaleUtility.scaledValue(25))
                
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
            Spacer()
                .frame(height: 40)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .sheet(isPresented: $showLength) {
            EssayLengthContainerView(selectedLength: $generateEssayModel.length, isShowLengthSheet: $showLength)
                .presentationDetents([.height(ScaleUtility.scaledSpacing(188))])
        }
        .sheet(isPresented: $showAcademySheet) {
            EssayAcademicContainerView(selectedAcademicLevel: $generateEssayModel.academicLevel, isShowAcademicSheet: $showAcademySheet)
                .presentationDetents([.height(ScaleUtility.scaledValue(281))])
        }
    }
}

//#Preview {
//    RegenerateEssayBasicModeView()
//}
