//
//  ImageManager.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 15/07/25.
//

import Foundation
import SwiftUI
import UIKit

struct ImageShareTransferable: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }

    public var image: Image
    public var caption: String
}

struct ScrollViewSnapshot: UIViewRepresentable {
    var content: AnyView
    var scale: CGFloat

    class Coordinator: NSObject {
        var parent: ScrollViewSnapshot

        init(parent: ScrollViewSnapshot) {
            self.parent = parent
        }

        func captureSnapshot() -> UIImage? {
            let view = parent.content
            let controller = UIHostingController(rootView: view.edgesIgnoringSafeArea(.all))

            controller.view.setNeedsLayout()
            controller.view.layoutIfNeeded()

            let targetSize = CGSize(
                width: UIScreen.main.bounds.width,
                height: controller.view.intrinsicContentSize.height
            )
            controller.view.frame = CGRect(origin: .zero, size: targetSize)

            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        DispatchQueue.main.async {
            if let snapshotImage = context.coordinator.captureSnapshot() {
                print("Snapshot captured!")
                // You can store this image or handle it as needed
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class ImageManager: NSObject, ObservableObject {
    @Published var imageShareTransferable: ImageShareTransferable? = nil
    @Published var imageSaved: Int = 0
    @Published var showError: Bool = false

    @MainActor
    func saveView(_ view: some View, scale: CGFloat) {
        if let uiImage = getUIImage(view, scale: scale) {
            writeToPhotoAlbum(image: uiImage)
        }
    }

    @MainActor
    func getTransferable(_ view: some View, scale: CGFloat, caption: String) -> ImageShareTransferable? {
        if let uiImage = getUIImage(view, scale: scale) {
            return ImageShareTransferable(image: Image(uiImage: uiImage), caption: caption)
        }
        return nil
    }

    @MainActor
    func getUIImage(_ view: some View, scale: CGFloat) -> UIImage? {
        let scrollViewSnapshot = ScrollViewSnapshot(content: AnyView(view), scale: scale)
        let coordinator = scrollViewSnapshot.makeCoordinator()
        return coordinator.captureSnapshot()
    }

    private func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Saving finished with error: \(error)")
            self.showError = true
        } else {
            print("Save finished!")
            imageSaved += 1
        }
    }

    static func defaultImageShareTransferable() -> ImageShareTransferable {
        let defaultImage = Image(systemName: "photo")
        return ImageShareTransferable(image: defaultImage, caption: "Default Caption")
    }
}
