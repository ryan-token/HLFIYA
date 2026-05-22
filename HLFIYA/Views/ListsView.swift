//
//  ListsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct ListsView: View {
    @State private var isShowingCreateListSheet = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(fetchRequest: SavedList.allListsFetchRequest, animation: .default)
    private var savedLists: FetchedResults<SavedList>

    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if savedLists.isEmpty {
                        ContentUnavailableView(
                            "No Lists Yet",
                            systemImage: "list.bullet.rectangle",
                            description: Text("Create lists to easily save places for later.")
                        )
                    } else {
                        List {
                            ForEach(savedLists, id: \.self) { list in
                                NavigationLink {
                                    SavedRestaurantsView(list: list)
                                } label: {
                                    Text(list.wrappedName)
                                }
                            }
                            .onDelete(perform: removeList)
                        }
                        .safeAreaInset(edge: .bottom) {
                            Color.clear.frame(height: 20)
                        }
                    }
                }

                VStack {
                    Spacer()

                    GlassButton(action: { isShowingCreateListSheet.toggle() }) {
                        Label("Create List", systemImage: "plus.square.fill")
                            .foregroundStyle(.fuchsia)
                            .padding(10)
                    }
                    .font(.headline)
                }
            }
            .popover(isPresented: $isShowingCreateListSheet) {
                CreateListSheet()
            }
            .navigationTitle("Lists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", action: dismiss.callAsFunction)
                        .font(.headline)
                }
            }
        }
        .tint(.fuchsia)
    }

    private func removeList(at offsets: IndexSet) {
        for index in offsets {
            moc.delete(savedLists[index])
        }
        try? moc.save()
    }
}

#Preview {
    ListsView()
}
