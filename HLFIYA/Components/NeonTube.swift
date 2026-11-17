//
//  NeonTube.swift
//  HLFIYA
//

import SwiftUI

/// The lit tube of a piece of neon lettering: a pink glass edge around a white-hot core.
struct NeonTube: View {
    let lettering: NeonLettering

    var body: some View {
        ZStack {
            LetteringShape(lettering: lettering, strokeWidth: NeonStyle.tubeWidth)
                .fill(NeonStyle.tubeGradient)

            LetteringShape(lettering: lettering)
                .fill(Color.neonCore)
        }
    }
}

#Preview {
    NeonTube(lettering: .getReady)
        .aspectRatio(NeonLettering.getReady.aspectRatio, contentMode: .fit)
        .padding()
        .background(.black)
}
