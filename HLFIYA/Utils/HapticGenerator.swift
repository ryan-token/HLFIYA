//
//  HapticGenerator.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/12/22.
//

import SwiftUI

@MainActor
class HapticGenerator {
    static func playSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func playWarningHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func playErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
