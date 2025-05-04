//
//  View+Snapshot.swift
//  Whisk
//
//  Created by Hesham Aly on 4/16/25.
//

import SwiftUI

extension View {
  /// Render this SwiftUI view to a UIImage.
  func snapshot(width: CGFloat) -> UIImage {
    // 1) Create a hosting controller with this view.
    let controller = UIHostingController(rootView: self)
    // 2) Decide on a fitting size: full device width, infinite height
    let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
    controller.view.bounds = CGRect(origin: .zero, size: targetSize)
    controller.view.backgroundColor = .clear

    // 3) Let the view layout itself
    let size = controller.sizeThatFits(in: targetSize)
    controller.view.bounds = CGRect(origin: .zero, size: size)

    // 4) Render to image
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
      controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
    }
  }
}
