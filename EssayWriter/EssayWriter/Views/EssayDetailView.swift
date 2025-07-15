//
//  EssayDetailView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI
import Kingfisher

struct EssayDetailScreen: View {
    @Environment(\.displayScale) var displayScale
    @State var isShowDeleteAlert: Bool = false
    @ObservedObject var essayDetail: GenerateEssayModel
    @ObservedObject var generatedEssayCoreDataManager: CoreDataManager<GeenrateEssay>
    @FocusState private var isTextFieldFocused: Bool
    @State var newEssay: String = ""
    @Binding var isFavourite: Bool
    var isFromGenerateView: Bool = false
    var isRegenerateFromLibrary: Bool = false
    var isShowDeleteButton: Bool = false
    let favouriteAction: () -> Void
    let deleteAction: () -> Void
    let reGenerateButtonAction: (_ essayID: String) -> Void
    let closeButtonAction: () -> Void
    let backButtonAction: () -> Void

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(14)) {
            HStack(spacing: 0) {
                AppBackButtonView(action: {
                    if isFromGenerateView {
                        generatedEssayCoreDataManager.updateEssayContent(id: essayDetail.id, newEssay: essayDetail.essay)
                    }
                    backButtonAction()
                })
                .pushOutWidth(.leading)

                if isFromGenerateView {
                    Button {
                        if isFromGenerateView {
                            generatedEssayCoreDataManager.updateEssayContent(id: essayDetail.id, newEssay: essayDetail.essay)
                        }
                        closeButtonAction()
                    } label: {
                        Image(.closeIcon)
                            .renderingMode(.template)
                            .resizable()
                            .square(size: ScaleUtility.scaledValue(14))
                            .foregroundStyle(.appTextBackground)
                    }
                    .padding(.trailing, ScaleUtility.scaledSpacing(13))
                }
            }
            .padding(.horizontal, ScaleUtility.scaledSpacing(25))

            VStack(spacing: isSmallDevice ? ScaleUtility.scaledSpacing(29) : ScaleUtility.scaledSpacing(38)) {
                VStack(spacing: ScaleUtility.scaledSpacing(34)) {
                    EssayHeaderInfoView(
                        url: essayDetail.url,
                        title: essayDetail.title,
                        category: essayDetail.category,
                        wordCount: essayDetail.essay.wordCount
                    )
                    .padding(.leading, ScaleUtility.scaledSpacing(32))
                    .padding(.trailing, ScaleUtility.scaledSpacing(25))

                    if isFromGenerateView {
                        EssayTextEditorView(
                            generatedEssayCoreDataManager: generatedEssayCoreDataManager,
                            essay: $essayDetail.essay,
                            isFavourite: $isFavourite,
                            isFocused: _isTextFieldFocused.projectedValue, essayId: $essayDetail.id,
                            citation: essayDetail.citation,
                            essayTitle: essayDetail.title,
                            isShowDelete: isShowDeleteButton,
                            favouriteAction: favouriteAction,
                            deleteAction: { self.isShowDeleteAlert = true }
                        )
                        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
                    } else {
                        EssayTextDetailView(
                            isFavourite: $isFavourite,
                            essayTitle: essayDetail.title,
                            essay: essayDetail.essay,
                            citation: essayDetail.citation,
                            isShowDelete: isFromGenerateView || isShowDeleteButton,
                            favouriteAction: favouriteAction,
                            deleteAction: { self.isShowDeleteAlert = true }
                        )
                        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
                    }
                }

                if isFromGenerateView || isRegenerateFromLibrary {
                    VStack(spacing: 0) {
                        if isIPad {
                            Spacer()
                        }
                        Button {
                            self.isFavourite = false
                            if isFromGenerateView {
                                generatedEssayCoreDataManager.updateEssayContent(id: essayDetail.id, newEssay: essayDetail.essay)
                            }
                            reGenerateButtonAction(essayDetail.id)
                        } label: {
                            Text("Regenerate")
                        }
                        .buttonStyle(.customButtonStyle)
                        .padding(.horizontal, ScaleUtility.scaledSpacing(80))
                        .padding(.bottom, ScaleUtility.scaledSpacing(10))
                    }
                } else {
                    Spacer()
                }
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.top, ScaleUtility.scaledSpacing(10))
        .background {
            Color.appViewBackground
                .ignoresSafeArea()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .navigationBarBackButtonHidden()
        .alert(isPresented: $isShowDeleteAlert) {
            Alert(
                title: Text("Are you sure you want to delete?"),
                primaryButton: .destructive(Text("Delete")) { deleteAction() },
                secondaryButton: .cancel()
            )
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
//                    hideKeyboard()
                    if isFromGenerateView {
                        generatedEssayCoreDataManager.updateEssayContent(id: essayDetail.id, newEssay: essayDetail.essay)
                    }
                } label: {
                    Text("Done")
                }
                .foregroundStyle(.appTextBackground)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

struct EssayHeaderInfoView: View {
    let url: String
    let title: String
    let category: String
    let wordCount: Int

    var body: some View {
        HStack(spacing: ScaleUtility.scaledSpacing(12)) {
            KFImage(URL(string: url))
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

            VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(4)) {
                Text(title)
                    .font(.system(size: .scaledFontSize(14), weight: .semibold))
                    .foregroundStyle(.appTextBackground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(category)
                    .font(.system(size: .scaledFontSize(12)))
                    .foregroundStyle(.appTextBackground.opacity(0.6))
                    .lineLimit(1)

                Text("\(wordCount) words")
                    .font(.system(size: .scaledFontSize(12)))
                    .foregroundStyle(.appTextBackground.opacity(0.4))
            }
            .pushOutWidth(.leading)
        }
        .pushOutWidth(.leading)
        .padding(.vertical, ScaleUtility.scaledSpacing(5))
    }
}

struct EssayTextEditorView: View {
    @ObservedObject var generatedEssayCoreDataManager: CoreDataManager<GeenrateEssay>
    
    @State private var showToast: Bool = false
    @State private var rendererImage: Image?
    @State private var previousEssayContent: String = ""
    
    @Binding var essay: String
    @Binding var isFavourite: Bool
    let isFocused: FocusState<Bool>.Binding
    @Binding var essayId: String
    let citation: String?
    var essayTitle: String
    let isShowDelete: Bool
    let favouriteAction: () -> Void
    let deleteAction: () -> Void
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(32)) {
            
//            // MARK: - Text Editor
            TextEditor(text: $essay)
                .focused(isFocused)
                .font(.system(size: .scaledFontSize(14)))
                .scrollContentBackground(.hidden)
                .foregroundStyle(.appTextBackground)
                .opacity(0.8)
                .scrollIndicators(.hidden)
                .onChange(of: isFocused.wrappedValue) { _, newValue in
                    if !newValue, previousEssayContent != essay {
                        print("Updating essay with ID: \(essayId) and content: \(essay)")
                        generatedEssayCoreDataManager.updateEssayContent(id: essayId, newEssay: essay)
                        previousEssayContent = essay
                    }
                }
                .frame(height: isSmallDevice ? 350 : 434 * heightRatio)
                .padding(.top, ScaleUtility.scaledSpacing(14))
                .overlay(alignment: .bottom) {
                    ZStack {
                        Color.clear
                        LinearGradient(
                            stops: [
                                .init(color: Color.appEssayGradient.opacity(0.3), location: 0.0),
                                .init(color: Color.appEssayGradient.opacity(0.8), location: 1.0)
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    }
                    .frame(height: ScaleUtility.scaledValue(55))
                    .allowsHitTesting(false)
                }
            
//            // MARK: - Bottom Buttons
            VStack(spacing: ScaleUtility.scaledSpacing(14)) {
                if let citation {
                    Text("Citation: \(citation)")
                        .font(.system(size: .scaledFontSize(12)))
                        .foregroundStyle(.appBlueBackground)
                        .pushOutWidth(.leading)
                        .offset(x: 4)
                        .opacity(citation.isEmpty || citation == "Non Specific" ? 0 : 1)
                }
                
                HStack(spacing: ScaleUtility.scaledSpacing(12)) {
                    if let rendererImage {
                        ShareLink(item: essay, message: Text(""), preview: SharePreview(essayTitle, image: rendererImage)) {
                            Image(.essayShareIcon)
                                .renderingMode(.template)
                                .resizeImage()
                                .square(size: ScaleUtility.scaledValue(16))
                                .foregroundStyle(.appTextBackground)
                        }
                        .onTapGesture {
//                            AnalyticsManager.shared.log(.shareEssay)
                        }
                    }
                    
                    EssayButtonContainerView(
                        image: Image(.essayCopyIcon),
                        action: {
//                            AnalyticsManager.shared.log(.copyEssay)
                            UIPasteboard.general.string = essay
                            showToast = true
                        }
                    )
                    
                    EssayButtonContainerView(
                        image: isFavourite ? Image(.essaySaveFillIcon) : Image(.essaySaveIcon),
                        action: favouriteAction
                    )
                    
                    if isShowDelete {
                        EssayButtonContainerView(
                            image: Image(.essayDeleteIcon),
                            action: deleteAction
                        )
                    }
                }
                .offset(x: 8)
                .pushOutWidth(.trailing)
            }
            .overlay(alignment: (citation?.isEmpty ?? true || citation == "Non Specific") ? .center : .top) {
                Text("Essay Copied")
                    .font(.system(size: .scaledFontSize(10)))
                    .foregroundStyle(.appViewBackground)
                    .padding(4)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.appTextBackground.opacity(0.8))
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .opacity(showToast ? 1 : 0)
                    .offset(y: ScaleUtility.scaledSpacing(-20))
            }
        }
        .padding([.vertical, .leading], ScaleUtility.scaledSpacing(10))
        .padding(.trailing, ScaleUtility.scaledSpacing(18))
        .pushOutWidth()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appEssayBackground)
        }
        .onTapGesture {
            isFocused.wrappedValue = false
        }
        .onAppear {
            previousEssayContent = essay
            renderImage()
        }
        .onChange(of: showToast) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showToast = false
                }
            }
        }
    }
    
    func renderImage() {
        let renderer = ImageRenderer(content: Image(.essayWriterIcon)
            .clipped()
            .background(Color.white)
        )
        if let image = renderer.cgImage {
            rendererImage = Image(decorative: image, scale: 1.0)
        }
    }
}

