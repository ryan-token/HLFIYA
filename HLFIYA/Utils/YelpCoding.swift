//
//  YelpCoding.swift
//  HLFIYA
//

import Foundation

nonisolated extension JSONDecoder {
    /// A decoder for Yelp's snake_case JSON, and for the app's caches of it.
    static var yelp: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

nonisolated extension JSONEncoder {
    /// An encoder that writes snake_case keys, matching Yelp's responses.
    static var yelp: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
