//
//  CustomHeaderView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import SwiftUI

/// A customizable header view with leading, middle, and trailing bar items.
struct AppHeaderView: View {
    
    var leadingBarItem: () -> AnyView
    var middleBarItem: () -> AnyView
    var trailingBarItem: () -> AnyView
    
    /// Initializes the header with optional bar items.
    ///
    /// Defaults to Spacer() if not provided.
    init(
        leadingBarItem: @escaping () -> some View = { Spacer() },
        middleBarItem: @escaping () -> some View = { Spacer() },
        trailingBarItem: @escaping () -> some View = { Spacer() }
    ) {
        // Type erasure to AnyView
        self.leadingBarItem = { AnyView(leadingBarItem()) }
        self.middleBarItem = { AnyView(middleBarItem()) }
        self.trailingBarItem = { AnyView(trailingBarItem()) }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            leadingBarItem()
            Spacer()
            middleBarItem()
            Spacer()
            trailingBarItem()
        }
    }
}

// MARK: - Preview

#Preview {
    AppHeaderView(
        leadingBarItem: {
            Text("AI Essay Writer")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.appTextBackground)
        },
        middleBarItem: {
            Spacer()
        },
        trailingBarItem: {
            HStack(spacing: 16) {
                AppPaywallButtonView(action: {})
                AppSettingsButtonView(action: {})
            }
        }
    )
}
