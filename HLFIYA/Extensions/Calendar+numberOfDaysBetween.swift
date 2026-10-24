//
//  Calendar+numberOfDaysBetween.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/14/23.
//

import Foundation

extension Calendar {
    /// The number of calendar days from the start date to the end date.
    nonisolated func numberOfDaysBetween(_ start: Date, and end: Date) -> Int {
        dateComponents([.day], from: startOfDay(for: start), to: startOfDay(for: end)).day ?? 0
    }
}
