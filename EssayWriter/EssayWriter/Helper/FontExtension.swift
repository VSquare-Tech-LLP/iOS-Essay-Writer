//
//  FontExtension.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Font Constants

enum FontConstants {
    /// Font name for CeraPro-Bold.
    static let ceraProBold = "CeraPro-Bold"
    
    /// Font name for CeraPro-Medium.
    static let ceraProMedium = "CeraPro-Medium"
    
    /// Font name for CeraPro-Regular (removed .ttf suffix to match registered name).
    static let ceraProRegular = "CeraPro-Regular"
    
    /// Font name for HankenGrotesk-Bold.
    static let hankenGroteskBold = "HankenGrotesk-Bold"
    
    /// Font name for HankenGrotesk-Black.
    static let hankenGroteskBlack = "HankenGrotesk-Black"
}

// MARK: - Font Extension for Custom Fonts

extension Font {
    
    /// Returns CeraPro-Bold font scaled to screen size.
    static func ceraProBold(_ size: CGFloat) -> Font {
        .custom(FontConstants.ceraProBold, size: .scaledFontSize(size))
    }
    
    /// Returns CeraPro-Medium font scaled to screen size.
    static func ceraProMedium(_ size: CGFloat) -> Font {
        .custom(FontConstants.ceraProMedium, size: .scaledFontSize(size))
    }
    
    /// Returns CeraPro-Regular font scaled to screen size.
    static func ceraProRegular(_ size: CGFloat) -> Font {
        .custom(FontConstants.ceraProRegular, size: .scaledFontSize(size))
    }
    
    /// Returns HankenGrotesk-Bold font scaled to screen size.
    static func hankenGroteskBold(_ size: CGFloat) -> Font {
        .custom(FontConstants.hankenGroteskBold, size: .scaledFontSize(size))
    }
    
    /// Returns HankenGrotesk-Black font scaled to screen size.
    static func hankenGroteskBlack(_ size: CGFloat) -> Font {
        .custom(FontConstants.hankenGroteskBlack, size: .scaledFontSize(size))
    }
}