struct EssayTextDetailView: View {
    @State private var showToast: Bool = false
    @State private var rendererImage: Image?
    
    @Binding var isFavourite: Bool
    var essayTitle: String
    var essay: String
    let citation: String?
    let isShowDelete: Bool
    let favouriteAction: () -> Void
    let deleteAction: () -> Void
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(32)) {
            
            // MARK: - Scrollable Essay Text
            ScrollView {
                Text(essay)
                    .font(.system(size: .scaledFontSize(14)))
                    .foregroundStyle(.appTextBackground)
                    .opacity(0.8)
            }
            .scrollIndicators(.hidden)
            .frame(height: isSmallDevice ? 350 : 434 * heightRatio)
            .padding(.top, ScaleUtility.scaledSpacing(14))
            .scrollBounceBehavior(.basedOnSize)
            .overlay(alignment: .bottom) {
                ZStack {
                    Color.clear
                    LinearGradient(
                        stops: [
                            .init(color: Color.appEssayGradient.opacity(0.3), location: 0.0),
                            .init(color: Color.appEssayGradient.opacity(0.8), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(height: ScaleUtility.scaledValue(55))
                .allowsHitTesting(false)
            }
            
            // MARK: - Buttons & Citation
            VStack(spacing: ScaleUtility.scaledValue(14)) {
                if let citation {
                    Text("Citation: \(citation)")
                        .font(.system(size: .scaledFontSize(12)))
                        .foregroundStyle(.appBlueBackground)
                        .pushOutWidth(.leading)
                        .offset(x: 4)
                        .opacity(citation.isEmpty || citation == "Non Specific" ? 0 : 1)
                }
                
                HStack(spacing: ScaleUtility.scaledSpacing(12)) {
                    if let rendererImage {
                        ShareLink(item: essay, message: Text(""), preview: SharePreview(essayTitle, image: rendererImage)) {
                            Image(.essayShareIcon)
                                .renderingMode(.template)
                                .resizeImage()
                                .square(size: ScaleUtility.scaledValue(16))
                                .foregroundStyle(.appTextBackground)
                        }
                    }
                    
                    EssayButtonContainerView(
                        image: Image(.essayCopyIcon),
                        action: {
//                            AnalyticsManager.shared.log(.copyEssay)
                            UIPasteboard.general.string = essay
                            showToast = true
                        }
                    )
                    
                    EssayButtonContainerView(
                        image: isFavourite ? Image(.essaySaveFillIcon) : Image(.essaySaveIcon),
                        action: favouriteAction
                    )
                    
                    if isShowDelete {
                        EssayButtonContainerView(
                            image: Image(.essayDeleteIcon),
                            action: deleteAction
                        )
                    }
                }
                .offset(x: 8)
                .pushOutWidth(.trailing)
            }
            .overlay(
                alignment: (citation?.isEmpty ?? true || citation == "Non Specific") ? .center : .top
            ) {
                Text("Essay Copied")
                    .font(.system(size: .scaledFontSize(10)))
                    .foregroundStyle(.appViewBackground)
                    .padding(4)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.appTextBackground.opacity(0.8))
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .opacity(showToast ? 1 : 0)
                    .offset(y: ScaleUtility.scaledSpacing(-26))
            }
        }
        .padding([.vertical, .leading], ScaleUtility.scaledSpacing(10))
        .padding(.trailing, ScaleUtility.scaledSpacing(18))
        .pushOutWidth()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appEssayBackground)
        }
        .onAppear {
            renderImage()
        }
        .onChange(of: showToast) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showToast = false
                }
            }
        }
    }
    
    func renderImage() {
        let renderer = ImageRenderer(
            content: Image(.essayWriterIcon)
                .clipped()
                .background(Color.white)
        )
        
        if let image = renderer.cgImage {
            rendererImage = Image(decorative: image, scale: 1.0)
        }
    }
}


struct EssayButtonContainerView: View {
    var image: Image
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            image
                .renderingMode(.template)
                .resizeImage()
                .square(size: ScaleUtility.scaledSpacing(16))
                .foregroundStyle(.appTextBackground)
        }

    }
}
