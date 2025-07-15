//
//  CreationEssayHelperView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import SwiftUI

struct CreationEssayHeaderView: View {
    let purchaseHasPro: Bool
    let backButtonAction: () -> Void
    let paywallAction: () -> Void
    let settingAction: () -> Void
    
    var body: some View {
        AppHeaderView(
            leadingBarItem: {
                AppBackButtonView(action: backButtonAction)
            },
            middleBarItem: {
                Text("AI Essay Writer")
                    .font(.system(size: .scaledFontSize(18), weight: .semibold))
                    .foregroundStyle(.appTextBackground)
                    .pushOutWidth(.leading)
            },
            trailingBarItem: {
                HStack(spacing: ScaleUtility.scaledSpacing(16)) {
                    AppPaywallButtonView(action: paywallAction)
                        .opacity(purchaseHasPro ? 0 : 1)
                    
                    AppSettingsButtonView(action: settingAction)
                }
            }
        )
    }
}

struct CustomPicker: View {
//    @EnvironmentObject var purchaseManager: PurchaseManager
    @Binding var selectedTab: EssayGeneratorMode
    var animation: Namespace.ID
    
    var body: some View {
        HStack(spacing: 0) {
            PickerButton(
                title: "Basic Mode",
                tag: .basic,
                selectedTab: $selectedTab,
                animation: animation
            )
            
            PickerButton(
                title: "Guided Mode",
                isLock: false,
                tag: .guided,
                selectedTab: $selectedTab,
                animation: animation
            )
        }
        .padding(2)
        .background(Color.appEssayBackground)
        .cornerRadius(9)
    }
}

struct PickerButton: View {
    let title: String
    var isLock: Bool = false
    let tag: EssayGeneratorMode
    @Binding var selectedTab: EssayGeneratorMode
    var animation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = tag
            }
        }) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: .scaledFontSize(14), weight: .medium))
                    .foregroundColor(
                        selectedTab == tag
                        ? .white
                        : .appTextBackground.opacity(0.5)
                    )
                    .padding(10)
                
                if isLock {
                    Image(.creationLockIcon)
                        .renderingMode(.template)
                        .resizeImage()
                        .frame(
                            width: ScaleUtility.scaledValue(8),
                            height: ScaleUtility.scaledValue(12)
                        )
                        .foregroundStyle(
                            selectedTab == .guided
                            ? .white
                            : Color.appTextBackground
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .background {
                if selectedTab == tag {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.appBlueBackground)
                        .matchedGeometryEffect(id: "background", in: animation)
                }
            }
            .shadow(color: .black.opacity(0.04), radius: 0.5, x: 0, y: 3)
            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct CapsuleSheetView: View {
    var body: some View {
        Capsule()
            .fill(.appTextBackground.opacity(0.2))
            .frame(width: ScaleUtility.scaledSpacing(40), height: ScaleUtility.scaledValue(5))
    }
}
