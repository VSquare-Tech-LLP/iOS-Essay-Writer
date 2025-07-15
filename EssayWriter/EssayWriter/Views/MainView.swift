//
//  MainView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var generateEssayCoreDataManager: CoreDataManager<GeenrateEssay>
    @EnvironmentObject var favouriteEssayCoreDataManager: CoreDataManager<FavoriteEssay>
    @State var selectedTab = AppMainTab.home
    @State var isShowCreateEssayView = false
    @EnvironmentObject var essayCreationViewModel: EssayCreationViewModel
    @EnvironmentObject var homeViewModel: EssayHomeViewModel
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .home:
                        EssayHomeView()
                    case .library:
                        LibraryView()
                    }
                }
                .frame(maxWidth: .infinity)
                
                ZStack {
                    Color.appViewBackground
                        .shadow(color: .appDropBottomShadow, radius: 2.5, x: 4, y: 0)
                    
                    HStack(spacing: 0) {
                        Button {
                            selectedTab = .home
                        } label: {
                            TabBarImageContainerView(imageName: .essayHomeIcon, title: "Home", isSelected: selectedTab == .home)
                        }
                        
                        Spacer()
                            .frame(width: 66 * widthRatio)
                        
                        Button {
                            self.isShowCreateEssayView = true
                        } label: {
                            Image(.essayGenerateIcon)
                                .resizeImage()
                                .square(size: 50)
                        }
                        
                        Spacer()
                            .frame(width: 66 * widthRatio)
                        
                        Button {
                            selectedTab = .library
                        } label: {
                            TabBarImageContainerView(imageName: .essayLibraryIcon, title: "Library", isSelected: selectedTab == .library)
                        }
                    }
                    .padding(.bottom, isSmallDevice ? 10 : 20)
                }
                .frame(height: isSmallDevice ? ScaleUtility.scaledValue(80) : ScaleUtility.scaledSpacing(85))
                .pushOutWidth()
                .navigationDestination(isPresented: $isShowCreateEssayView) {
                    CreationEssayView(isShowSettingView: false, backButtonAcion: {
                        self.isShowCreateEssayView = false
                    })
                }
            }
            .ignoresSafeArea(edges: .bottom)

        }
    }
}

#Preview {
    MainView()
}

struct TabBarImageContainerView: View {
    var imageName: ImageResource
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(6)) {
            Image(imageName)
                .renderingMode(.template)
                .resizeImage()
                .square(size: ScaleUtility.scaledValue(24))
                .foregroundStyle(.appTextBackground)
            Text(title)
                .font(.system(size: .scaledFontSize(12), weight: .medium))
                .foregroundStyle(.appTextBackground)
        }
        .opacity(isSelected ? 1 : 0.4)
    }
}
