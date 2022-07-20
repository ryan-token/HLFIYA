//
//  LocationRequestView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/26/22.
//

import SwiftUI
import CoreLocation

struct LocationRequestView: View {
    private let manager = CLLocationManager()
    
    @State private var showGetReady = false
    @State private var showHot = false
    @State private var showLocal = false
    @State private var showFood = false
    @State private var showAllowLocation = false
    @State private var showMaybeLater = false
    
    @ObservedObject var locationManager = LocationManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            
            VStack {
                Spacer()
                
                Text("🍑")
                    .font(Font.system(size: 150))
                    .padding(.bottom, 32)
                
                if showGetReady {
                    Text("Get ready for some")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding()
                }
                
                VStack (spacing: 5) {
                    if showHot {
                        Text("HOT 🥵")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    
                    if showLocal {
                        Text("LOCAL 📍")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    
                    if showFood {
                        Text("FOOD 🍔")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                VStack {
                    if showAllowLocation {
                        Button {
                            LocationManager.shared.requestLocation()
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
                    }
                    
                    if showMaybeLater {
                        Button {
                            locationManager.location = CLLocation(latitude: 36.14203247996243, longitude: -95.97570631738338)
                        } label: {
                            Text("Maybe Later")
                                .padding()
                                .font(Font.system(.headline, design: .rounded))
                                .foregroundColor(.gray)
                                .animation(.default, value: showMaybeLater)
                        }
                    }
                    
                    if CLLocationManager.locationServicesEnabled() {
                        switch manager.authorizationStatus {
                        case .notDetermined:
                            Text("")
                        case .restricted, .denied:
                            VStack(spacing: 0) {
                                Text("Location services are disabled")
                                    .foregroundColor(.red)
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
                                .background(Color.red)
                                .clipShape(Capsule())
                                .padding()
                            }
                            .padding(.top, 30)
                            
                        case .authorizedAlways, .authorizedWhenInUse:
                            Text("")
                        @unknown default:
                            Text("")
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .font(Font.system(.body, design: .rounded))
            
            .foregroundColor(Color(UIColor(named: "fuchsia")!))
        }
        .onAppear {
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

struct LocationRequestView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRequestView()
            .preferredColorScheme(.light)
    }
}
