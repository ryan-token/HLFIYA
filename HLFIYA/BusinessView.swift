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
    @State private var selectedTab = 1
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    var business: Business
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Spacer()
                    
                    Button("Close") {
                        dismiss()
                    }
                }
                .padding(.top, 10)
                .padding(.trailing, 15)
            }
            
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
                    ImageSliderView(selectedTab: $selectedTab, imageUrls: checkForPhotos(imageUrls: currentBusiness.photos ?? [""]))
                        .frame(height: 300)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section(header: Text("Information")) {
                    HStack {
                        Text("Currently Open:")
                            .foregroundColor(.gray)
                        Text(isOpenNow(currentBusiness.hours?[0].is_open_now ?? false))
                            .bold()
                            .foregroundColor(currentBusiness.hours?[0].is_open_now ?? false ? .green : .red)
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
                    
                    VStack(alignment: .leading) {
                        Text("Full Hours:")
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                        
                        VStack(alignment: .leading) {
                            ForEach((currentBusiness.hours?[0].open ?? BusinessDetails.emptyBusiness.hours![0].open)!, id: \.self) { chunk in
                                VStack(alignment: .leading) {
                                    Text(convertDayNumberToWeekday(dayNumberString: chunk.day ?? 99999))
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text(convertMilitaryTimeToLocalTime(militaryTime: chunk.start ?? ""))
                                        
                                        Text("–")
                                        
                                        Text(convertMilitaryTimeToLocalTime(militaryTime: chunk.end ?? ""))
                                    }
                                    .font(.headline)
                                }
                                .padding(.bottom, 5)
                            }
                        }
                    }
                }
                
                Section(header: Text("Links")) {
                    Button("Open DoorDash") {
                        openAppOrSafari(appToTry: "DoorDash")
                    }
                    Button("Open Uber Eats") {
                        openAppOrSafari(appToTry: "Uber Eats")
                    }
                    Button("Open OpenTable") {
                        openAppOrSafari(appToTry: "OpenTable")
                    }
                    Link("See More on Yelp", destination: URL(string: currentBusiness.url ?? "#")!)
                }
                
                HStack {
                    Text("Powered by:")
                    
                    if (colorScheme == .light) {
                        Image("yelp_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75)
                    } else {
                        Image("yelp_logo_dark_bg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75)
                    }
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
    
    func isOpenNow(_ isOpenNow: Bool) -> String {
        if isOpenNow {
            return "Yes"
        } else {
            return "No"
        }
    }
    
    func convertDayNumberToWeekday(dayNumberString: Int) -> String {
        switch dayNumberString {
        case 0:
            return "Monday"
        case 1:
            return "Tuesday"
        case 2:
            return "Wednesday"
        case 3:
            return "Thursday"
        case 4:
            return "Friday"
        case 5:
            return "Saturday"
        case 6:
            return "Sunday"
        default:
            return "Unknown"
        }
    }
    
    func convertMilitaryTimeToLocalTime(militaryTime: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"

        let date = dateFormatter.date(from: militaryTime)
        dateFormatter.dateFormat = "h:mm a"
        let localTime = dateFormatter.string(from: date ?? Date())
        
        return localTime
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
    
    func openAppOrSafari(appToTry: String) {
        var urlScheme: String
        var safariUrl: String
        
        switch appToTry {
        case "DoorDash":
            urlScheme = "doordash://"
            let url = "https://www.doordash.com/search/store/\(currentBusiness.name!)"
            safariUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        case "Uber Eats":
            urlScheme = "ubereats://"
            let url = "https://www.ubereats.com/search?diningMode=DELIVERY&q=\(currentBusiness.name!)"
            safariUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        case "OpenTable":
            urlScheme = "opentable://"
            let url = "https://www.opentable.com/s?term=\(currentBusiness.name!)"
            safariUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        default:
            urlScheme = "#"
            safariUrl = "#"
        }
        
        if let customScheme = URL(string: urlScheme) {
            openURL(customScheme) { accepted in
                if !accepted {
                    print("failed to open app")
                    print("safariUrl: \(safariUrl)")
                    if let webUrl = URL(string: safariUrl) {
                        openURL(webUrl)
                    }
                }
            }
        }
    }
}

struct BusinessView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessView(business: Business.data[0])
    }
}
