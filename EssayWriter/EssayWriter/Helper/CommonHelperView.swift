//
//  CommonHelperView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import UIKit
import SwiftUI

/// Flag indicating if the device is an iPad.
let isIPadDevice = UIDevice.current.userInterfaceIdiom == .pad

/// Tabs for the main app interface.
enum AppMainTab: CaseIterable {
    case home
    case library
}

/// Sample image URLs for testing.
var sampleImageURLs: [String] = [
    "https://fastly.picsum.photos/id/569/200/200.jpg?hmac=rzX0dRJRyZs2NIa_h_87CJVeoetRLtTlweCZmYrYlCA",
    "https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI",
    "https://fastly.picsum.photos/id/126/200/300.jpg?hmac=YZspkRJLWLgmsrQIIdievQ5w-KqBV-gNF7WgCbTSM8A",
    "https://fastly.picsum.photos/id/121/200/300.jpg?hmac=2fXySXN_YXZfcWVqSvYNuH7podc4E9cEj89RqtBW238",
    "https://fastly.picsum.photos/id/13/2500/1667.jpg?hmac=SoX9UoHhN8HyklRA4A3vcCWJMVtiBXUg0W4ljWTor7s",
    "https://fastly.picsum.photos/id/1/200/300.jpg?hmac=jH5bDkLr6Tgy3oAg5khKCHeunZMHq0ehBZr6vGifPLY"
]

/// Modes for the essay generator.
enum EssayGeneratorMode: CaseIterable {
    case basic
    case guided
}

/// Length options for generated essays.
enum EssayLengthOption: String, CaseIterable {
    case short = "Short"
    case medium = "Medium"
    case long = "Long"
}

/// Academic levels for essay tone.
enum EssayAcademicLevelOption: String, CaseIterable {
    case highSchool = "High School"
    case college = "College"
    case university = "University"
    case master = "Masters"
    case doctorate = "Doctorate"
}

/// Number of paragraphs options.
enum EssayParagraphCount: String, CaseIterable {
    case nonSpecific = "Non Specific"
    case five = "5"
    case ten = "10"
    case fifteen = "15"
}

/// Writing style options for essays.
enum EssayWritingStyleOption: String, CaseIterable {
    case argumentative = "Argumentative"
    case persuasive = "Persuasive"
    case analytical = "Analytical"
    case expository = "Expository"
    case narrative = "Narrative"
    case comparing = "Comparing"
}

/// Tone options for essay generation.
enum EssayToneOption: String, CaseIterable {
    case friendly = "Friendly"
    case professional = "Professional"
    case bold = "Bold"
    case witty = "Witty"
    case inspirational = "Inspirational"
    case informative = "Informative"
    case neutral = "Neutral"
    case empathetic = "Empathetic"
}

/// Citation formats for essays.
enum EssayCitationStyle: String, CaseIterable {
    case nonSpecific = "Non Specific"
    case apa = "APA"
    case asa = "ASA"
    case bluebook = "Bluebook"
    case cbe = "CBE"
    case chicago = "Chicago"
    case harvard = "Harvard"
    case ieee = "IEEE"
    case mla = "MLA"
    case turabian = "Turabian"
}

/// Theme modes for the app appearance.
enum AppThemeMode: String, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: return "System Default"
        case .light: return "Light Mode"
        case .dark: return "Dark Mode"
        }
    }
}

/// Back button component.
struct AppBackButtonView: View {
    var opacity: Double = 1
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(.backButtonIcon)
                .renderingMode(.template)
                .resizeImage()
                .frame(
                    width: ScaleUtility.scaledValue(18),
                    height: ScaleUtility.scaledValue(16),
                    alignment: .top
                )
                .foregroundStyle(.appTextBackground.opacity(opacity))
        }
    }
}

/// Paywall button component.
struct AppPaywallButtonView: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(.crown)
                .resizeImage()
                .square(size: ScaleUtility.scaledValue(24))
        }
    }
}

/// Settings button component.
struct AppSettingsButtonView: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(.settingIcon)
                .renderingMode(.template)
                .resizeImage()
                .square(size: ScaleUtility.scaledValue(24))
                .foregroundStyle(.appTextBackground)
        }
    }
}

/// Utility to dismiss the keyboard.
func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
