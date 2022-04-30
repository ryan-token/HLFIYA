//
//  TopBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI
import CoreLocationUI

struct TopBarView: View {
    
    var body: some View {
        HStack {
            Button(action: {
                
            }) {
                Image("tinder-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            
            Spacer()
            
            Button(action: {
                LocationManager.shared.requestLocation()
            }) {
                Image(systemName: "location.circle.fill")
                    .font(Font.system(size: 50, design: .rounded))
            }
        }
        .padding(.horizontal)
    }
}
struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView()
    }
}
