//
//  TopBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI
import CoreLocationUI

struct TopBarView: View {
    @State private var isShowingSettingsView = false
    
    var body: some View {
        HStack {
            Button(action: {
                LocationManager.shared.requestLocation()
            }) {
                Image(systemName: "location.circle.fill")
                    .font(Font.system(size: 45, design: .rounded))
            }
            
            Spacer()
            
            Button(action: {
                isShowingSettingsView.toggle()
            }) {
                Image(systemName: "gear.circle.fill")
                    .font(Font.system(size: 45, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        
        .popover(isPresented: $isShowingSettingsView) {
            SettingsView()
        }
    }
}
struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView()
    }
}
