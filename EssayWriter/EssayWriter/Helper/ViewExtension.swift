//
//  ViewExtension.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    
    /// The size of the main screen.
    var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    /// Width scaling ratio relative to 375pt (typical iPhone width).
    var widthRatio: CGFloat {
        screenSize.width / 375
    }
    
    /// Height scaling ratio for larger iPads (> 1300pt reference).
    var bigIpadHeightRatio: CGFloat {
        screenSize.height / 1300
    }
    
    /// Height scaling ratio relative to 812pt (typical iPhone X height).
    var heightRatio: CGFloat {
        screenSize.height / 812
    }
    
    /// True if the device is smaller than 812pt height.
    var isSmallDevice: Bool {
        screenSize.height < 812
    }
    
    /// True if the device is larger than 1300pt height.
    var isBigIpadDevice: Bool {
        screenSize.height > 1300
    }
    
    /// Width scaling ratio relative to 820pt (iPad width).
    var ipadWidthRatio: CGFloat {
        screenSize.width / 820
    }
    
    /// Height scaling ratio relative to 1366pt (iPad Pro height).
    var ipadHeightRatio: CGFloat {
        screenSize.height / 1366
    }
    
    /// Forces the view into a square frame.
    func square(size: CGFloat) -> some View {
        frame(width: size, height: size)
    }
    
    /// Expands the view to the maximum available width with alignment.
    func pushOutWidth(_ alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }
}

// MARK: - CGFloat Extension for Font Scaling

extension CGFloat {
    
    /// Calculates a scaled font size based on the screen width.
    static func scaledFontSize(_ baseSize: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let scaleFactor = screenWidth / 375
        if isIPad {
            // Adjust multiplier for iPads
            return baseSize * scaleFactor * 0.7
        } else {
            return baseSize * scaleFactor
        }
    }
}

// You’ll need this global flag somewhere in your project:
// For example:
 let isIPad = UIDevice.current.userInterfaceIdiom == .pad

// MARK: - String Extension for Filtering and Counting

extension String {
    
    /// Filters input to allow only letters, numbers, and spaces.
    /// Enforces the character limit strictly, blocking pasting beyond it.
    func filterData(limit: Int) -> String {
        var validCount = 0
        var result = ""
        
        for char in self {
            if char.isLetter || char.isNumber {
                if validCount < limit {
                    result.append(char)
                    validCount += 1
                } else {
                    break
                }
            } else {
                if validCount < limit {
                    result.append(char)
                } else {
                    break
                }
            }
        }
        
        return result
    }
    
    /// Counts only letters and numbers, ignoring spaces and special characters.
    func validCharCount() -> Int {
        filter { $0.isLetter || $0.isNumber }.count
    }
    
    /// Returns the number of words in the string.
    var wordCount: Int {
        split { $0.isWhitespace || $0.isNewline }.count
    }
}
