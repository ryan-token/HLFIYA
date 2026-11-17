//
//  NeonFlicker.swift
//  HLFIYA
//

import SwiftUI

/// The brightness of a neon tube as it catches: a couple of quick stutters, then steady.
enum NeonFlicker {
    static var keyframes: some Keyframes<Double> {
        KeyframeTrack {
            LinearKeyframe(0.15, duration: 0.05)
            LinearKeyframe(1.0, duration: 0.07)
            LinearKeyframe(0.35, duration: 0.06)
            LinearKeyframe(1.0, duration: 0.09)
            LinearKeyframe(0.7, duration: 0.05)
            LinearKeyframe(1.0, duration: 0.12)
        }
    }
}
