//
//  Utils.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/14/22.
//

import CoreLocation
import Foundation
import os

/// File-backed caches for Yelp responses, filters, and review prompts.
///
/// Everything here is nonisolated and synchronous so it can be called from the
/// background fetches in `BusinessFetcher` as well as from the main actor.
nonisolated enum Utils {
    private static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "Cache")

    private static let businessesCacheName = "localYelpCache.json"
    private static let isOpenNowFilterCacheName = "isOpenNowFilterCache.txt"
    private static let categoriesFilterCacheName = "categoriesFilterCache.json"
    private static let pricesFilterCacheName = "pricesFilterCache.json"
    private static let locationFilterCacheName = "locationFilterCache.json"
    private static let lastReviewDateName = "lastReviewData.txt"

    static func convertMilesToMeters(miles: Double) -> Int {
        Int(Measurement(value: miles, unit: UnitLength.miles).converted(to: .meters).value.rounded())
    }

    // MARK: Yelp responses

    static func writeBusinessesCache(_ response: Businesses) {
        write(response, to: businessesCacheName)
    }

    static func getLocalYelpCache() -> [Business] {
        read(Businesses.self, from: businessesCacheName)?.businesses?.shuffled() ?? []
    }

    static func writeBusinessDetailsCache(_ details: BusinessDetails) {
        write(details, to: businessDetailsCacheName(for: details.id ?? "unknown"))
    }

    /// Returns the cached details for a business, or `nil` when nothing usable is cached.
    static func getLocalYelpCacheForBusiness(id: String) -> BusinessDetails? {
        guard let cached = read(BusinessDetails.self, from: businessDetailsCacheName(for: id)),
              cached.name?.isEmpty == false else { return nil }
        return cached
    }

    private static func businessDetailsCacheName(for id: String) -> String {
        "localYelpCacheForBusId-\(id).json"
    }

    // MARK: Filters

    static func writeIsOpenNowFilterToCache(onlyShowOpenNow: Bool) {
        writeString(onlyShowOpenNow ? "true" : "false", to: isOpenNowFilterCacheName)
    }

    static func getIsOpenNowFilterCache() -> Bool {
        readString(from: isOpenNowFilterCacheName) == "true"
    }

    static func writeCategoriesFilterToCache(categories: Set<String>, categoriesNames: String) {
        write(CategoriesFilter(categories: categories, categoriesNames: categoriesNames), to: categoriesFilterCacheName)
    }

    static func getCategoriesFilterCache() -> CategoriesFilter {
        read(CategoriesFilter.self, from: categoriesFilterCacheName)
            ?? CategoriesFilter(categories: [AllCategories.allFood], categoriesNames: "All Food")
    }

    static func writePricesFilterToCache(prices: Set<String>, priceName: String) {
        write(PricesFilter(prices: prices, priceName: priceName), to: pricesFilterCacheName)
    }

    static func getPricesFilterCache() -> PricesFilter {
        read(PricesFilter.self, from: pricesFilterCacheName)
            ?? PricesFilter(prices: [AllPrices.allPrices], priceName: AllPrices.allPrices)
    }

    static func writeLocationFilterToCache(
        customLatitude: CLLocationDegrees,
        customLongitude: CLLocationDegrees,
        customRadius: Double
    ) {
        let filter = LocationFilter(
            customLatitude: customLatitude,
            customLongitude: customLongitude,
            customRadius: customRadius
        )
        write(filter, to: locationFilterCacheName)
    }

    static func getLocationFilterCache() -> LocationFilter {
        read(LocationFilter.self, from: locationFilterCacheName)
            ?? LocationFilter(customLatitude: 0, customLongitude: 0, customRadius: 5)
    }

    // MARK: Review prompts

    static func writeReviewDateToDocumentsDir(date: Date) {
        writeString(date.formatted(.iso8601), to: lastReviewDateName)
    }

    /// The last time the app asked for a review, or `nil` if it never has.
    static func getLastReviewRequestDate() -> Date? {
        guard let string = readString(from: lastReviewDateName) else { return nil }
        return try? Date(string, strategy: .iso8601)
    }

    // MARK: Cache maintenance

    static func clearAnyCacheFilesOverAMonthOld() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date.now

        for fileURL in jsonCacheFiles(includingModificationDates: true) {
            let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey])
            guard let modificationDate = resourceValues?.contentModificationDate,
                  calendar.numberOfDaysBetween(modificationDate, and: now) > 30 else { continue }

            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                logFailure("remove stale cache \(fileURL.lastPathComponent)", error)
            }
        }
    }

    static func clearAllCacheFilesInDocumentsDir() {
        for fileURL in jsonCacheFiles(includingModificationDates: false) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                logFailure("remove cache \(fileURL.lastPathComponent)", error)
            }
        }
    }

    private static func jsonCacheFiles(includingModificationDates: Bool) -> [URL] {
        do {
            return try FileManager.default.contentsOfDirectory(
                at: .documentsDirectory,
                includingPropertiesForKeys: includingModificationDates ? [.contentModificationDateKey] : nil,
                options: .skipsHiddenFiles
            )
            .filter { $0.pathExtension == "json" }
        } catch {
            logFailure("list the documents directory", error)
            return []
        }
    }

    // MARK: File helpers

    private static func logFailure(_ action: String, _ error: any Error) {
        logger.error("Failed to \(action, privacy: .public): \(error.localizedDescription, privacy: .public)")
    }

    private static func url(for fileName: String) -> URL {
        URL.documentsDirectory.appending(path: fileName)
    }

    private static func write(_ value: some Encodable, to fileName: String) {
        do {
            let data = try JSONEncoder.yelp.encode(value)
            try data.write(to: url(for: fileName), options: .atomic)
        } catch {
            logFailure("write \(fileName)", error)
        }
    }

    private static func read<Value: Decodable>(_ type: Value.Type, from fileName: String) -> Value? {
        let fileURL = url(for: fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return nil }

        do {
            return try JSONDecoder.yelp.decode(type, from: Data(contentsOf: fileURL))
        } catch {
            logFailure("read \(fileName)", error)
            return nil
        }
    }

    private static func writeString(_ string: String, to fileName: String) {
        do {
            try string.write(to: url(for: fileName), atomically: true, encoding: .utf8)
        } catch {
            logFailure("write \(fileName)", error)
        }
    }

    private static func readString(from fileName: String) -> String? {
        try? String(contentsOf: url(for: fileName), encoding: .utf8)
    }

    // MARK: Cached filter shapes

    struct CategoriesFilter: Codable {
        var categories: Set<String>
        var categoriesNames: String
    }

    struct PricesFilter: Codable {
        var prices: Set<String>
        var priceName: String
    }

    struct LocationFilter: Codable {
        var customLatitude: CLLocationDegrees
        var customLongitude: CLLocationDegrees
        var customRadius: Double
    }
}
