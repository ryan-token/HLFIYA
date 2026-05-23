//
//  SavedRestaurant+FetchRequest.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/10/22.
//

import CoreData

extension SavedRestaurant {
    static var allSavedRestaurantsFetchRequest: NSFetchRequest<SavedRestaurant> {
        let request = SavedRestaurant.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedRestaurant.name, ascending: true)]
        return request
    }
}
