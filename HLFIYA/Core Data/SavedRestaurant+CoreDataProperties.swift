//
//  SavedRestaurant+CoreDataProperties.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/10/22.
//
//

import Foundation
import CoreData


extension SavedRestaurant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedRestaurant> {
        return NSFetchRequest<SavedRestaurant>(entityName: "SavedRestaurant")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var lists: NSSet?

    public var wrappedId: String {
        return id ?? "Unknown"
    }

    public var wrappedName: String {
        return name ?? "Unknown"
    }
    
    public var listsArray: [SavedList] {
        let set = lists as? Set<SavedList> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
}

// MARK: Generated accessors for lists
extension SavedRestaurant {

    @objc(addListsObject:)
    @NSManaged public func addToLists(_ value: SavedList)

    @objc(removeListsObject:)
    @NSManaged public func removeFromLists(_ value: SavedList)

    @objc(addLists:)
    @NSManaged public func addToLists(_ values: NSSet)

    @objc(removeLists:)
    @NSManaged public func removeFromLists(_ values: NSSet)

}

extension SavedRestaurant : Identifiable {

}
