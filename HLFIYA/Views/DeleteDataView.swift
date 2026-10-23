//
//  DeleteDataView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/23/22.
//

import CloudKit
import CoreData
import os
import SwiftUI

/// Clears cached Yelp data, or deletes all swipes and lists locally and from iCloud.
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

    private static let containerIdentifiers = ["iCloud.com.ryantoken.HLFIYA"]
    private nonisolated static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "DeleteData")

    var body: some View {
        List {
            Section {
                LabeledContent("Total Swipes", value: leftSwipes.count + rightSwipes.count, format: .number)
                LabeledContent("Number of Lists", value: savedLists.count, format: .number)
            }

            Section {
                Button("Clear Cached Yelp Data") {
                    isShowingClearCachesAlert = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            } footer: {
                Text(
                    """
                    We cache Yelp data to improve the app. Cached data is intermittently refreshed, \
                    but you can manually clear the cached data here.
                    """
                )
            }

            Section {
                Button("Delete All Saved Data", role: .destructive) {
                    isShowingDeleteAlert = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(!hasSavedData)
            } footer: {
                Text(
                    """
                    Your swipes data and all of your saved Lists are stored in iCloud so they can sync across \
                    your devices. You can delete all saved data from your device and from iCloud by tapping below.
                    """
                )
            }
        }
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .navigationTitle("Delete Data")
        .alert("This will clear all cached data received from the Yelp API.", isPresented: $isShowingClearCachesAlert) {
            Button("Clear Caches", role: .destructive) {
                Utils.clearAllCacheFilesInDocumentsDir()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Proceed if you're seeing stale Yelp data.")
        }
        .alert(
            "This will permanently delete all of your swipes data and all of your Lists.",
            isPresented: $isShowingDeleteAlert
        ) {
            Button("Delete All Saved Data", role: .destructive) {
                Task { await deleteAllLocalAndCloudKitData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to do this?")
        }
    }

    private var hasSavedData: Bool {
        !leftSwipes.isEmpty || !rightSwipes.isEmpty || !savedLists.isEmpty
    }

    private func deleteAllLocalAndCloudKitData() async {
        Utils.clearAllCacheFilesInDocumentsDir()

        // Snapshot the results before deleting, so we aren't iterating a collection
        // that the fetched results controller is mutating in response to delete().
        let objects: [NSManagedObject] = Array(leftSwipes) + Array(rightSwipes) + Array(savedLists)
        for object in objects {
            moc.delete(object)
        }

        do {
            try moc.save()
        } catch {
            Self.logger.error("Failed to save Core Data deletions: \(error.localizedDescription, privacy: .public)")
        }

        let containers = [CKContainer.default()] + Self.containerIdentifiers.map(CKContainer.init(identifier:))
        await withTaskGroup { group in
            for container in containers {
                group.addTask {
                    await Self.deleteAllZones(in: container)
                }
            }
        }
    }

    private nonisolated static func deleteAllZones(in container: CKContainer) async {
        do {
            let database = container.privateCloudDatabase
            let zoneIDs = try await database.allRecordZones().map(\.zoneID)
            guard !zoneIDs.isEmpty else { return }
            _ = try await database.modifyRecordZones(saving: [], deleting: zoneIDs)
        } catch {
            let containerName = container.containerIdentifier ?? "default"
            let reason = error.localizedDescription
            logger.error("Failed to delete zones in \(containerName, privacy: .public): \(reason, privacy: .public)")
        }
    }
}

#Preview {
    NavigationStack {
        DeleteDataView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
