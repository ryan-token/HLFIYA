//
//  SwipesStatsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/14/22.
//

import CoreData
import SwiftUI

/// The places the person has swiped on most, in each direction.
struct SwipesStatsView: View {
    @FetchRequest(fetchRequest: RightSwipe.allRightSwipesFetchRequest, animation: .default)
    private var rightSwipes: FetchedResults<RightSwipe>

    @FetchRequest(fetchRequest: LeftSwipe.allLeftSwipesFetchRequest, animation: .default)
    private var leftSwipes: FetchedResults<LeftSwipe>

    // Tallying every swipe is proportional to the swipe history, so it's done
    // only when the counts change rather than on every body evaluation.
    @State private var topRightSwipes: [SwipeTally] = []
    @State private var topLeftSwipes: [SwipeTally] = []

    var body: some View {
        List {
            Section("Top 5 Right Swipes") {
                ForEach(topRightSwipes) { tally in
                    LabeledContent(tally.name, value: tally.count, format: .number)
                }
            }

            Section("Top 5 Left Swipes") {
                ForEach(topLeftSwipes) { tally in
                    LabeledContent(tally.name, value: tally.count, format: .number)
                }
            }
        }
        .overlay {
            if leftSwipes.isEmpty && rightSwipes.isEmpty {
                ContentUnavailableView(
                    "No Swipes Yet",
                    systemImage: "hand.draw",
                    description: Text("Use the app for a bit, then come back 🙂")
                )
            }
        }
        .navigationTitle("Swipe Stats")
        .onChange(of: rightSwipes.count, initial: true) {
            topRightSwipes = SwipeTally.top(5, from: rightSwipes.map(\.wrappedName))
        }
        .onChange(of: leftSwipes.count, initial: true) {
            topLeftSwipes = SwipeTally.top(5, from: leftSwipes.map(\.wrappedName))
        }
    }
}

#Preview {
    NavigationStack {
        SwipesStatsView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
