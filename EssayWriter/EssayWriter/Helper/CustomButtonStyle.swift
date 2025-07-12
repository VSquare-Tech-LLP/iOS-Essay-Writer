//
//  CustomButtonStyle.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import SwiftUI

import SwiftUI

// MARK: - Custom Button Styles

/// A general-purpose button style with medium system font and capsule background.
struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: .scaledFontSize(14), weight: .medium))
            .foregroundStyle(configuration.isPressed ? Color.white.opacity(0.5) : .white)
            .frame(height: ScaleUtility.scaledValue(42))
            .pushOutWidth()
            .background(
                Capsule()
                    .fill(Color.appBlueBackground)
            )
    }
}

extension ButtonStyle where Self == CustomButtonStyle {
    /// Accessor for `CustomButtonStyle`.
    static var customButtonStyle: CustomButtonStyle {
        CustomButtonStyle()
    }
}

/// A paywall button style with bold custom font and capsule background.
struct PaywallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.ceraProBold(15))
            .foregroundStyle(configuration.isPressed ? Color.white.opacity(0.5) : .white)
            .frame(height: ScaleUtility.scaledValue(56))
            .pushOutWidth()
            .background(
                Capsule()
                    .fill(Color.appBlueBackground)
            )
    }
}

extension ButtonStyle where Self == PaywallButtonStyle {
    /// Accessor for `PaywallButtonStyle`.
    static var paywallButtonStyle: PaywallButtonStyle {
        PaywallButtonStyle()
    }
}

/// A gift paywall button style with bold custom font and capsule background.
struct GiftPaywallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.ceraProBold(14))
            .foregroundStyle(configuration.isPressed ? Color.white.opacity(0.5) : .white)
            .frame(height: ScaleUtility.scaledValue(44))
            .pushOutWidth()
            .background(
                Capsule()
                    .fill(Color.appBlueBackground)
            )
    }
}

extension ButtonStyle where Self == GiftPaywallButtonStyle {
    /// Accessor for `GiftPaywallButtonStyle`.
    static var giftPaywallButtonStyle: GiftPaywallButtonStyle {
        GiftPaywallButtonStyle()
    }
}


