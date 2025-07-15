//
//  LibraryView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI

struct LibraryView: View {
    @FetchRequest(entity: GeenrateEssay.entity(), sortDescriptors: [])
    private var generateEssay: FetchedResults<GeenrateEssay>
    @EnvironmentObject var favouriteManager: CoreDataManager<FavoriteEssay>
    @EnvironmentObject var generateManager: CoreDataManager<GeenrateEssay>
    
    @State var showSettingView: Bool = false
    
    @State var essayCopeid: Bool = false
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(20)) {
            AppHeaderView(
                leadingBarItem: {
                    Text("AI Essay Writer")
                        .font(.system(size: .scaledFontSize(18), weight: .semibold))
                        .foregroundStyle(.appTextBackground.opacity(0.6))
                }, middleBarItem: {
                    Spacer()
                }, trailingBarItem: {
                    HStack(spacing: ScaleUtility.scaledSpacing(16)) {
                        AppPaywallButtonView(action: {
                            
                        })
                        
                        AppSettingsButtonView(action: {
                            
                        })
                    }
                }
            )
            .padding(.horizontal, ScaleUtility.scaledSpacing(25))
            
            LibraryFavoriteEssayView()
            
            LibraryGenerateEssayView(isShowPaywall: .constant(false), essayCopied: $essayCopeid)
                .padding(.top, ScaleUtility.scaledSpacing(7))
                .padding(.horizontal, ScaleUtility.scaledSpacing(25))

        }
        .overlay(alignment: .bottom, content: {
            Text("Essay Copied")
                .font(.system(size: .scaledFontSize(10)))
                .foregroundStyle(.appViewBackground)
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.appTextBackground.opacity(0.8))
                }
                .transition(.move(edge: .top).combined(with: .opacity)) // Slide in from top & fade out
                .opacity(essayCopeid ? 1 : 0)
                .offset(y: ScaleUtility.scaledSpacing(-110))
                .border(.red)
        })
        .background {
            Color.appViewBackground
                .ignoresSafeArea()
        }
        .onChange(of: essayCopeid) { newValue in
            if newValue == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.essayCopeid = false
                }
            }
        }
    }
}

#Preview {
    LibraryView()
}
