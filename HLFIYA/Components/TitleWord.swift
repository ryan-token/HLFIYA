//
//  TitleWord.swift
//  HLFIYA
//

import SwiftUI

/// One word of the neon "Hot Local Food" wordmark. When shown, it slides in from its edge
/// and flickers on like a neon tube catching.
///
/// It's drawn from Yellowtail's outlines with the app icon's sign layers: a clear acrylic
/// backer, a glow that brightens what's beneath it, a pink tube with a glassy sheen, and a
/// white-hot core.
struct TitleWord: View {
    let word: NeonWord
    let isVisible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LetteringShape(lettering: word.lettering, strokeWidth: NeonStyle.backerWidth)
                // White acrylic disappears on a light background, so tint it there instead.
                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.neonHalo.opacity(0.12))

            NeonHalo(lettering: word.lettering)
                .blendMode(NeonStyle.haloBlendMode(for: colorScheme))
                .keyframeAnimator(initialValue: 1.0, trigger: flickerTrigger) { content, brightness in
                    content.opacity(brightness)
                } keyframes: { _ in
                    NeonFlicker.keyframes
                }

            NeonTube(lettering: word.lettering)
                .shadow(color: NeonStyle.shadowColor, radius: 6)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: hiddenOffset.width, y: hiddenOffset.height)
    }

    /// Changes only when the word appears with motion allowed, so Reduce Motion skips the flicker.
    private var flickerTrigger: Bool {
        isVisible && !reduceMotion
    }

    /// Where the word waits before sliding in. Reduce Motion fades it in place instead.
    private var hiddenOffset: CGSize {
        guard !isVisible, !reduceMotion else { return .zero }
        return switch word.insertionEdge {
        case .leading: CGSize(width: -300, height: 0)
        case .trailing: CGSize(width: 300, height: 0)
        case .top: CGSize(width: 0, height: -100)
        case .bottom: CGSize(width: 0, height: 100)
        }
    }
}

#Preview {
    ZStack {
        ForEach(NeonWord.allCases, id: \.self) { word in
            TitleWord(word: word, isVisible: true)
        }
    }
    .aspectRatio(WordmarkLetteringData.aspectRatio, contentMode: .fit)
    .padding()
}
