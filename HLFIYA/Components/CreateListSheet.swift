//
//  CreateListSheet.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct CreateListSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @State private var listName = String()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("List Name", text: $listName)
                    .font(Font.system(.largeTitle, design: .rounded))
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding()
            
            .navigationTitle("Create New List")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if (!listName.isEmpty) {
                            let newList = SavedList(context: moc)
                            newList.name = listName

                            try? moc.save()
                        }
                        
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CreateListSheet_Previews: PreviewProvider {
    static var previews: some View {
        CreateListSheet()
    }
}
