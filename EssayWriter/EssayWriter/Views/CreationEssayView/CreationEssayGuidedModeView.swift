//
//  CreationEssayGuidedModeView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI

struct CreationEssayGuidedModeView: View {
    @EnvironmentObject var essayCreationViewModel: EssayCreationViewModel
    @EnvironmentObject var generatedEssayDataManager: CoreDataManager<GeenrateEssay>
//    @Binding var isShowPaywall: Bool

    @State private var isShowLengthSheet = false
    @State private var isShowParagraphsSheet = false
    @State private var isShowAcademicLevelSheet = false
    @State private var isShowWritingSheet = false
    @State private var isShowToneSheet = false
    @State private var isShowCitationSheet = false
    @State private var addReference = false

    @State private var guideModeText = ""
    @State private var guideModeDescription = ""
    @State private var guideModeLength = "Short"
    @State private var guideModeAcademicLevel = "High School"
    @State private var numberOfParagraph = "Non Specific"
    @State private var writingStyle = "Argumentative"
    @State private var tone = "Friendly"
    @State private var citation = "Non Specific"

    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                    CreationEssayTitleView(title: $guideModeText)

                    CreationEssayShortDescriptionTextView(text: $guideModeDescription)

                    CreationEssayLengthView(
                        title: "Length",
                        selectedText: guideModeLength
                    ) {
                        dismissKeyboard()
                        isShowLengthSheet = true
                    }

                    CreationEssayLengthView(
                        title: "No. of Paragraphs",
                        selectedText: numberOfParagraph
                    ) {
                        dismissKeyboard()
                        isShowParagraphsSheet = true
                    }

                    CreationEssayLengthView(
                        title: "Academic Level",
                        selectedText: guideModeAcademicLevel
                    ) {
                        dismissKeyboard()
                        isShowAcademicLevelSheet = true
                    }

                    CreationEssayLengthView(
                        title: "Writing Style",
                        selectedText: writingStyle
                    ) {
                        dismissKeyboard()
                        isShowWritingSheet = true
                    }

                    CreationEssayLengthView(
                        title: "Tone",
                        selectedText: tone
                    ) {
                        dismissKeyboard()
                        isShowToneSheet = true
                    }

                    CreationEssayLengthView(
                        title: "Citation",
                        selectedText: citation
                    ) {
                        dismissKeyboard()
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
                    .padding(.leading, ScaleUtility.scaledSpacing(15))
                    .padding(.trailing, ScaleUtility.scaledSpacing(28))
                    .padding(.vertical, ScaleUtility.scaledSpacing(17))
                    .frame(height: ScaleUtility.scaledSpacing(51))
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.appEssayBackground)
                    }
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
                    guard validateGenerateEssay(title: guideModeText, prompt: guideModeDescription) else {
                        return
                    }

                    essayCreationViewModel.generatedEssayTitle = guideModeText
                    essayCreationViewModel.citation = citation

//                    AnalyticsManager.shared.log(.generateEssayFromGuideMode)

//                    if purchaseManager.hasPro {
                        Task {
                            try await essayCreationViewModel.guideModeGenerateEssay(
                                title: guideModeText,
                                prompt: guideModeDescription,
                                length: guideModeLength,
                                academicLevel: guideModeAcademicLevel,
                                noOfParagraph: numberOfParagraph,
                                tone: tone,
                                writingStyle: writingStyle,
                                citation: citation,
                                addRef: addReference ? "true" : "false",
                                generatedEssaySaveAction: { generatedEssay in
                                    generatedEssayDataManager.saveGeneratedEssay(
                                        id: generatedEssay.id,
                                        url: generatedEssay.url,
                                        title: generatedEssay.title,
                                        category: generatedEssay.category,
                                        essay: generatedEssay.essay,
                                        prompt: generatedEssay.prompt,
                                        length: generatedEssay.length,
                                        academicLevel: generatedEssay.academicLevel,
                                        noOfParagraph: generatedEssay.noOfParagraph,
                                        writingStyle: generatedEssay.writingStyle,
                                        tone: generatedEssay.tone,
                                        citation: generatedEssay.citation,
                                        addReferences: generatedEssay.addReferences,
                                        isFromBasicMode: generatedEssay.isFromBasicMode
                                    )
                                }
                            )
                        }
//                    } else {
//                        isShowPaywall = true
//                    }
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

            Spacer().frame(height: 40)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .onChange(of: showToast) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showToast = false
                }
            }
        }
        .sheet(isPresented: $isShowLengthSheet) {
            EssayLengthContainerView(
                selectedLength: $guideModeLength,
                isShowLengthSheet: $isShowLengthSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(188))])
        }
        .sheet(isPresented: $isShowParagraphsSheet) {
            CreationEssayParagraphSheetView(
                selectedParagraph: $numberOfParagraph,
                isShowParagraphSheet: $isShowParagraphsSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(228))])
        }
        .sheet(isPresented: $isShowAcademicLevelSheet) {
            EssayAcademicContainerView(
                selectedAcademicLevel: $guideModeAcademicLevel,
                isShowAcademicSheet: $isShowAcademicLevelSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(281))])
        }
        .sheet(isPresented: $isShowWritingSheet) {
            CreationEssayWritingStyleSheetView(
                selectedWritingStyle: $writingStyle,
                isShowWritingStyleSheet: $isShowWritingSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(327))])
        }
        .sheet(isPresented: $isShowToneSheet) {
            CreationEssayToneSheetView(
                selectedTone: $tone,
                isShowToneSheet: $isShowToneSheet
            )
            .presentationDetents([.height(ScaleUtility.scaledValue(414))])
        }
        .sheet(isPresented: $isShowCitationSheet) {
            CreationEssayCitationView(
                selectedCitation: $citation,
                isShowCitationSheet: $isShowCitationSheet
            ) { citation in
                essayCreationViewModel.citation = citation
            }
            .presentationDetents([.height(ScaleUtility.scaledValue(512))])
        }
    }

    func validateGenerateEssay(title: String, prompt: String) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty && trimmedPrompt.isEmpty {
            toastMessage = "Title & Prompt are required!"
            showToast = true
            return false
        } else if trimmedTitle.isEmpty {
            toastMessage = "Title is required!"
            showToast = true
            return false
        } else if trimmedPrompt.isEmpty {
            toastMessage = "Prompt is required!"
            showToast = true
            return false
        } else {
            return true
        }
    }
}

