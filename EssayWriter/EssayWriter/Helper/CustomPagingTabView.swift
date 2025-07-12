//
//  CustomPagingTabView.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import SwiftUI

/// A reusable paging TabView with custom page indicators.
struct CustomPagingTabView<Content: View>: View {
    @Binding var selectedIndex: Int
    let pageCount: Int
    let spacing: CGFloat
    let content: () -> Content

    var body: some View {
        VStack(spacing: spacing) {
            // Custom page indicator
            HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                ForEach(0..<pageCount, id: \.self) { index in
                    if selectedIndex == index {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.appBlueBackground)
                            .frame(
                                width: ScaleUtility.scaledValue(25),
                                height: ScaleUtility.scaledValue(5)
                            )
                    } else {
                        Circle()
                            .fill(Color.appPageSliderBackground)
                            .square(size: 5)
                    }
                }
            }
            .animation(.easeInOut, value: selectedIndex)
            .pushOutWidth()

            // TabView with paging style
            TabView(selection: $selectedIndex) {
                content()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background {
            Color.appViewBackground
        }
    }
}

/// Example usage of CustomPagingTabView
struct CustomPagingTabViewExample: View {
    @State private var selectedIndex = 0
    private let pages = ["Page 1", "Page 2", "Page 3", "Page 4"]

    var body: some View {
        CustomPagingTabView(selectedIndex: $selectedIndex, pageCount: pages.count, spacing: 10) {
            ForEach(0..<pages.count, id: \.self) { index in
                VStack {
                    Text("Content for \(pages[index])")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.systemBackground))
                }
                .tag(index)
            }
        }
    }
}

#Preview {
    CustomPagingTabViewExample()
}
