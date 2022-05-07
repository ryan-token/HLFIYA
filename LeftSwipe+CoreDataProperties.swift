//
//  LeftSwipe+CoreDataProperties.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//
//

import Foundation
import CoreData


extension LeftSwipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LeftSwipe> {
        return NSFetchRequest<LeftSwipe>(entityName: "LeftSwipe")
    }

    @NSManaged public var name: String?
    @NSManaged public var uuid: UUID?

    public var wrappedName: String {
        return name ?? "Unknown"
    }

    public var wrappedUuid: UUID {
        return uuid ?? UUID()
    }
}

extension LeftSwipe : Identifiable {

}
