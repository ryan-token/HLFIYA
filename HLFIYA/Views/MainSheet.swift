//
//  MainSheet.swift
//  HLFIYA
//

import Foundation

/// The sheets the main screen's toolbar can present.
enum MainSheet: String, Identifiable {
    case settings
    case lists
    case categories
    case prices
    case location

    var id: Self { self }
}
