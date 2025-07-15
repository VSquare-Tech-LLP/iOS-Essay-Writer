//
//  CreationEssayBaiscModeView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI

struct CreationEssayBaiscModeView: View {
    @EnvironmentObject var essayCreationViewModel: EssayCreationViewModel
    @EnvironmentObject var generateEssayDataManager: CoreDataManager<GeenrateEssay>
    
    @State var showLength: Bool = false
    @State var showAcademySheet: Bool = false
    @State var showRewardBox: Bool = false
    
    @State var essayTitle: String = ""
    @State var prompt: String = ""
    @State var essayLength: String = ""
    @State var essayAcademicLevel: String = ""
    
    @State var showToast: Bool = false
    @State var toastMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: ScaleUtility.scaledSpacing(24)) {
                VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                    CreationEssayTitleView(title: $essayTitle)
                    
                    CreationEssayShortDescriptionTextView(text: $prompt)
                    
                    CreationEssayLengthView(title: "Length", selectedText: essayLength, action: {
                        dismissKeyboard()
                        self.showLength = true
                    })
                    
                    CreationEssayLengthView(title: "Academic Level", selectedText: essayAcademicLevel, action: {
                        dismissKeyboard()
                        self.showAcademySheet = true
                    })
                }
                .padding(.horizontal, ScaleUtility.scaledSpacing(25))
                Text(toastMessage)
                    .font(.system(size: .scaledFontSize(12)))
                    .foregroundStyle(.appViewBackground)
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.appTextBackground.opacity(0.8))
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .opacity(showToast ? 1 : 0)
                
                Button {
                    guard self.validateGenerateEssay(title: essayTitle, prompt: prompt) else {
                        return
                    }
                    self.essayCreationViewModel.generatedEssayTitle = essayTitle
                    Task {
                        _ = try await essayCreationViewModel.basicModeGenerateEssay(
                            essayTitle: essayTitle,
                            prompt: prompt,
                            length: essayLength,
                            academicLevel: essayAcademicLevel,
                            generatedEssaySaveAction: { generateEssay in
                                generateEssayDataManager.saveGeneratedEssay(
                                    id: generateEssay.id,
                                    url: generateEssay.url,
                                    title: generateEssay.title,
                                    category: generateEssay.category,
                                    essay: generateEssay.essay,
                                    prompt: generateEssay.prompt,
                                    length: generateEssay.length,
                                    academicLevel: generateEssay.academicLevel,
                                    noOfParagraph: generateEssay.noOfParagraph,
                                    writingStyle: generateEssay.writingStyle,
                                    tone: generateEssay.tone,
                                    citation: nil,
                                    addReferences: generateEssay.addReferences,
                                    isFromBasicMode: generateEssay.isFromBasicMode)
                            })
                    }
                } label: {
                    if essayCreationViewModel.isLoading {
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
            EssayLengthContainerView(selectedLength: $essayLength, isShowLengthSheet: $showLength)
                .presentationDetents([.height(ScaleUtility.scaledValue(188))])
        }
        .sheet(isPresented: $showAcademySheet, content: {
            EssayAcademicContainerView(selectedAcademicLevel: $essayAcademicLevel, isShowAcademicSheet: $showAcademySheet)
                .presentationDetents([.height(ScaleUtility.scaledValue(281))])
        })
        .alert("Generate New Essay", isPresented: $showRewardBox, actions: {
            Button {
                
            } label: {
                Text("Buy Pro")
            }

        })
    }
    
    func validateGenerateEssay(title: String, prompt: String) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedTitle.isEmpty && trimmedPrompt.isEmpty {
            self.toastMessage = "Title & Prompt are required!"
            self.showToast = true
            return false
        } else if trimmedTitle.isEmpty {
            self.toastMessage = "Title is required!"
            self.showToast = true
            return false
        } else if trimmedPrompt.isEmpty {
            self.toastMessage = "Prompt is required!"
            self.showToast = true
            return false
        } else {
            return true
        }
    }
}

#Preview {
    CreationEssayBaiscModeView()
}

struct CreationEssayTitleView: View {
    @Binding var title: String

    var body: some View {
        ZStack {
            if title.isEmpty {
                Text("Enter Your Title")
                    .font(.system(size: .scaledFontSize(14)))
                    .foregroundStyle(.appTextBackground.opacity(0.7))
                    .pushOutWidth(.leading)
                    .padding(.horizontal, ScaleUtility.scaledSpacing(15))
            }

            TextField("", text: $title)
                .font(.system(size: .scaledFontSize(14)))
                .padding(.vertical, ScaleUtility.scaledSpacing(17))
                .padding(.horizontal, ScaleUtility.scaledSpacing(15))
        }
        .frame(height: ScaleUtility.scaledValue(51))
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appEssayBackground)
        }
    }
}

