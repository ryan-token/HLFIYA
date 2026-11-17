//
//  GetReadyTitle.swift
//  HLFIYA
//

import SwiftUI

/// "Get ready for some", written out in neon as if by hand when it appears.
///
/// It's set in Yellowtail with the same neon layers as the wordmark below it: a glow, a pink
/// tube, and a white-hot core. A mask follows the pen's path through the letters, so they're
/// uncovered stroke by stroke from left to right.
struct GetReadyTitle: View {
    let isVisible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    /// The lettering's height at the default text size; it grows with Dynamic Type and
    /// shrinks only if the width runs out.
    @ScaledMetric(relativeTo: .title) private var height = 52.0

    /// The pen's width relative to the lettering's height, covering the thickest letter
    /// strokes plus the glow on either side.
    private static let penWidthRatio = 0.27

    /// How long the writing takes, at an unhurried hand-lettering pace.
    private static let writingAnimation = Animation.timingCurve(0.35, 0, 0.65, 1, duration: 2)

    var body: some View {
        ZStack {
            NeonHalo(lettering: .getReady)
                .mask {
                    GetReadyReveal(writtenFraction: writtenFraction, lineWidth: height * Self.penWidthRatio)
                }
                // Blended after masking, so the glow lightens what's behind the lettering.
                .blendMode(NeonStyle.haloBlendMode(for: colorScheme))

            NeonTube(lettering: .getReady)
                .mask {
                    GetReadyReveal(writtenFraction: writtenFraction, lineWidth: height * Self.penWidthRatio)
                }
                .shadow(color: NeonStyle.shadowColor, radius: 4)
        }
        .aspectRatio(NeonLettering.getReady.aspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: height)
        // Reduce Motion fades the finished lettering in instead of writing it.
        .opacity(reduceMotion && !isVisible ? 0 : 1)
        // Only the intro's animated steps get the writing pace; jumping straight to the end,
        // as when returning from Settings, shows the lettering at once.
        .transaction(value: isVisible) { transaction in
            if transaction.animation != nil, !reduceMotion {
                transaction.animation = Self.writingAnimation
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Get ready for some")
    }

    /// How much of the lettering is written. Both neon layers share it, so they're written together.
    private var writtenFraction: Double {
        isVisible || reduceMotion ? 1 : 0
    }
}

#Preview {
    @Previewable @State var isVisible = false

    VStack {
        GetReadyTitle(isVisible: isVisible)
        Button(isVisible ? "Reset" : "Write") {
            withAnimation { isVisible.toggle() }
        }
    }
    .padding()
}
