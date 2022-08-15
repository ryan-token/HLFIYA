//
//  SwipesView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import SwiftUI
import CloudKit

struct SwipesStatsView: View {
    @FetchRequest(fetchRequest: RightSwipe.allRightSwipesFetchRequest, animation: .default)
    var rightSwipes: FetchedResults<RightSwipe>
    
    @FetchRequest(fetchRequest: LeftSwipe.allLeftSwipesFetchRequest, animation: .default)
    var leftSwipes: FetchedResults<LeftSwipe>
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    
    let containers: [CKContainer] = [
        CKContainer.default(),
        .init(identifier: "iCloud.com.ryantoken.HLFIYA")
    ]
    
    var body: some View {
        List {
            Section(header: Text("Top 5 Right Swipes").font(.callout).foregroundColor(.gray)) {
                ForEach(formattedRightSwipes().prefix(5), id: \.key) { business, count in
                    Text("\(business.trimmingCharacters(in: .whitespacesAndNewlines)): \(count)")
                }
            }
            
            Section(header: Text("Top 5 Left Swipes").font(.callout).foregroundColor(.gray)) {
                ForEach(formattedLeftSwipes().prefix(5), id: \.key) { business, count in
                    Text("\(business.trimmingCharacters(in: .whitespacesAndNewlines)): \(count)")
                }
            }
            
            if !leftSwipes.isEmpty || !rightSwipes.isEmpty {
                Section(header: Text("Clear Data").font(.callout).foregroundColor(.gray)) {
                    Text("Your swipes data is stored in iCloud so it can sync across your devices. I do not store this data (or any other data) on my servers. If you'd like to clear this data from iCloud, you can do so by tapping the button below.")
                        .foregroundColor(.primary)
                    
                    Button {
                        deleteCloudKitData()
                    } label: {
                        Text("Clear Swipes Data")
                            .padding()
                            .font(Font.system(.headline, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color(UIColor(named: "fuchsia")!.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))) : Color.white)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(colorScheme == .dark ? Color.white : Color.black)
                    .clipShape(Capsule())
                    .padding()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .font(Font.system(.body, design: .rounded))
            }
        }
        .font(Font.system(.body, design: .rounded))
        
        .navigationTitle("Swipe Stats")
    }
    
    func formattedRightSwipes() -> [Dictionary<String, Int>.Element] {
        var businessDictionary = [String:Int]()
        
        for business in rightSwipes {
            let keyExists = businessDictionary[business.wrappedName] != nil
            
            if keyExists {
                businessDictionary.updateValue(businessDictionary[business.wrappedName]!+1, forKey: business.wrappedName)
            } else {
                businessDictionary[business.wrappedName] = 1
            }
        }
        
        let sortedDictionary = businessDictionary.sorted{
            return ($0.value, $1.key) > ($1.value, $0.key)
        }
        
        return sortedDictionary
    }
    
    func formattedLeftSwipes() -> [Dictionary<String, Int>.Element] {
        var businessDictionary = [String:Int]()
        
        for business in leftSwipes {
            let keyExists = businessDictionary[business.wrappedName] != nil
            
            if keyExists {
                businessDictionary.updateValue(businessDictionary[business.wrappedName]!+1, forKey: business.wrappedName)
            } else {
                businessDictionary[business.wrappedName] = 1
            }
        }
        
        let sortedDictionary = businessDictionary.sorted{
            return ($0.value, $1.key) > ($1.value, $0.key)
        }
        
        return sortedDictionary
    }
    
    func deleteCloudKitData() {
        for leftSwipe in leftSwipes {
            moc.delete(leftSwipe)
        }
        
        for rightSwipe in rightSwipes {
            moc.delete(rightSwipe)
        }
        
        try? moc.save()
        
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
    }
}

struct SwipesStatsView_Previews: PreviewProvider {
    static var previews: some View {
        SwipesStatsView()
    }
}
