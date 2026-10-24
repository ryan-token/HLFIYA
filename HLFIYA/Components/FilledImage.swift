//
//  FilledImage.swift
//  HLFIYA
//

import SwiftUI

/// An image scaled to fill whatever frame it's given, clipped to that frame.
struct FilledImage: View {
    let image: Image

    var body: some View {
        Color.clear
            .overlay {
                image
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .accessibilityHidden(true)
    }
}
