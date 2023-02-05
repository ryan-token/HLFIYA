//
//  AboutView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/12/22.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 7) {
                Image("HLF-1024")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                    .padding(.bottom, 7)
                
                Text("Hot Local Food")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 7)
                
                Text("Made with 💜 by an independent developer")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Made with love by an independent developer")
                
                Form {
                    Section {
                        Text("Hot Local Food was built by two friends who just needed a better way to find some good food nearby.")
                        
                        Text("Thank you for using the app. Please leave a review if you find it valuable.")
                        
                        Button(action: {
                            requestReviewManually()
                        }) {
                            HStack {
                                Image(systemName: "heart.square.fill")
                                    .font(.title)
                                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                                Text("Rate on the App Store")
                                    .font(Font.system(.headline, design: .rounded))
                                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                            }
                        }
                    }
                    .padding(5)
                    
                    Section(header: Text("Try my other apps")) {
                        Button(action: {
                            openOutrankAppStoreLink()
                        }) {
                            HStack {
                                Image("Outrank-1024")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 11))
                                
                                Spacer()
                                    .frame(width: 15)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Outrank")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("College football stat rankings")
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .accessibilityLabel("Try out this developer's other app: Outrank")
                        
                        Button(action: {
                            openCatchUpAppStoreLink()
                        }) {
                            HStack {
                                Image("CatchUp-1024")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 11))
                                
                                Spacer()
                                    .frame(width: 15)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("CatchUp – Keep in Touch")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Stay in touch with those who matter most")
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .accessibilityLabel("Try out this developer's other app: CatchUp – Keep in Touch")
                    }
                }
            }
            
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(Font.system(.headline, design: .rounded))
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(Color(UIColor(named: "fuchsia")!))
    }
    
    func openCatchUpAppStoreLink() {
        if let url = URL(string: "itms-apps://apps.apple.com/us/app/catchup-keep-in-touch/id1358023550") {
            UIApplication.shared.open(url)
        }
    }
    
    func openOutrankAppStoreLink() {
        if let url = URL(string: "itms-apps://apps.apple.com/us/app/outrank/id1588983785") {
            UIApplication.shared.open(url)
        }
    }
    
    func requestReviewManually() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/us/app/hot-local-food/id1621818779?action=write-review") else {
            fatalError("Expected a valid URL")
        }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
