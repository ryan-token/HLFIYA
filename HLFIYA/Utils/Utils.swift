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
    
    static func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    static func getLocalYelpCache() -> [Business] {
        let localCacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("localYelpCache.json")
        
        do {
            let localYelpCache = try String(contentsOf: localCacheUrl)
            print("Local Yelp Cache:")
            print(localYelpCache)
            
            let localCacheAsData = Data(localYelpCache.utf8)
            print("Local cache as data:")
            print(localCacheAsData)
            let localCacheAsBusinesses = try! JSONDecoder().decode(Businesses.self, from: localCacheAsData)
            print("Local cache as businesses object:")
            print(localCacheAsBusinesses)
            
            return localCacheAsBusinesses.businesses ?? []
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}
