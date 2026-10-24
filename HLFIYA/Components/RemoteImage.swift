//
//  RemoteImage.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/30/22.
//

import SwiftUI

/// A remote image that fills its frame, retrying once if the first load fails.
struct RemoteImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                FilledImage(image: image)
            case .failure:
                // Yelp's CDN occasionally drops a request; one retry usually succeeds.
                AsyncImage(url: url) { retryPhase in
                    if let image = retryPhase.image {
                        FilledImage(image: image)
                    } else {
                        Image(systemName: "xmark.octagon")
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Photo unavailable")
                    }
                }
            default:
                Rectangle()
                    .fill(.secondary)
            }
        }
    }
}

#Preview {
    RemoteImage(url: URL(string: "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg"))
}