//#Preview {
//    CreationEssayGuidedModeView()
//}

struct CreationEssayParagraphSheetView: View {
    @Binding var selectedParagraph: String
    @Binding var isShowParagraphSheet: Bool

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(43)) {
            CapsuleSheetView()

            VStack(spacing: ScaleUtility.scaledSpacing(12)) {
                ForEach(EssayParagraphCount.allCases, id: \.self) { paragraphNumber in
                    let isLast = EssayParagraphCount.allCases.last == paragraphNumber

                    VStack(spacing: ScaleUtility.scaledSpacing(12)) {
                        Text(paragraphNumber.rawValue)
                            .font(.system(size: .scaledFontSize(16)))
                            .foregroundStyle(.appTextBackground)
                            .frame(height: ScaleUtility.scaledValue(19))

                        Color.appTextBackground.opacity(0.06)
                            .frame(height: 1)
                            .opacity(isLast ? 0 : 1)
                    }
                    .onTapGesture {
                        self.selectedParagraph = paragraphNumber.rawValue
                        self.isShowParagraphSheet = false
                    }
                }
            }
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
    }
}

struct CreationEssayWritingStyleSheetView: View {
    @Binding var selectedWritingStyle: String
    @Binding var isShowWritingStyleSheet: Bool

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(27)) {
            CapsuleSheetView()

            VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                ForEach(EssayWritingStyleOption.allCases, id: \.self) { style in
                    let isLast = EssayWritingStyleOption.allCases.last == style

                    VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                        Text(style.rawValue)
                            .font(.system(size: .scaledFontSize(16)))
                            .foregroundStyle(.appTextBackground)
                            .frame(height: ScaleUtility.scaledValue(19))

                        Color.appTextBackground.opacity(0.06)
                            .frame(height: 1)
                            .opacity(isLast ? 0 : 1)
                    }
                    .frame(height: ScaleUtility.scaledValue(33))
                    .onTapGesture {
                        self.selectedWritingStyle = style.rawValue
                        self.isShowWritingStyleSheet = false
                    }
                }
            }
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
    }
}

struct CreationEssayToneSheetView: View {
    @Binding var selectedTone: String
    @Binding var isShowToneSheet: Bool

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(27)) {
            CapsuleSheetView()

            VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                ForEach(EssayToneOption.allCases, id: \.self) { style in
                    let isLast = EssayToneOption.allCases.last == style

                    VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                        Text(style.rawValue)
                            .font(.system(size: .scaledFontSize(16)))
                            .foregroundStyle(.appTextBackground)
                            .frame(height: ScaleUtility.scaledValue(19))

                        if !isLast {
                            Color.appTextBackground.opacity(0.06)
                                .frame(height: 1)
                        }
                    }
                    .frame(height: ScaleUtility.scaledValue(33))
                    .onTapGesture {
                        self.selectedTone = style.rawValue
                        self.isShowToneSheet = false
                    }
                }
            }
        }
        .padding(.top, ScaleUtility.scaledSpacing(6))
        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
    }
}

struct CreationEssayCitationView: View {
    @Binding var selectedCitation: String
    @Binding var isShowCitationSheet: Bool
    let onCloseCitation: (_ citation: String) -> Void

    var body: some View {
        VStack(
            spacing: isBigIpadDevice
                ? ScaleUtility.scaledSpacing(25)
                : ScaleUtility.scaledSpacing(29)
        ) {
            CapsuleSheetView()

            VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                ForEach(EssayCitationStyle.allCases, id: \.self) { citation in
                    let isLast = EssayCitationStyle.allCases.last == citation

                    VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                        Text(citation.rawValue)
                            .font(.system(size: .scaledFontSize(16)))
                            .foregroundStyle(.appTextBackground)
                            .frame(height: ScaleUtility.scaledValue(19))

                        Color.appTextBackground.opacity(0.06)
                            .frame(height: 1)
                            .opacity(isLast ? 0 : 1)
                    }
                    .frame(
                        height: isBigIpadDevice
                            ? ScaleUtility.scaledValue(30)
                            : ScaleUtility.scaledValue(33)
                    )
                    .onTapGesture {
                        self.selectedCitation = citation.rawValue
                        self.isShowCitationSheet = false
                        onCloseCitation(citation.rawValue)
                    }
                }
            }
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
    }
}
