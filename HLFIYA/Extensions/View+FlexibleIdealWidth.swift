//
//  View+FlexibleIdealWidth.swift
//  HLFIYA
//

import SwiftUI

extension View {
    /// Fills the width it's offered, wrapping or truncating to fit, but asks for no width
    /// of its own.
    ///
    /// `ViewThatFits` measures each option's ideal width, which for text is its whole
    /// length on one line. Without this, a long name or category would rule out every
    /// option on a narrow card, even though it would happily wrap.
    func flexibleIdealWidth() -> some View {
        frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
