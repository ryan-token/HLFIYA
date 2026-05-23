//
//  Calendar+numberOfDaysBetween.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/14/23.
//

import Foundation

extension Calendar {
    nonisolated func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
}
