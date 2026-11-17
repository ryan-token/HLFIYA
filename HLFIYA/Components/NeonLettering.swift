//
//  NeonLettering.swift
//  HLFIYA
//

/// A piece of the intro's Yellowtail lettering, drawn from the font's own outlines.
nonisolated enum NeonLettering {
    /// "Get ready for some", which is written out by hand.
    case getReady

    /// The words of the "Hot Local Food" wordmark, which share one canvas.
    case hot
    case local
    case food

    /// The letters' outlines, as described by the generated data types.
    var outline: [[Double]] {
        switch self {
        case .getReady: GetReadyLetteringData.outline
        case .hot: WordmarkLetteringData.hot
        case .local: WordmarkLetteringData.local
        case .food: WordmarkLetteringData.food
        }
    }

    /// The pen's path through the letters, for lettering that's written by hand.
    var pen: [[Double]] {
        switch self {
        case .getReady: GetReadyLetteringData.pen
        case .hot, .local, .food: []
        }
    }

    /// The canvas's width divided by its height.
    var aspectRatio: Double {
        switch self {
        case .getReady: GetReadyLetteringData.aspectRatio
        case .hot, .local, .food: WordmarkLetteringData.aspectRatio
        }
    }

    /// The font size the lettering was set at, relative to the canvas height, so every piece
    /// can be stroked at the same weight for its size.
    var fontSizeOverHeight: Double {
        switch self {
        case .getReady: GetReadyLetteringData.fontSizeOverHeight
        case .hot, .local, .food: WordmarkLetteringData.fontSizeOverHeight
        }
    }
}
