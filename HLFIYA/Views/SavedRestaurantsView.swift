//
//  SavedRestaurantsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct SavedRestaurantsView: View {
    let list: SavedList
    
    @State private var isShowingUpdateListNameAlert = false
    @State private var newListName = ""
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var savedRestaurants: FetchedResults<SavedRestaurant>
    
    var body: some View {
        ZStack {
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
			.safeAreaInset(edge: .bottom) {
				Color.clear.frame(height: 20)
			}

			VStack {
				Spacer()
				GlassButton {
					isShowingUpdateListNameAlert = true
				} label: {
					HStack {
						Image(systemName: "pencil")
							.foregroundColor(Color(UIColor(named: "fuchsia")!))
						Text("Change List Name")
							.foregroundColor(Color(UIColor(named: "fuchsia")!))
					}
					.padding(10)
				}
				.font(Font.system(.headline, design: .rounded))
			}
        }
		.onAppear {
			newListName = list.name ?? ""
		}

        .alert("Change List Name", isPresented: $isShowingUpdateListNameAlert) {
            TextField("New List Name", text: $newListName)
                .textInputAutocapitalization(.words)
            Button(action: { updateListNameViaAlert(list: list) }) {
                Text("Change List Name")
            }
            Button("Cancel", role: .cancel) {}
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
    
    func updateListNameViaAlert(list: SavedList) {
		if !newListName.isEmpty {
			list.name = newListName

			do {
				try moc.save()
			} catch {
				print("Error saving moc: \(error)")
			}
        }
    }
}

//struct SavedRestaurantsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedRestaurantsView()
//    }
//}
