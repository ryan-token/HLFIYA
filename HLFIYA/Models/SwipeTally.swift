//
//  SwipeTally.swift
//  HLFIYA
//

import Foundation

/// How many times the person swiped on one place.
nonisolated struct SwipeTally: Identifiable, Equatable {
    let name: String
    let count: Int

    var id: String { name }

    /// The most-swiped places, ties broken alphabetically, with names trimmed.
    static func top(_ limit: Int, from names: [String]) -> [SwipeTally] {
        Dictionary(grouping: names.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }, by: \.self)
            .map { SwipeTally(name: $0.key, count: $0.value.count) }
            .sorted { ($0.count, $1.name) > ($1.count, $0.name) }
            .prefix(limit)
            .map(\.self)
    }
}
