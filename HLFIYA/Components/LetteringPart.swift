//
//  LetteringPart.swift
//  HLFIYA
//

/// Which geometry of a piece of lettering to draw.
nonisolated enum LetteringPart {
    /// The letters' filled outlines.
    case outline

    /// The pen's path through the middle of the letters, in writing order.
    case pen
}
