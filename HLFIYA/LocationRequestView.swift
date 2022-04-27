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
                
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 32)
                
                Text("Would you like to explore nearby food?")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Start sharing your location")
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
                            .foregroundColor(.red)
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
