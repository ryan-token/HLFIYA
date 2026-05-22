//
//  SwipesView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import SwiftUI

struct SwipesStatsView: View {
    @FetchRequest(fetchRequest: RightSwipe.allRightSwipesFetchRequest, animation: .default)
    private var rightSwipes: FetchedResults<RightSwipe>

    @FetchRequest(fetchRequest: LeftSwipe.allLeftSwipesFetchRequest, animation: .default)
    private var leftSwipes: FetchedResults<LeftSwipe>

    var body: some View {
        Group {
            if leftSwipes.isEmpty && rightSwipes.isEmpty {
                ContentUnavailableView(
                    "No swipes yet",
                    systemImage: "hand.draw",
                    description: Text("Use the app for a bit, then come back 🙂")
                )
            } else {
                List {
                    Section("Top 5 Right Swipes") {
                        ForEach(topSwipes(from: rightSwipes.map(\.wrappedName)), id: \.key) { business, count in
                            Text("\(business.trimmingCharacters(in: .whitespacesAndNewlines)): \(count)")
                        }
                    }

                    Section("Top 5 Left Swipes") {
                        ForEach(topSwipes(from: leftSwipes.map(\.wrappedName)), id: \.key) { business, count in
                            Text("\(business.trimmingCharacters(in: .whitespacesAndNewlines)): \(count)")
                        }
                    }
                }
            }
        }
        .navigationTitle("Swipe Stats")
    }

    private func topSwipes(from names: [String]) -> [(key: String, value: Int)] {
        Dictionary(grouping: names, by: { $0 })
            .mapValues(\.count)
            .sorted { ($0.value, $1.key) > ($1.value, $0.key) }
            .prefix(5)
            .map { (key: $0.key, value: $0.value) }
    }
}

#Preview {
    NavigationStack { SwipesStatsView() }
}
