//
//  PhoneRow.swift
//  HLFIYA
//

import SwiftUI

/// The restaurant's phone number, which places a call when tapped.
struct PhoneRow: View {
    let phone: String
    let displayPhone: String

    var body: some View {
        LabeledContent("Phone") {
            if let url = URL(string: "tel://\(phone)") {
                Link(displayPhone, destination: url)
            } else {
                Text(displayPhone)
            }
        }
    }
}

#Preview {
    List {
        PhoneRow(phone: "+14153917117", displayPhone: "(415) 391-7117")
    }
}
