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
                Image("profile")
            }
            
            Spacer()
            
            Button(action: {
                
            }) {
                Image("tinder-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 45)
            }
            
            Spacer()
            
            Button(action: {
                LocationManager.shared.requestLocation()
            }) {
                Image(systemName: "location.circle.fill")
                    .font(.largeTitle)
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
