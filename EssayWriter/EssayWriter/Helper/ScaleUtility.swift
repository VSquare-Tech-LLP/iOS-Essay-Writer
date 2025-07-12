//
//  ScaleUtility.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import UIKit


/// Utility for scaling values and spacing based on screen size and design dimensions.
struct ScaleUtility {
    
    /// The width of the device screen.
    static let screenWidth = UIScreen.main.bounds.width
    
    /// The height of the device screen.
    static let screenHeight = UIScreen.main.bounds.height
    
    /// The reference design width (e.g., from Figma).
    static let designWidth: CGFloat = 375
    
    /// The reference design height (optional).
    static let designHeight: CGFloat = 825
    
    /// Checks if the current device is an iPad.
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Scales a value proportionally to screen width.
    ///
    /// - Parameter value: The value to scale (e.g. 16 from design).
    /// - Returns: The scaled value for the current device.
    static func scaledValue(_ value: CGFloat) -> CGFloat {
        let scaleFactor: CGFloat
        if isIPad {
            scaleFactor = screenWidth / (designWidth * 2)
        } else {
            scaleFactor = screenWidth / designWidth
        }
        return value * scaleFactor
    }
    
    /// Scales spacing values proportionally, with special handling for iPads.
    ///
    /// - Parameter baseValue: The spacing value from the design.
    /// - Returns: The scaled spacing for the current device.
    static func scaledSpacing(_ baseValue: CGFloat) -> CGFloat {
        let scaleFactor = screenWidth / (isIPad ? designWidth * 2 : designWidth)
        return baseValue * scaleFactor
    }
}

