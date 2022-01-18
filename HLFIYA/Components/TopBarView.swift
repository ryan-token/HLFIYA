//
//  TopBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI

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
                
            }) {
                Image("chats")
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
