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
            
            return localCacheAsBusinesses.businesses?.shuffled() ?? []
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    static func getLocalYelpCacheForBusiness(id: String) -> BusinessDetails {
        let localCacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("localYelpCacheForBusId-\(id).json")
        
        do {
            let localYelpCacheForBusiness = try String(contentsOf: localCacheUrl)
            print("Local Yelp Cache for Business with id \(id):")
            print(localYelpCacheForBusiness)
            
            let localCacheAsData = Data(localYelpCacheForBusiness.utf8)
            print("Local cache as data:")
            print(localCacheAsData)
            let localCacheAsBusiness = try! JSONDecoder().decode(BusinessDetails.self, from: localCacheAsData)
            print("Local cache as businesses object:")
            print(localCacheAsBusiness)
            
            return localCacheAsBusiness
        } catch {
            print(error.localizedDescription)
            return BusinessDetails.emptyBusiness
        }
    }
    
    static func clearAnyCacheFilesOverAMonthOld() {
        let documentsDir = getDocumentsDirectory()
        let todaysDate = Date.now
        let calendar = Calendar(identifier: .gregorian)
        
        // loop over every local cache file
        // if any modificationDates are over a month old, return  true
        // otherwise return false
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for fileURL in fileURLs where fileURL.pathExtension == "json" {
                let fileName = fileURL.lastPathComponent
                print("file name: \(fileName)")
                let filePath = fileURL.relativePath
                do {
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
                    
                    for attribute in fileAttributes {
                        if attribute.key == FileAttributeKey("NSFileModificationDate") {
                            let modificationDate = attribute.value as! Date
                            let daysSinceCacheModification = calendar.numberOfDaysBetween(modificationDate, and: todaysDate)
                            print("days since cache modification: \(daysSinceCacheModification)")
                            if daysSinceCacheModification > 30 {
                                print("clearing cache for \(fileName)")
                                try FileManager.default.removeItem(at: fileURL)
                            }
                        }
                    }
                } catch {
                    print("error checking for old cache files: \(error)")
                }
            }
        } catch  {
            print("error getting files from documents dir: \(error)")
        }
    }
    
    static func clearAllCacheFilesInDocumentsDir() {
        let documentsDir = getDocumentsDirectory()
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for fileURL in fileURLs where fileURL.pathExtension == "json" {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch  {
            print("error clearing files from cache: \(error)")
        }
    }
}
