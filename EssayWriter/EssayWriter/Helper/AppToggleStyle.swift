//
//  AppToggleStyle.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import SwiftUI

/// A toggle style with a capsule background and animated sliding circle.
struct AppToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Capsule()
                .fill(configuration.isOn ? .appBlueBackground : .appTextBackground.opacity(0.10))
                .frame(
                    width: ScaleUtility.scaledValue(37),
                    height: ScaleUtility.scaledValue(20)
                )
                .overlay(
                    Circle()
                        .fill(.white)
                        .square(size: ScaleUtility.scaledValue(16))
                        .clipShape(Circle())
                        .offset(x: configuration.isOn ? 9 : -10)
                )
                .animation(.easeInOut(duration: 0.3), value: configuration.isOn)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

extension ToggleStyle where Self == AppToggleStyle {
    /// Accessor for `AppToggleStyle`.
    static var appToggleStyle: AppToggleStyle {
        AppToggleStyle()
    }
}
