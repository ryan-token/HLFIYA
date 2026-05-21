//
//  AddToListSection.swift
//  HLFIYA
//

import SwiftUI

struct AddToListSection: View {
    let savedLists: FetchedResults<SavedList>
    let onAddToList: (SavedList) -> Void
    let onCreateList: () -> Void

    var body: some View {
        Section("Add to List") {
            ForEach(savedLists) { list in
                Button {
                    onAddToList(list)
                } label: {
                    Text(list.wrappedName)
                }
                .accessibilityLabel("Add to \(list.wrappedName) list")
            }
            .foregroundStyle(.fuchsia)

            Button(action: onCreateList) {
                Label("Create List", systemImage: "plus.square.fill")
                    .font(.headline)
                    .foregroundStyle(.fuchsia)
            }
        }
    }
}
