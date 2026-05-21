//
//  Utils.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/30/22.
//

import Foundation
import CoreLocation

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
            let localYelpCache = try String(contentsOf: localCacheUrl, encoding: .utf8)
            let localCacheAsData = Data(localYelpCache.utf8)
            let localCacheAsBusinesses = try! JSONDecoder().decode(Businesses.self, from: localCacheAsData)
            
            return localCacheAsBusinesses.businesses?.shuffled() ?? []
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    static func getLocalYelpCacheForBusiness(id: String) -> BusinessDetails {
        let localCacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("localYelpCacheForBusId-\(id).json")
        
        do {
            let localYelpCacheForBusiness = try String(contentsOf: localCacheUrl, encoding: .utf8)
            
            let localCacheAsData = Data(localYelpCacheForBusiness.utf8)
            let localCacheAsBusiness = try! JSONDecoder().decode(BusinessDetails.self, from: localCacheAsData)
            
            return localCacheAsBusiness
        } catch {
            print(error.localizedDescription)
            return BusinessDetails.emptyBusiness
        }
    }
    
    static func writeIsOpenNowFilterToCache(onlyShowOpenNow: Bool) {
        let cacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("isOpenNowFilterCache.txt")
        var onlyShowOpenNowString = "false"
        if onlyShowOpenNow {
            onlyShowOpenNowString = "true"
        }
        do {
            try onlyShowOpenNowString.write(to: cacheUrl, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func getIsOpenNowFilterCache() -> Bool {
        let localCacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("isOpenNowFilterCache.txt")
        
        do {
            let isOpenNowCache = try String(contentsOf: localCacheUrl, encoding: .utf8)
            if (isOpenNowCache == "true") {
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    static func writeCategoriesFilterToCache(categories: Set<String>, categoriesNames: String) {
        let categoriesStruct = CategoriesFilter(categories: categories, categoriesNames: categoriesNames)

        let encoder = JSONEncoder()
        let cacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("categoriesFilterCache.json")
        do {
            let result = try encoder.encode(categoriesStruct)
            if let jsonString = String(data: result, encoding: .utf8){
                do {
                    try jsonString.write(to: cacheUrl, atomically: true, encoding: .utf8)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print("Error writing categories filter to cache: \(error)")
        }
    }
    
    static func getCategoriesFilterCache() -> CategoriesFilter {
        let localCacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("categoriesFilterCache.json")
        
        do {
            let localYelpCache = try String(contentsOf: localCacheUrl, encoding: .utf8)
            let localCacheAsData = Data(localYelpCache.utf8)
            let localCacheAsCategories = try! JSONDecoder().decode(CategoriesFilter.self, from: localCacheAsData)
            
            return localCacheAsCategories
        } catch {
            print(error.localizedDescription)
            return CategoriesFilter(categories: ["food"], categoriesNames: "All Food")
        }
    }
    
    static func writePricesFilterToCache(prices: Set<String>, priceName: String) {
        let pricesStruct = PricesFilter(prices: prices, priceName: priceName)

        let encoder = JSONEncoder()
        let cacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("pricesFilterCache.json")
        do {
            let result = try encoder.encode(pricesStruct)
            if let jsonString = String(data: result, encoding: .utf8){
                do {
                    try jsonString.write(to: cacheUrl, atomically: true, encoding: .utf8)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print("Error writing prices filter to cache: \(error)")
        }
    }
    
    static func getPricesFilterCache() -> PricesFilter {
        let localCacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("pricesFilterCache.json")
        
        do {
            let localYelpCache = try String(contentsOf: localCacheUrl, encoding: .utf8)
            let localCacheAsData = Data(localYelpCache.utf8)
            let localCacheAsPrices = try! JSONDecoder().decode(PricesFilter.self, from: localCacheAsData)
            
            return localCacheAsPrices
        } catch {
            print(error.localizedDescription)
            return PricesFilter(prices: ["All Prices"], priceName: "All Prices")
        }
    }
    
    static func writeReviewDateToDocumentsDir(date: Date) {
        let lastReviewDateDoc = Utils.getDocumentsDirectory().appendingPathComponent("lastReviewData.txt")
        let today = Date.now
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let dateString = formatter.string(from: today)
        do {
            try dateString.write(to: lastReviewDateDoc, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func getLastReviewRequestFromDocumentsDir() -> String {
        let lastReviewDateDoc = Utils.getDocumentsDirectory().appendingPathComponent("lastReviewData.txt")
        
        do {
            let lastReviewDateString = try String(contentsOf: lastReviewDateDoc, encoding: .utf8)
            return lastReviewDateString
        } catch {
            print(error.localizedDescription)
            return "Unknown"
        }
    }
    
    static func writeLocationFilterToCache(customLatitude: CLLocationDegrees, customLongitude: CLLocationDegrees, customRadius: Double) {
        let locationStruct = LocationFilter(customLatitude: customLatitude, customLongitude: customLongitude, customRadius: customRadius)

        let encoder = JSONEncoder()
        let cacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("locationFilterCache.json")
        do {
            let result = try encoder.encode(locationStruct)
            if let jsonString = String(data: result, encoding: .utf8){
                do {
                    try jsonString.write(to: cacheUrl, atomically: true, encoding: .utf8)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print("Error writing location filter to cache: \(error)")
        }
    }
    
    static func getLocationFilterCache() -> LocationFilter {
        let localCacheUrl = Utils.getDocumentsDirectory().appendingPathComponent("locationFilterCache.json")
        
        do {
            let localYelpCache = try String(contentsOf: localCacheUrl, encoding: .utf8)
            let localCacheAsData = Data(localYelpCache.utf8)
            let localCacheAsLocation = try! JSONDecoder().decode(LocationFilter.self, from: localCacheAsData)
            
            return localCacheAsLocation
        } catch {
            print(error.localizedDescription)
            return LocationFilter(customLatitude: CLLocationDegrees(), customLongitude: CLLocationDegrees(), customRadius: 5.0)
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
    
    struct CategoriesFilter: Codable {
        var categories: Set<String>
        var categoriesNames: String
        
        init(categories: Set<String>, categoriesNames: String) {
            self.categories = categories
            self.categoriesNames = categoriesNames
        }
    }
    
    struct PricesFilter: Codable {
        var prices: Set<String>
        var priceName: String
        
        init(prices: Set<String>, priceName: String) {
            self.prices = prices
            self.priceName = priceName
        }
    }
    
    struct LocationFilter: Codable {
        var customLatitude: CLLocationDegrees
        var customLongitude: CLLocationDegrees
        var customRadius: Double
        
        init(customLatitude: CLLocationDegrees, customLongitude: CLLocationDegrees, customRadius: Double) {
            self.customLatitude = customLatitude
            self.customLongitude = customLongitude
            self.customRadius = customRadius
        }
    }
}
