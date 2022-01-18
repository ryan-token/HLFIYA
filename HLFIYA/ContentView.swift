//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        VStack {
            TopBarView()
            
            ZStack {
                ForEach(Card.data.reversed()) { card in
                    CardView(card: card)
                        .padding(8)
                }
            }
            .zIndex(1.0)
            
            BottomBarView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
