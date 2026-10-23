//
//  Business+Fixture.swift
//  HLFIYATests
//

@testable import HLFIYA

extension Business {
    /// A minimal restaurant for tests that only care about identity and categories.
    static func fixture(id: String, categoryAliases: [String] = []) -> Business {
        Business(
            id: id,
            rating: nil,
            price: nil,
            phone: nil,
            displayPhone: nil,
            alias: nil,
            isClosed: nil,
            categories: categoryAliases.map { Category(alias: $0, title: $0) },
            reviewCount: nil,
            name: id,
            url: nil,
            coordinates: nil,
            imageURL: nil,
            location: nil,
            distance: nil,
            transactions: nil
        )
    }
}
