//
//  ImageExtention.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import SwiftUI

// MARK: - Image Extension for Resizing Helpers

extension Image {
    
    /// Makes the image resizable with `.fit` aspect ratio.
    ///
    /// - Returns: A resizable, aspect-fit image view.
    func resizeImage() -> some View {
        resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    /// Makes the image resizable with `.fit` aspect ratio and fixed size.
    ///
    /// - Parameter size: The target size for the image frame.
    /// - Returns: A resizable, aspect-fit image view with specified size.
    func resizable(size: CGSize) -> some View {
        resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width, height: size.height)
    }
}
