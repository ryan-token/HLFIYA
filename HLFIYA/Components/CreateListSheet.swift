//
//  CreateListSheet.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct CreateListSheet: View {
    @FocusState private var listNameInFocus: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc

    @State private var listName = ""

    var body: some View {
        NavigationStack {
            VStack {
                TextField("List Name", text: $listName)
                    .focused($listNameInFocus)
                    .textInputAutocapitalization(.words)
                    .font(.largeTitle)
                    .padding()
                    .background(Color(.systemGray5))
                    .clipShape(.rect(cornerRadius: 15))
            }
            .padding()
            .navigationTitle("Create New List")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                        .font(.headline)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save)
                        .font(.headline)
                }
            }
        }
        .tint(.fuchsia)
        .task {
            try? await Task.sleep(for: .milliseconds(750))
            listNameInFocus = true
        }
    }

    private func save() {
        if !listName.isEmpty {
            let newList = SavedList(context: moc)
            newList.name = listName
            try? moc.save()
        }
        dismiss()
    }
}

#Preview {
    CreateListSheet()
}
