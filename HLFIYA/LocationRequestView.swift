//
//  LocationRequestView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/26/22.
//

import SwiftUI
import CoreLocation

struct LocationRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationViewModel: LocationViewModel
    @AppStorage("userHasOpenedAppBefore") var userHasOpenedAppBefore = false
    
    @State private var showGetReady = false
    @State private var showHot = false
    @State private var showLocal = false
    @State private var showFood = false
    @State private var showAllowLocation = false
    @State private var showMaybeLater = false

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Image("HLF-1024")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                    .padding(.bottom, 32)
                
                if showGetReady {
                    Text("Get ready for some")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding()
                }
                
                VStack (spacing: 5) {
                    if showHot {
                        Text("HOT 🥵")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                    
                    if showLocal {
                        Text("LOCAL 📍")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                    
                    if showFood {
                        Text("FOOD 🍔")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                }
                
//                VStack(spacing: -30) {
//                    if showHot {
//                        Image("hot")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 250, height: 100)
//                            .padding(.trailing, 15)
//                    }
//
//                    if showLocal {
//                        Image("local")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 250, height: 100)
//                            //.padding(.leading, 15)
//                    }
//
//                    Spacer()
//                        .frame(height: 25)
//
//                    if showFood {
//                        Image("food")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 250, height: 100)
//                            .padding(.leading, 15)
//                    }
//                }
                
                Spacer()
                
                VStack {
                    if showAllowLocation && (locationViewModel.authorizationStatus.rawValue != 2 && locationViewModel.authorizationStatus.rawValue != 4) {
                        Button {
                            locationViewModel.requestPermission()
                        } label: {
                            Text("Allow Location")
                                .padding()
                                .font(Font.system(.headline, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color(UIColor(named: "fuchsia")!.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))) : Color.white)
                        }
                        .frame(width: UIScreen.main.bounds.width)
                        .padding(.horizontal, -32)
                        .background(colorScheme == .dark ? Color.white : Color.black)
                        .clipShape(Capsule())
                        .padding()
                        .animation(.default, value: showAllowLocation)
                        .disabled(locationViewModel.authorizationStatus.rawValue == 2 ? true : false)
                    }
                    
                    if showMaybeLater && (locationViewModel.authorizationStatus.rawValue != 2 && locationViewModel.authorizationStatus.rawValue != 4) {
                        Button {
                            locationViewModel.location = CLLocation(latitude: 37.334633, longitude: -122.012682)
                            dismiss()
                        } label: {
                            Text("Maybe Later")
                                .padding()
                                .font(Font.system(.headline, design: .rounded))
                                .foregroundColor(.gray)
                                .animation(.default, value: showMaybeLater)
                        }
                    }
                    
                    switch locationViewModel.authorizationStatus {
                        case .notDetermined:
                            Text("")
                        case .restricted, .denied:
                            VStack(spacing: 0) {
                                Text("Location services are disabled")
                                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                                    .font(Font.system(.body, design: .rounded))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                }) {
                                    Text("Allow Location in Settings")
                                        .padding()
                                        .font(Font.system(.headline, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .frame(width: UIScreen.main.bounds.width)
                                .padding(.horizontal, -32)
                                .background(Color(UIColor(named: "fuchsia")!))
                                .clipShape(Capsule())
                                .padding()
                            }
                            .padding(.top, 30)
                            
                        case .authorizedWhenInUse, .authorizedAlways:
                            VStack(spacing: 0) {
                                Text("Location services are enabled 🚀")
                                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                                    .font(Font.system(.body, design: .rounded))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                }) {
                                    Text("Change Location Permissions")
                                        .padding()
                                        .font(Font.system(.headline, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .frame(width: UIScreen.main.bounds.width)
                                .padding(.horizontal, -32)
                                .background(Color(UIColor(named: "fuchsia")!))
                                .clipShape(Capsule())
                                .padding()
                            }
                            .padding(.top, 30)
                        
                        @unknown default:
                            Text("")
                    }
                }
                .padding(.bottom, 32)
            }
            .font(Font.system(.body, design: .rounded))
            
            .foregroundColor(Color(UIColor(named: "fuchsia")!))
        }
        .onAppear {
            print("authorization status: \(locationViewModel.authorizationStatus.rawValue)")
            if (userHasOpenedAppBefore) {
                showGetReady.toggle()
                showHot.toggle()
                showLocal.toggle()
                showFood.toggle()
                showAllowLocation.toggle()
                showMaybeLater.toggle()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        showGetReady.toggle()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showHot.toggle()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        showLocal.toggle()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        showFood.toggle()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    withAnimation {
                        showAllowLocation.toggle()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    withAnimation {
                        showMaybeLater.toggle()
                    }
                }
            }
        }
           
    }
}

struct LocationRequestView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRequestView()
            .preferredColorScheme(.light)
            .environmentObject(LocationViewModel())
    }
}
