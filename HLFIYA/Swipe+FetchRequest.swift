//
//  Swipe+FetchRequest.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import CoreData

extension RightSwipe {
  static var allRightSwipesFetchRequest: NSFetchRequest<RightSwipe> {
      let request: NSFetchRequest<RightSwipe> = RightSwipe.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \RightSwipe.name, ascending: true)]

      return request
  }
}

extension LeftSwipe {
  static var allLeftSwipesFetchRequest: NSFetchRequest<LeftSwipe> {
      let request: NSFetchRequest<LeftSwipe> = LeftSwipe.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \LeftSwipe.name, ascending: true)]

      return request
  }
}
