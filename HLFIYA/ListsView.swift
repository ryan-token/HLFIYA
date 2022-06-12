//
//  ListsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct ListsView: View {
    @State private var isShowingCreateListSheet = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var savedLists: FetchedResults<SavedList>
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(savedLists, id: \.self) { list in
                        NavigationLink(destination: SavedRestaurantsView(list: list)) {
                            Text(list.wrappedName)
                        }
                        .isDetailLink(false)
                    }
                    .onDelete(perform: removeList)
                    
                    if (savedLists.isEmpty) {
                        Text("Create lists to easily save places for later")
                            .font(Font.system(.body, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: {
                    isShowingCreateListSheet.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus.square")
                            .foregroundColor(.green)
                        Text("Create List")
                            .foregroundColor(.green)
                            .font(Font.system(.headline, design: .rounded))
                    }
                }
            }
            
            .popover(isPresented: $isShowingCreateListSheet) {
                CreateListSheet()
            }
            
            .navigationTitle("Lists")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
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
