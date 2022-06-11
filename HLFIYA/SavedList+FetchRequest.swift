//
//  SavedList+FetchRequest.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/10/22.
//

import CoreData

extension SavedList {
  static var allListsFetchRequest: NSFetchRequest<SavedList> {
      let request = SavedList.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedList.name, ascending: true)]

      return request
  }
}
