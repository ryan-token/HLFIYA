//
//  CategorySelection.swift
//  HLFIYA
//

import Foundation

/// An editable set of selected Yelp categories, enforcing the "All Food" rules.
///
/// "All Food" is selected on its own whenever nothing else is selected, whenever
/// every specific category is selected, or when the person chooses it explicitly.
nonisolated struct CategorySelection: Equatable {
    private(set) var categories: Set<String>

    init(categories: Set<String> = [AllCategories.allFood]) {
        self.categories = categories.isEmpty ? [AllCategories.allFood] : categories
    }

    /// Whether a category is selected; setting it applies the selection rules.
    subscript(isSelected category: String) -> Bool {
        get { categories.contains(category) }
        set {
            guard newValue != categories.contains(category) else { return }
            toggle(category)
        }
    }

    /// The user-facing summary, such as "Pizza" or "Pizza and 2 More".
    var summary: String {
        let ordered = AllCategories.sortedInDisplayOrder(categories)
        guard let first = ordered.first else { return AllCategories.displayName(for: AllCategories.allFood) }
        let firstName = AllCategories.displayName(for: first)
        return ordered.count == 1 ? firstName : "\(firstName) and \(ordered.count - 1) More"
    }

    mutating func toggle(_ category: String) {
        if categories.contains(category) {
            categories.remove(category)
        } else {
            categories.insert(category)
        }

        if category == AllCategories.allFood || categories.isEmpty {
            categories = [AllCategories.allFood]
        } else {
            categories.remove(AllCategories.allFood)
            // Selecting every specific category is the same as "All Food".
            if categories.count == AllCategories.yelpCategories.count - 1 {
                categories = [AllCategories.allFood]
            }
        }
    }

    mutating func reset() {
        categories = [AllCategories.allFood]
    }
}
