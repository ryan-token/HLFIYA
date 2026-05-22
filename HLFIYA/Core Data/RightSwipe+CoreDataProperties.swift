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
        NSFetchRequest<RightSwipe>(entityName: "RightSwipe")
    }

    @NSManaged public var name: String?
    @NSManaged public var uuid: UUID?

    public var wrappedName: String {
        name ?? "Unknown"
    }
}

extension RightSwipe: Identifiable {}
