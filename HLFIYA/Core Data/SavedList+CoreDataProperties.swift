//
//  SavedList+CoreDataProperties.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/10/22.
//
//

import Foundation
import CoreData


extension SavedList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedList> {
        return NSFetchRequest<SavedList>(entityName: "SavedList")
    }

    @NSManaged public var name: String?
    @NSManaged public var restaurants: NSSet?

    public var wrappedName: String {
        return name ?? "Unknown"
    }
    
    public var restaurantsArray: [SavedRestaurant] {
        let set = restaurants as? Set<SavedRestaurant> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
}

// MARK: Generated accessors for restaurants
extension SavedList {

    @objc(addRestaurantsObject:)
    @NSManaged public func addToRestaurants(_ value: SavedRestaurant)

    @objc(removeRestaurantsObject:)
    @NSManaged public func removeFromRestaurants(_ value: SavedRestaurant)

    @objc(addRestaurants:)
    @NSManaged public func addToRestaurants(_ values: NSSet)

    @objc(removeRestaurants:)
    @NSManaged public func removeFromRestaurants(_ values: NSSet)

}

extension SavedList : Identifiable {

}
