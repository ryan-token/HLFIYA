//
//  AsyncImageHack.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/30/22.
//

import SwiftUI

struct AsyncImageHack: View {
    var url: String
    var isScaledToFill: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in

            switch phase {
                case .success(let image):
                    if isScaledToFill {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        image
                            .resizable()
                    }

                // image failed to load
                // call AsyncImage again
                case .failure:
                    AsyncImage(url: URL(string: url)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else{
                            Image(systemName: "xmark.octagon")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                    }

            case .empty:
                Image(systemName: "xmark.octagon")
                    .font(.title)
                    .foregroundColor(.gray)

            @unknown default:
                Image(systemName: "xmark.octagon")
                    .font(.title)
                    .foregroundColor(.gray)
                
            }
        }
    }
}

struct AsyncImageHack_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImageHack(url: "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg", isScaledToFill: false)
    }
}
