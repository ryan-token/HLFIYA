//
//  GetReadyReveal.swift
//  HLFIYA
//

import SwiftUI

/// A mask that uncovers the "Get ready for some" lettering along the pen's path, as far as it
/// has been written.
///
/// The pen is wider than the letters' thickest strokes and their glow, so whatever it has
/// passed over shows in full.
struct GetReadyReveal: View {
    /// How much of the lettering is written, from 0 to 1.
    let writtenFraction: Double
    let lineWidth: Double

    var body: some View {
        LetteringShape(lettering: .getReady, part: .pen)
            .trim(from: 0, to: writtenFraction)
            .stroke(.white, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
    }
}

#Preview {
    GetReadyReveal(writtenFraction: 0.6, lineWidth: 12)
        .aspectRatio(NeonLettering.getReady.aspectRatio, contentMode: .fit)
        .padding()
        .background(.black)
}
