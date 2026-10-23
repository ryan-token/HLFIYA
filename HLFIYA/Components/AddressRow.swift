//
//  AddressRow.swift
//  HLFIYA
//

import SwiftUI

/// The restaurant's address, which opens directions in Maps when tapped.
struct AddressRow: View {
    let addressLines: [String]
    let latitude: Double?
    let longitude: Double?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Address")
                .foregroundStyle(.secondary)

            if let directionsURL {
                Link(destination: directionsURL) {
                    LabeledContent {
                        Image(systemName: "arrow.up.forward")
                            .foregroundStyle(.tertiary)
                            .font(.callout)
                    } label: {
                        Text(addressLines.joined(separator: "\n"))
                            .foregroundStyle(.tint)
                    }
                }
            } else {
                Text(addressLines.joined(separator: "\n"))
            }
        }
    }

    private var directionsURL: URL? {
        guard let latitude, let longitude else { return nil }
        return URL(string: "https://maps.apple.com/?daddr=\(latitude),\(longitude)")
    }
}

#Preview {
    List {
        AddressRow(
            addressLines: ["1 Ferry Bldg", "Shop 11", "San Francisco, CA 94111"],
            latitude: 37.795831,
            longitude: -122.393303
        )
    }
}
