//
//  BusinessView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/24/22.
//

import SwiftUI

struct RestaurantDetailsView: View {
    var restaurant: Business
    
    @State private var currentRestaurant = BusinessDetails()
    @State private var apiError = false
    @State private var selectedTab = 1
    @State private var listTappedName = ""
    @State private var isShowingAddedToListAlert = false
    @State private var isShowingAddedToListErrorAlert = false
    @State private var isShowingDuplicateAlert = false
    @State private var isShowingCreateListSheet = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var savedLists: FetchedResults<SavedList>
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Spacer()
                    
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                }
                .padding(.top, 10)
                .padding(.trailing, 15)
            }
            
            Spacer()
            
            if apiError {
                Text("😕 Error loading business details")
                    .font(Font.system(.body, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.leading)
            }
            
            List {
                Section(header: Text(currentRestaurant.name ?? "")) {
                    StarRatingView(rating: currentRestaurant.rating ?? 0.0, label: "Rating:", reviewCount: currentRestaurant.review_count)
                    DollarView(price: currentRestaurant.price ?? "", label: "Price:")
                }
                .headerProminence(.increased)
                
                Section(header: Text("Photos")) {
                    ImageSliderView(selectedTab: $selectedTab, imageUrls: checkForPhotos(imageUrls: currentRestaurant.photos ?? [""]))
                        .frame(height: 300)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section(header: Text("Add to List")) {
                    ForEach(savedLists) { list in
                        Button(action:  {
                            listTappedName = list.wrappedName
                            addToList(list: list, id: restaurant.id, name: restaurant.name)
                        }) {
                            Text(list.wrappedName)
                        }
                        .accessibilityLabel("Add to \(list.wrappedName) list")
                    }
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                    
                    Button(action: {
                        isShowingCreateListSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.square")
                            Text("Create List")
                        }
                        .font(Font.system(.headline, design: .rounded))
                        .foregroundColor(Color(UIColor(named: "fuchsia")!))
                    }
                }
                
                Section(header: Text("Categories")) {
                    ForEach(currentRestaurant.categories ?? [BusinessDetails.Category(alias: "", title: "")], id: \.self) { category in
                        Text(category.title ?? "")
                    }
                }
                
                Section(header: Text("Information")) {
                    HStack {
                        Text("Currently Open:")
                            .foregroundColor(.gray)
                        Text(isOpenNow(currentRestaurant.hours?[0].is_open_now ?? false))
                            .bold()
                            .foregroundColor(currentRestaurant.hours?[0].is_open_now ?? false ? .green : .red)
                    }
                    
                    HStack {
                        Text("Phone:")
                            .foregroundColor(.gray)
                        Button(action: {
                            let phone = "tel://"
                            let phoneNumberformatted = phone + (currentRestaurant.phone ?? "555-555-5555")
                            guard let url = URL(string: phoneNumberformatted) else { return }
                            UIApplication.shared.open(url)
                        }) {
                            Text(currentRestaurant.display_phone ?? "")
                                .foregroundColor(Color(UIColor(named: "fuchsia")!))
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Address:")
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                        
                        Button {
                            openAddressInAppleMaps(latitude: currentRestaurant.coordinates?.latitude ?? 0.0, longitude: currentRestaurant.coordinates?.longitude ?? 0.0)
                        } label: {
                            ForEach(currentRestaurant.location?.display_address ?? [""], id: \.self) { addressPortion in
                                HStack {
                                    Text(addressPortion)
                                    Spacer()
                                }
                            }
                        }
                        .foregroundColor(Color(UIColor(named: "fuchsia")!))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Full Hours:")
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                        
                        VStack(alignment: .leading) {
                            ForEach((currentRestaurant.hours?[0].open ?? BusinessDetails.emptyBusiness.hours![0].open)!, id: \.self) { chunk in
                                VStack(alignment: .leading) {
                                    Text(convertDayNumberToWeekday(dayNumberString: chunk.day ?? 99999))
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text(convertMilitaryTimeToLocalTime(militaryTime: chunk.start ?? ""))
                                        
                                        Text("–")
                                        
                                        Text(convertMilitaryTimeToLocalTime(militaryTime: chunk.end ?? ""))
                                    }
                                    .accessibilityLabel("\(convertDayNumberToWeekday(dayNumberString: chunk.day ?? 99999)) hours: \(convertMilitaryTimeToLocalTime(militaryTime: chunk.start ?? "")) to \(convertMilitaryTimeToLocalTime(militaryTime: chunk.end ?? ""))")
                                    .font(Font.system(.headline, design: .rounded))
                                }
                                .padding(.bottom, 5)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(header: Text("Links")) {
                    Button("Open DoorDash") {
                        openAppOrSafari(appToTry: "DoorDash")
                    }
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                    
                    Button("Open Uber Eats") {
                        openAppOrSafari(appToTry: "Uber Eats")
                    }
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                    
                    Button("Open OpenTable") {
                        openAppOrSafari(appToTry: "OpenTable")
                    }
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                    
                    Link("See More on Yelp", destination: URL(string: currentRestaurant.url ?? "#")!)
                        .foregroundColor(Color(UIColor(named: "fuchsia")!))
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
                .accessibilityLabel("Powered by Yelp")
                .listRowBackground(Color.clear)
                
            }
            .font(Font.system(.body, design: .rounded))
        }
        
        .task {
            await getBusiness(id: restaurant.id)
        }
        
        .alert("Added \(restaurant.name) to your \(listTappedName) list", isPresented: $isShowingAddedToListAlert) {
            Button("OK", role: .cancel) { }
        }
        
        .alert("Error adding \(restaurant.name) to your \(listTappedName) list", isPresented: $isShowingAddedToListErrorAlert) {
            Button("OK", role: .cancel) { }
        }
        
        .alert("\(restaurant.name) is already in your \(listTappedName) list!", isPresented: $isShowingDuplicateAlert) {
            Button("OK", role: .cancel) { }
        }
        
        .popover(isPresented: $isShowingCreateListSheet) {
            CreateListSheet()
        }
    }
    
    func addToList(list: SavedList, id: String, name: String) {
        let restaurant = SavedRestaurant(context: moc)
        print("list restaurants: \(list.restaurantsArray)")
        if !list.restaurantsArray.contains(where: { $0.name == name }) {
            restaurant.addToLists(list)
            restaurant.id = id
            restaurant.name = name

            do {
                try moc.save()
                isShowingAddedToListAlert.toggle()
            } catch {
                isShowingAddedToListErrorAlert.toggle()
            }
        } else {
            isShowingDuplicateAlert.toggle()
        }
    }
    
    func getBusiness(id: String) async {
        Task {
            do {
                let businessDetails = try await BusinessFetcher.getBusiness(id: id)
                currentRestaurant = businessDetails
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
            let url = "https://www.doordash.com/search/store/\(currentRestaurant.name!)"
            safariUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        case "Uber Eats":
            urlScheme = "ubereats://"
            let url = "https://www.ubereats.com/search?diningMode=DELIVERY&q=\(currentRestaurant.name!)"
            safariUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        case "OpenTable":
            urlScheme = "opentable://"
            let url = "https://www.opentable.com/s?term=\(currentRestaurant.name!)"
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
        RestaurantDetailsView(restaurant: Business.data[0])
    }
}
