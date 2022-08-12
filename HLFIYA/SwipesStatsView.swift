//
//  SwipesView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import SwiftUI

struct SwipesStatsView: View {
    @FetchRequest(fetchRequest: RightSwipe.allRightSwipesFetchRequest, animation: .default)
    var rightSwipes: FetchedResults<RightSwipe>
    
    @FetchRequest(fetchRequest: LeftSwipe.allLeftSwipesFetchRequest, animation: .default)
    var leftSwipes: FetchedResults<LeftSwipe>
    
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
        }
        .font(Font.system(.body, design: .rounded))
        // .listStyle(.sidebar)
        
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
}

struct SwipesStatsView_Previews: PreviewProvider {
    static var previews: some View {
        SwipesStatsView()
    }
}
