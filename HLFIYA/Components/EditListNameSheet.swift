//
//  EditListNameSheet.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/15/23.
//

import SwiftUI

struct EditListNameSheet: View {
    let list: SavedList
    @FocusState private var listNameInFocus: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @State private var newListName = String()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Update your \(list.name ?? "") list")
                    .foregroundColor(.gray)
                    .font(Font.system(.headline, design: .rounded))
                Spacer()
                TextField("New list name", text: $newListName)
                    .focused($listNameInFocus)
                    .textInputAutocapitalization(.words)
                    .font(Font.system(.largeTitle, design: .rounded))
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                Spacer()
            }
            .padding()
            
            .navigationTitle("Change List Name")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(Font.system(.headline, design: .rounded))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if (!newListName.isEmpty) {
                            list.name = newListName

                            try? moc.save()
                        }
                        
                        dismiss()
                    }
                    .font(Font.system(.headline, design: .rounded))
                }
            }
        }
        .accentColor(Color(UIColor(named: "fuchsia")!))
        
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                listNameInFocus = true
              }
        }
    }
}
