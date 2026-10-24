//
//  TitleWord.swift
//  HLFIYA
//

import SwiftUI

/// One word of the "Hot Local Food" wordmark, which slides in from an edge when shown.
struct TitleWord: View {
    let image: ImageResource
    let isVisible: Bool
    let insertionEdge: Edge

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .opacity(isVisible ? 1 : 0)
            .offset(x: hiddenOffset.width, y: hiddenOffset.height)
    }

    /// Where the word waits before sliding in. Reduce Motion fades it in place instead.
    private var hiddenOffset: CGSize {
        guard !isVisible, !reduceMotion else { return .zero }
        return switch insertionEdge {
        case .leading: CGSize(width: -300, height: 0)
        case .trailing: CGSize(width: 300, height: 0)
        case .top: CGSize(width: 0, height: -100)
        case .bottom: CGSize(width: 0, height: 100)
        }
    }
}

#Preview {
    TitleWord(image: .hot, isVisible: true, insertionEdge: .leading)
}
