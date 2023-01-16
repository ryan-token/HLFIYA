//
//  SavedRestaurantsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct SavedRestaurantsView: View {
    let list: SavedList
    
    @State private var isShowingUpdateListNameAlertForiOS16 = false
    @State private var isShowingUpdateListNameSheetForiOS15 = false
    @State private var newListName = ""
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var savedRestaurants: FetchedResults<SavedRestaurant>
    
    var body: some View {
        List {
            if (list.restaurantsArray.isEmpty) {
                Text("No places added to your \(list.wrappedName) list. Swipe right on a card to add some!")
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
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
        
        
        Button(action: {
            if #available(iOS 16, *) {
                isShowingUpdateListNameAlertForiOS16 = true
            } else {
                isShowingUpdateListNameSheetForiOS15 = true
            }
        }) {
            HStack {
                Image(systemName: "pencil")
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                Text("Change List Name")
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
            }
        }
        .font(Font.system(.headline, design: .rounded))
        
        .alert("Change List Name", isPresented: $isShowingUpdateListNameAlertForiOS16) {
            TextField("New List Name", text: $newListName)
                .textInputAutocapitalization(.words)
            Button(action: { updateListNameViaAlert(list: list) }) {
                Text("Change List Name")
            }
            Button("Cancel", role: .cancel) { newListName = "" }
        }
        .font(Font.system(.body, design: .rounded))
        
        .popover(isPresented: $isShowingUpdateListNameSheetForiOS15) {
            EditListNameSheet(list: list)
        }
        
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
    
    func updateListNameViaAlert(list: SavedList) {
        if newListName != "" {
            list.name = newListName

            do {
                try moc.save()
            }
            catch {
                print("Error saving moc: \(error)")
            }
        }
        
        // set the initial test name back to empty when the alert appears
        newListName = ""
    }
}

//struct SavedRestaurantsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedRestaurantsView()
//    }
//}
