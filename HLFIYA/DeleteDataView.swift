//
//  DeleteDataView.swift
//  HLFIYA
//
//  Created by Ryan Token on 8/15/22.
//

import SwiftUI
import CloudKit

struct DeleteDataView: View {
    @State private var isShowingDeleteAlert = false
    
    @FetchRequest(fetchRequest: RightSwipe.allRightSwipesFetchRequest, animation: .default)
    var rightSwipes: FetchedResults<RightSwipe>
    
    @FetchRequest(fetchRequest: LeftSwipe.allLeftSwipesFetchRequest, animation: .default)
    var leftSwipes: FetchedResults<LeftSwipe>
    
    @FetchRequest(fetchRequest: SavedList.allListsFetchRequest, animation: .default)
    var savedLists: FetchedResults<SavedList>
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    
    let containers: [CKContainer] = [
        CKContainer.default(),
        .init(identifier: "iCloud.com.ryantoken.HLFIYA")
    ]
    
    var body: some View {
        List {
            if !leftSwipes.isEmpty || !rightSwipes.isEmpty || !savedLists.isEmpty {
                Text("Total Swipes: \(getTotalSwipes())")
                Text("Number of Lists: \(savedLists.count)")
                
                Section {
                    Text("Your swipes data and all of your saved Lists are stored in iCloud so it can sync across your devices. I do not store this data (or any other data) on my servers. If you'd like to delete this data from both your device and from iCloud, tap the button below.")
                        .foregroundColor(.gray)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    
                    Button {
                        isShowingDeleteAlert = true
                    } label: {
                        Text("Delete All Saved Data")
                            .padding()
                            .font(Font.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(Color.pink)
                    .clipShape(Capsule())
                    .padding()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } else {
                Text("No data to delete! Use the app for a bit, then come back 🙂")
                    .foregroundColor(.gray)
            }
        }
        .font(Font.system(.body, design: .rounded))
        
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(
                title: Text("This will permanently delete all of your swipes data and all of your Lists."),
                message: Text("Are you sure you want to do this?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteAllLocalAndCloudKitData()
                },
                secondaryButton: .cancel()
            )
        }
        
        .navigationTitle("Delete Data")
    }
    
    func deleteAllLocalAndCloudKitData() {
        for leftSwipe in leftSwipes {
            moc.delete(leftSwipe)
        }
        
        for rightSwipe in rightSwipes {
            moc.delete(rightSwipe)
        }
        
        for savedList in savedLists {
            moc.delete(savedList)
        }
        
        for container in containers {
            container.privateCloudDatabase.fetchAllRecordZones { zones, error in
                guard let zones = zones, error == nil else {
                    print("Error fetching zones.")
                    return
                }
                
                let zoneIDs = zones.map { $0.zoneID }
                let deletionOperation = CKModifyRecordZonesOperation(recordZonesToSave: nil, recordZoneIDsToDelete: zoneIDs)
                
                deletionOperation.modifyRecordZonesResultBlock = { result in
                    print("deletion result: \(result)")
                }
                
                container.privateCloudDatabase.add(deletionOperation)
            }
        }
        
        try? moc.save()
    }
    
    func getTotalSwipes() -> Int {
        let numberOfLeftSwipes = leftSwipes.count
        let numberOfRightSwipes = rightSwipes.count
        let totalSwipes = numberOfLeftSwipes + numberOfRightSwipes
        return totalSwipes
    }
}

struct DeleteDataView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteDataView()
    }
}