struct CreationEssayShortDescriptionTextView: View {
    @Binding var text: String
    var totalChar: Int = 200
    @FocusState private var focus: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(10)) {
            
            ZStack {
                if text.isEmpty {
                    Text("Write a Short Description for Your Essay")
                        .font(.system(size: .scaledFontSize(14)))
                        .foregroundStyle(.appTextBackground.opacity(0.7))
                        .pushOutWidth(.leading)
                        .frame(
                            height: ScaleUtility.scaledValue(79),
                            alignment: .top
                        )
                        .padding(.top, ScaleUtility.scaledSpacing(18))
                        .padding(.leading, ScaleUtility.scaledSpacing(2))
                }

                TextEditor(text: $text)
                    .font(.system(size: .scaledFontSize(14)))
                    .scrollContentBackground(.hidden)
                    .frame(height: ScaleUtility.scaledValue(100))
                    .focused($focus)
                    .padding(.top, ScaleUtility.scaledSpacing(28))
                    .onChange(of: text) { _, newValue in
                        let filteredText = newValue.filterData(limit: 200)
                        if filteredText != text {
                            text = filteredText
                        }
                        if newValue.contains("\n") {
                            text = newValue.replacingOccurrences(of: "\n", with: "")
                            focus = false
                        }
                    }
                    .offset(x: -2, y: -4)
            }
            .frame(height: ScaleUtility.scaledValue(100))
            
            Text(remainingCharText)
                .font(.system(size: .scaledFontSize(10)))
                .foregroundStyle(.appTextBackground)
                .pushOutWidth(.leading)
                .frame(height: ScaleUtility.scaledValue(19))
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(15))
        .frame(height: ScaleUtility.scaledValue(133))
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.appEssayBackground)
        }
    }

    func validCharCount() -> Int {
        text.filter { $0.isLetter || $0.isNumber }.count
    }

    var remainingCharText: String {
        let remainingChar = max(totalChar - validCharCount(), 0)
        return "\(remainingChar)/200 "
    }
}

struct CreationEssayLengthView: View {
    let title: String
    let selectedText: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.system(size: .scaledFontSize(14)))
                .foregroundStyle(.appTextBackground.opacity(0.7))
                .pushOutWidth(.leading)

            Spacer()

            Button(action: {
                action()
            }) {
                HStack(spacing: ScaleUtility.scaledSpacing(6)) {
                    Text(selectedText)
                        .font(.system(size: .scaledFontSize(14)))
                        .foregroundStyle(.appTextBackground)

                    Image(.backButtonIcon)
                        .renderingMode(.template)
                        .resizeImage()
                        .frame(
                            width: ScaleUtility.scaledValue(6),
                            height: ScaleUtility.scaledValue(18)
                        )
                        .foregroundStyle(.appTextBackground)
                        .rotationEffect(.degrees(-180))
                }
            }
        }
        .padding(.leading, ScaleUtility.scaledSpacing(15))
        .padding(.trailing, ScaleUtility.scaledSpacing(24))
        .padding(.vertical, ScaleUtility.scaledSpacing(17))
        .frame(height: ScaleUtility.scaledSpacing(51))
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appEssayBackground)
        }
    }
}

struct EssayLengthContainerView: View {
    @Binding var selectedLength: String
    @Binding var isShowLengthSheet: Bool

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(43)) {
            CapsuleSheetView()
            
            VStack(spacing: ScaleUtility.scaledSpacing(12)) {
                ForEach(EssayLengthOption.allCases, id: \.self) { essayLength in
                    let isLast = EssayLengthOption.allCases.last?.rawValue ?? "" == essayLength.rawValue
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(12)) {
                        Text(essayLength.rawValue)
                            .font(.system(size: .scaledFontSize(16)))
                            .foregroundStyle(.appTextBackground)
                            .frame(height: ScaleUtility.scaledValue(19))
                        
                        Color.appTextBackground.opacity(0.06)
                            .frame(height: 1)
                            .opacity(isLast ? 0 : 1)
                    }
                    .onTapGesture {
                        self.selectedLength = essayLength.rawValue
                        self.isShowLengthSheet = false
                    }
                }
            }
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(24))
        .padding(.top, ScaleUtility.scaledSpacing(22))
        .padding(.bottom, ScaleUtility.scaledSpacing(25))
    }
}

struct EssayAcademicContainerView: View {
    @Binding var selectedAcademicLevel: String
    @Binding var isShowAcademicSheet: Bool

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(36)) {
            CapsuleSheetView()
            
            VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                ForEach(EssayAcademicLevelOption.allCases, id: \.self) { academicLevel in
                    let isLast = EssayAcademicLevelOption.allCases.last?.rawValue ?? "" == academicLevel.rawValue
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                        Text(academicLevel.rawValue)
                            .font(.system(size: .scaledFontSize(16)))
                            .foregroundStyle(.appTextBackground)
                            .frame(height: ScaleUtility.scaledValue(19))
                        
                        Color.appTextBackground.opacity(0.06)
                            .frame(height: 1)
                            .opacity(isLast ? 0 : 1)
                    }
                    .onTapGesture {
                        self.selectedAcademicLevel = academicLevel.rawValue
                        self.isShowAcademicSheet = false
                    }
                }
            }
        }
        .padding(.top, ScaleUtility.scaledSpacing(10))
        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
    }
}


