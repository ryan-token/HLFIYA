//
//  IntroStep.swift
//  HLFIYA
//

import Foundation

/// The stages of the first-launch intro animation, in order.
enum IntroStep: Int, Comparable {
    case blank, getReady, hot, local, food, buttons

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
