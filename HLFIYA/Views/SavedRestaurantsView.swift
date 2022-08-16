//
//  SavedRestaurantsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct SavedRestaurantsView: View {
    let list: SavedList
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var savedRestaurants: FetchedResults<SavedRestaurant>
    
    var body: some View {
        List {
            if (list.restaurantsArray.isEmpty) {
                Text("No places added to your \(list.wrappedName) list. Swipe right on a card to add some!")
                    .foregroundColor(.gray)
            }
            
            ForEach(list.restaurantsArray) { restaurant in
                NavigationLink(destination: SavedRestaurantsDetailsView(restaurantId: restaurant.wrappedId)) {
                    Text(restaurant.wrappedName)
                }
            }
            .onDelete(perform: { offsets in
                removeRestaurantFromList(at: offsets, from: list)
            })
        }
        .font(Font.system(.body, design: .rounded))
        
        .navigationTitle(list.wrappedName)
    }
    
    func removeRestaurantFromList(at offsets: IndexSet, from list: SavedList) {
        for index in offsets.sorted() {
            let restaurantToDelete = list.restaurantsArray[index]
            list.removeFromRestaurants(restaurantToDelete)
            moc.delete(restaurantToDelete)
        }
        
        if moc.hasChanges {
            try? moc.save()
        }
    }
}

//struct SavedRestaurantsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedRestaurantsView()
//    }
//}
