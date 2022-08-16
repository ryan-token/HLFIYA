//
//  Utils.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/30/22.
//

import Foundation


class Utils {
    static func convertMilesToMeters(miles: Double) -> Int {
        let distanceInMiles = Measurement(value: miles, unit: UnitLength.miles)
        let distanceInMeters = distanceInMiles.converted(to: UnitLength.meters)
        
        let distanceInMetersDouble = distanceInMeters.value
        let distanceInMetersRounded = Int(distanceInMetersDouble.rounded())
        
        return distanceInMetersRounded
    }
}
