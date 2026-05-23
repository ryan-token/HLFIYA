//
//  DeleteDataView.swift
//  HLFIYA
//
//  Created by Ryan Token on 8/15/22.
//

import SwiftUI
import CloudKit

struct DeleteDataView: View {
    @State private var isShowingClearCachesAlert = false
    @State private var isShowingDeleteAlert = false

    @FetchRequest(fetchRequest: RightSwipe.allRightSwipesFetchRequest, animation: .default)
    private var rightSwipes: FetchedResults<RightSwipe>

    @FetchRequest(fetchRequest: LeftSwipe.allLeftSwipesFetchRequest, animation: .default)
    private var leftSwipes: FetchedResults<LeftSwipe>

    @FetchRequest(fetchRequest: SavedList.allListsFetchRequest, animation: .default)
    private var savedLists: FetchedResults<SavedList>

    @Environment(\.managedObjectContext) private var moc

    private let containers: [CKContainer] = [
        CKContainer.default(),
        CKContainer(identifier: "iCloud.com.ryantoken.HLFIYA")
    ]

    var body: some View {
        Group {
            if hasAnyData {
                List {
                    Text("Total Swipes: \(totalSwipes)")
                    Text("Number of Lists: \(savedLists.count)")

                    Section {
                        Text("We cache Yelp data to improve the app. Cached data is intermittently refreshed, but you can manually clear the cached data here.")
                            .foregroundStyle(.gray)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                        Button {
                            isShowingClearCachesAlert = true
                        } label: {
                            Text("Clear Cached Yelp Data")
                                .padding()
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.orange)
                        .clipShape(.capsule)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    Section {
                        Text("Your swipes data and all of your saved Lists are stored in iCloud so they can sync across your devices. You can delete all saved data from your device and from iCloud by tapping below.")
                            .foregroundStyle(.gray)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                        Button {
                            isShowingDeleteAlert = true
                        } label: {
                            Text("Delete All Saved Data")
                                .padding()
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.pink)
                        .clipShape(.capsule)
                        .padding()
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Data Yet",
                    systemImage: "tray",
                    description: Text("Use the app for a bit, then come back 🙂")
                )
            }
        }
        .navigationTitle("Delete Data")
        .alert("This will clear all cached data received from the Yelp API.", isPresented: $isShowingClearCachesAlert) {
            Button("Clear Caches", role: .destructive) {
                Utils.clearAllCacheFilesInDocumentsDir()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Proceed if you're seeing stale Yelp data.")
        }
        .alert("This will permanently delete all of your swipes data and all of your Lists.", isPresented: $isShowingDeleteAlert) {
            Button("Delete All Saved Data", role: .destructive) {
                Task { await deleteAllLocalAndCloudKitData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to do this?")
        }
    }

    private var hasAnyData: Bool {
        !leftSwipes.isEmpty || !rightSwipes.isEmpty || !savedLists.isEmpty
    }

    private var totalSwipes: Int {
        leftSwipes.count + rightSwipes.count
    }

    private func deleteAllLocalAndCloudKitData() async {
        Utils.clearAllCacheFilesInDocumentsDir()

        // Snapshot FetchedResults before deleting so we aren't iterating a
        // collection that the controller is mutating in response to .delete().
        let leftSwipesToDelete = Array(leftSwipes)
        let rightSwipesToDelete = Array(rightSwipes)
        let listsToDelete = Array(savedLists)

        for leftSwipe in leftSwipesToDelete { moc.delete(leftSwipe) }
        for rightSwipe in rightSwipesToDelete { moc.delete(rightSwipe) }
        for savedList in listsToDelete { moc.delete(savedList) }

        do {
            try moc.save()
        } catch {
            print("Failed to save Core Data deletions: \(error)")
        }

        await withTaskGroup(of: Void.self) { group in
            for container in containers {
                group.addTask {
                    await Self.deleteAllZones(in: container)
                }
            }
        }
    }

    private static func deleteAllZones(in container: CKContainer) async {
        do {
            let database = container.privateCloudDatabase
            let zones = try await database.allRecordZones()
            let zoneIDs = zones.map(\.zoneID)
            guard !zoneIDs.isEmpty else { return }
            _ = try await database.modifyRecordZones(saving: [], deleting: zoneIDs)
        } catch {
            print("Failed to delete CloudKit zones in \(container.containerIdentifier ?? "default"): \(error)")
        }
    }
}

#Preview {
    NavigationStack { DeleteDataView() }
}
