//
//  RightSwipe+CoreDataProperties.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/10/22.
//
//

import Foundation
import CoreData


extension RightSwipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RightSwipe> {
        return NSFetchRequest<RightSwipe>(entityName: "RightSwipe")
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

extension RightSwipe : Identifiable {

}
