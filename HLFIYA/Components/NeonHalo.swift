//
//  NeonHalo.swift
//  HLFIYA
//

import SwiftUI

/// The soft glow around a piece of neon lettering.
///
/// It doesn't set a blend mode itself, so callers can mask or animate it first and then apply
/// `NeonStyle.haloBlendMode(for:)` against what's behind it.
struct NeonHalo: View {
    let lettering: NeonLettering

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LetteringShape(lettering: lettering, strokeWidth: NeonStyle.haloWidth)
            .fill(Color.neonHalo.opacity(NeonStyle.haloOpacity(for: colorScheme)))
    }
}

#Preview {
    NeonHalo(lettering: .getReady)
        .aspectRatio(NeonLettering.getReady.aspectRatio, contentMode: .fit)
        .padding()
}
