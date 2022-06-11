//
//  Swipe+FetchRequest.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import CoreData

extension RightSwipe {
  static var allRightSwipesFetchRequest: NSFetchRequest<RightSwipe> {
      let request = RightSwipe.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \RightSwipe.name, ascending: true)]

      return request
  }
}

extension LeftSwipe {
  static var allLeftSwipesFetchRequest: NSFetchRequest<LeftSwipe> {
      let request = LeftSwipe.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \LeftSwipe.name, ascending: true)]

      return request
  }
}
