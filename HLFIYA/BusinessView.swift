//
//  BusinessView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/24/22.
//

import SwiftUI

struct BusinessView: View {
    @State private var currentBusiness = BusinessDetails()
    @State private var apiError = false
    
    @Environment(\.dismiss) var dismiss
    
    var business: Business
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Button("Close") {
                    dismiss()
                }
            }
            .padding()
            
            Spacer()
            
            if apiError {
                Text("😕 Error loading businesses")
                    .foregroundColor(.gray)
                    .padding(.leading)
            }
            
            List {
                Section(header: Text(currentBusiness.name ?? "")) {
                    StarRatingView(rating: currentBusiness.rating ?? 0.0, label: "Rating:")
                    PriceView(price: currentBusiness.price ?? "", label: "Price:")
                }
                .headerProminence(.increased)
                
                Section(header: Text("Categories")) {
                    ForEach(currentBusiness.categories ?? [BusinessDetails.Category(alias: "", title: "")], id: \.self) { category in
                        Text(category.title ?? "")
                    }
                }
                
                Section(header: Text("Photos")) {
                    ImageSliderView(imageUrls: checkForPhotos(imageUrls: currentBusiness.photos ?? [""]))
                        .frame(height: 300)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section(header: Text("Information")) {
                    HStack {
                        Text("Currently Open:")
                            .foregroundColor(.gray)
                        Text(isClosed(currentBusiness.is_closed ?? false))
                    }
                    
                    HStack {
                        Text("Full Hours:")
                            .foregroundColor(.gray)
                        Text("Show Hours Here")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Address:")
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                        
                        Button {
                            openAddressInAppleMaps(latitude: currentBusiness.coordinates?.latitude ?? 0.0, longitude: currentBusiness.coordinates?.longitude ?? 0.0)
                        } label: {
                            ForEach(currentBusiness.location?.display_address ?? [""], id: \.self) { addressPortion in
                                HStack {
                                    Text(addressPortion)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Text("Phone:")
                            .foregroundColor(.gray)
                        Button(action: {
                            let phone = "tel://"
                            let phoneNumberformatted = phone + (currentBusiness.phone ?? "555-555-5555")
                            guard let url = URL(string: phoneNumberformatted) else { return }
                            UIApplication.shared.open(url)
                        }) {
                            Text(currentBusiness.display_phone ?? "")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Link("Open Website", destination: URL(string: currentBusiness.url ?? "#")!)
                }
                
                HStack {
                    Text("Powered by:")
                    Image("yelp_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75)
                }
                .listRowBackground(Color.clear)
                
            }
        }
        
        .task {
            await getBusiness(id: business.id)
        }
    }
    
    func getBusiness(id: String) async {
        Task {
            do {
                let businessDetails = try await BusinessFetcher.getBusiness(id: id)
                currentBusiness = businessDetails
                print(businessDetails)
                apiError = false
            } catch {
                print("Request failed with error: \(error)")
                apiError = true
            }
        }
    }
    
    func isClosed(_ closed: Bool) -> String {
        if closed == true {
            return "No"
        } else {
            return "Yes"
        }
    }
    
    func checkForPhotos(imageUrls: [String]) -> [String] {
        let emptyUrls = [""]
        if !imageUrls.isEmpty {
            return imageUrls
        } else {
            return emptyUrls
        }
    }
    
    func openAddressInAppleMaps (latitude: Double, longitude: Double) {
        guard let url = URL(string:"http://maps.apple.com/?daddr=\(latitude),\(longitude)") else { return }
        UIApplication.shared.open(url)
    }
}

struct BusinessView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessView(business: Business.data[0])
    }
}
