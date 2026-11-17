//
//  NeonWord.swift
//  HLFIYA
//

import SwiftUI

/// One word of the neon "Hot Local Food" wordmark.
enum NeonWord: CaseIterable {
    case hot
    case local
    case food

    /// The word's Yellowtail lettering, already placed within the wordmark.
    var lettering: NeonLettering {
        switch self {
        case .hot: .hot
        case .local: .local
        case .food: .food
        }
    }

    /// The edge the word slides in from when it appears.
    var insertionEdge: Edge {
        switch self {
        case .hot: .leading
        case .local: .trailing
        case .food: .bottom
        }
    }
}
