//
//  ListsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct ListsView: View {
    @State private var isShowingCreateListSheet = false
    @State private var editMode = EditMode.inactive
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var savedLists: FetchedResults<SavedList>
    
    var body: some View {
        NavigationView {
			ZStack {
				List {
					ForEach(savedLists, id: \.self) { list in
						NavigationLink(destination: SavedRestaurantsView(list: list)) {
							Text(list.wrappedName)
						}
						.isDetailLink(false)
					}
					.onDelete(perform: removeList)

					if (savedLists.isEmpty) {
						Text("Create lists to easily save places for later.")
							.foregroundColor(.gray)
					}
				}
				.font(Font.system(.body, design: .rounded))
				.safeAreaInset(edge: .bottom) {
					Color.clear.frame(height: 5)
				}

				VStack {
					Spacer()

					GlassButton {
						isShowingCreateListSheet.toggle()
					} label: {
						HStack {
							Image(systemName: "plus.square.fill")
								.foregroundColor(Color(UIColor(named: "fuchsia")!))
							Text("Create List")
								.foregroundColor(Color(UIColor(named: "fuchsia")!))
						}
					}
					.font(Font.system(.headline, design: .rounded))
				}
			}
            .environment(\.editMode, $editMode)
            
            .popover(isPresented: $isShowingCreateListSheet) {
                CreateListSheet()
            }
            
            .navigationTitle("Lists")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(Font.system(.headline, design: .rounded))
                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(Color(UIColor(named: "fuchsia")!))
    }
    
    func removeList(at offsets: IndexSet) {
        for index in offsets {
            let list = savedLists[index]
            moc.delete(list)
        }
        
        do {
            try moc.save()
        } catch {
            print("Error deleting the list")
        }
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView()
    }
}
