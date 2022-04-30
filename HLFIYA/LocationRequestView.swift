//
//  LocationRequestView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/26/22.
//

import SwiftUI

struct LocationRequestView: View {
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("🍑")
                    .font(Font.system(size: 150))
                    .padding(.bottom, 32)
                
                Text("Would you like to *explore* HOT 🥵 LOCAL 📍 FOOD  in your area?")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Start sharing your location")
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                VStack {
                    Button {
                        LocationManager.shared.requestLocation()
                    } label: {
                        Text("Allow location")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(Color.black)
                    .clipShape(Capsule())
                    .padding()
                    
                    Button {
                        print("Dismiss")
                    } label: {
                        Text("Maybe Later")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 32)
            }
            .foregroundColor(.red)
        }
    }
}

struct LocationRequestView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRequestView()
    }
}
