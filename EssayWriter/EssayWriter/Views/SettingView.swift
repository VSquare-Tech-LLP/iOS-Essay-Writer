//
//  SettingView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 16/07/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var favouriteManager: CoreDataManager<FavoriteEssay>
    @EnvironmentObject var generateManager: CoreDataManager<GeenrateEssay>
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SettingView()
}

struct SettingLabelView: View {
    @Environment(\.openURL) private var openLink

    let imageName: ImageResource
    let title: String
    let link: URL

    var body: some View {
        Button {
            openLink(link)
        } label: {
            HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                Image(imageName)
                    .renderingMode(.template)
                    .resizeImage()
                    .square(size: ScaleUtility.scaledValue(22))
                    .foregroundStyle(.appTextBackground)
                
                Text(title)
                    .font(.system(size: .scaledFontSize(14)))
                    .foregroundStyle(.appTextBackground)
            }
            .pushOutWidth(.leading)
            // Optional height if needed:
            // .frame(height: ScaleUtility.scaledValue(24))
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(14))
    }
}


struct SettingButtonContainerView: View {
    let image: ImageResource
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                Image(image)
                    .renderingMode(.template)
                    .resizeImage()
                    .square(size: ScaleUtility.scaledValue(22))
                    .foregroundStyle(.appTextBackground)
                
                Text(title)
                    .font(.system(size: .scaledFontSize(14)))
                    .foregroundStyle(.appTextBackground)
            }
            .pushOutWidth(.leading)
            .frame(height: ScaleUtility.scaledValue(24))
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(14))
    }
}
