//
//  NeonStyle.swift
//  HLFIYA
//

import SwiftUI

/// The shared look of the intro's neon lettering, taken from the app icon's sign.
enum NeonStyle {
    /// The pink tube around each letter, relative to the font size: the icon's 14-point tube
    /// at 300 points.
    static let tubeWidth = 14.0 / 300

    /// The glow around the tube, relative to the font size: the icon's 40-point halo at
    /// 300 points.
    static let haloWidth = 40.0 / 300

    /// The clear acrylic the wordmark's tubes are mounted on, reaching past the letters by
    /// half this, relative to the font size: the icon's 68-point backer at 300 points.
    static let backerWidth = 68.0 / 300

    /// The tube's glassy sheen, lighter at the top.
    static let tubeGradient = LinearGradient(
        colors: [Color.neonTube.mix(with: .white, by: 0.3), Color.neonTube],
        startPoint: .top,
        endPoint: .bottom
    )

    /// The icon's chromatic shadow: the tube's color spilling onto what's behind it.
    static let shadowColor = Color.neonTube.opacity(0.45)

    /// The glow is stronger against a dark background.
    static func haloOpacity(for colorScheme: ColorScheme) -> Double {
        colorScheme == .dark ? 0.42 : 0.3
    }

    /// The glow lightens what's beneath it, like the icon's; on a light background that would
    /// vanish, so it blends normally there.
    static func haloBlendMode(for colorScheme: ColorScheme) -> BlendMode {
        colorScheme == .dark ? .plusLighter : .normal
    }
}
