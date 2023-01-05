//
//  SavedRestaurantsDetailsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct SavedRestaurantsDetailsView: View {
    var restaurantId: String
    
    @State private var currentRestaurant = BusinessDetails()
    @State private var listTappedName = ""
    @State private var isShowingCreateListSheet = false
    @State private var isShowingAddedToListAlert = false
    @State private var isShowingAddedToListErrorAlert = false
    @State private var isShowingDuplicateAlert = false
    @State private var selectedTab = 1
    @State private var apiError = false
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject var locationViewModel: LocationViewModel
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var savedLists: FetchedResults<SavedList>
    
    var body: some View {
        List {
            Section(header: Text(currentRestaurant.name ?? "")) {
                VStack(alignment: .leading, spacing: 5) {
                    StarRatingView(rating: currentRestaurant.rating ?? 0.0, label: "Rating:", reviewCount: currentRestaurant.review_count)
                    DollarView(price: currentRestaurant.price ?? "", label: "Price:")
                    
                    if currentRestaurant.categories?.count ?? 0 < 2 {
                        HStack {
                            Text("Category:")
                            ForEach(currentRestaurant.categories ?? [BusinessDetails.Category(alias: "", title: "")], id: \.self) { category in
                                Text(category.title ?? "")
                                    .accessibilityLabel("\(currentRestaurant.name ?? "restaurant") is a \(category.title ?? "") place")
                            }
                        }
                        .foregroundColor(.gray)
                        
                    } else {
                        VStack(alignment: .leading) {
                            Text("Categories:")
                            
                            Spacer()
                                .frame(height: 5)
                            
                            ForEach(currentRestaurant.categories ?? [BusinessDetails.Category(alias: "", title: "")], id: \.self) { category in
                                Text("– \(category.title ?? "")")
                                    .padding(.leading, 25)
                                    .accessibilityLabel("\(currentRestaurant.name ?? "restaurant") is a \(category.title ?? "") place")
                            }
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
            .headerProminence(.increased)
            .accessibilityLabel("Rating, price, and categories for \(currentRestaurant.name ?? "restaurant")")
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section(header: Text("Photos")) {
                ImageSliderView(selectedTab: $selectedTab, imageUrls: checkForPhotos(imageUrls: currentRestaurant.photos ?? [""]))
                    .frame(height: 300)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            
            Section(header: Text("Add to List")) {
                ForEach(savedLists) { list in
                    Button(action:  {
                        listTappedName = list.wrappedName
                        addToList(list: list, id: currentRestaurant.id ?? "", name: currentRestaurant.name ?? "")
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
                        Image(systemName: "plus.square.fill")
                        Text("Create List")
                    }
                    .font(Font.system(.headline, design: .rounded))
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                }
            }
            
            Section(header: Text("Order").foregroundColor(.gray)) {
                HStack {
                    Button("Search DoorDash") {
                        openAppOrSafari(appToTry: "DoorDash")
                    }
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .foregroundColor(Color(uiColor: .lightGray))
                        .font(.callout)
                }
                
                HStack {
                    Button("Search Uber Eats") {
                        openAppOrSafari(appToTry: "Uber Eats")
                    }
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .foregroundColor(Color(uiColor: .lightGray))
                        .font(.callout)
                }
                
                HStack {
                    Button("Search OpenTable") {
                        openAppOrSafari(appToTry: "OpenTable")
                    }
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .foregroundColor(Color(uiColor: .lightGray))
                        .font(.callout)
                }
                
                HStack {
                    Link("See More on Yelp", destination: URL(string: currentRestaurant.url ?? "#")!)
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .foregroundColor(Color(uiColor: .lightGray))
                        .font(.callout)
                }
            }
            .foregroundColor(Color(UIColor(named: "fuchsia")!))
            
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
                        .padding(.top, 2)
                        .padding(.bottom, 2)
                    
                    Button {
                        openAddressInAppleMaps(latitude: currentRestaurant.coordinates?.latitude ?? 0.0, longitude: currentRestaurant.coordinates?.longitude ?? 0.0)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                ForEach(currentRestaurant.location?.display_address ?? [""], id: \.self) { addressPortion in
                                    HStack {
                                        Text(addressPortion)
                                        Spacer()
                                    }
                                }
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .foregroundColor(Color(uiColor: .lightGray))
                                .font(.callout)
                        }
                    }
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                    .padding(.bottom, 5)
                }
                
                VStack(alignment: .leading) {
                    Text("Full Hours:")
                        .foregroundColor(.gray)
                        .padding(.top, 5)
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
        
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        
        .task {
            let localYelpCacheForBusiness = Utils.getLocalYelpCacheForBusiness(id: restaurantId)
            
            if localYelpCacheForBusiness.name != "" {
                currentRestaurant = localYelpCacheForBusiness
                print("got business data from cache")
            } else {
                await getBusiness(id: restaurantId)
                print("got business data from API")
            }
        }
        
        .alert("Added \(currentRestaurant.name ?? "") to your \(listTappedName) list", isPresented: $isShowingAddedToListAlert) {
            Button("OK", role: .cancel) { }
        }
        
        .alert("Error adding \(currentRestaurant.name ?? "") to your \(listTappedName) list", isPresented: $isShowingAddedToListErrorAlert) {
            Button("OK", role: .cancel) { }
        }
        
        .alert("\(currentRestaurant.name ?? "") is already in your \(listTappedName) list!", isPresented: $isShowingDuplicateAlert) {
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
            let doordashUrl = "search/store/\(currentRestaurant.name!)/?event_type=search"
            let cleanUrl = doordashUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            urlScheme = "doordash:///\(cleanUrl)"
            safariUrl = "https://www.doordash.com/\(cleanUrl)"
            
        case "Uber Eats":
            let uberEatsUrl = "search?diningMode=DELIVERY&q=\(currentRestaurant.name!)&sc=SEARCH_SUGGESTION&vertical=ALL"
            let cleanUrl = uberEatsUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            urlScheme = "ubereats://\(cleanUrl)"
            safariUrl = "https://www.ubereats.com/\(cleanUrl)"
            
        case "OpenTable":
            let date = Date.now
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let now = formatter.string(from: date)
            
            if let location = locationViewModel.location {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                let openTableUrl = "s?dateTime=\(now)&covers=2&latitude=\(latitude)&longitude=\(longitude)&term=\(currentRestaurant.name!)&shouldUseLatLongSearch=true&sortBy=web_conversion&originalTerm=\(currentRestaurant.name!)&intentModifiedTerm=\(currentRestaurant.name!)&queryUnderstandingType=default"
                let cleanUrl = openTableUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                urlScheme = "opentable"
                safariUrl = "https://www.opentable.com/\(cleanUrl)"
            } else {
                let openTableUrl = "s?dateTime=\(now)&covers=2&term=\(currentRestaurant.name!)&shouldUseLatLongSearch=true&sortBy=web_conversion&originalTerm=\(currentRestaurant.name!)&intentModifiedTerm=\(currentRestaurant.name!)&queryUnderstandingType=default"
                let cleanUrl = openTableUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                urlScheme = "opentable"
                safariUrl = "https://www.opentable.com/\(cleanUrl)"
            }
        default:
            urlScheme = "#"
            safariUrl = "#"
        }
        
        // couldn't figure out the URL scheme to search within the OpenTable app, so I try to just open Safari every time for OpenTable
        // even the standard https:// url is opening the OpenTable app though, unfortunately
        if urlScheme == "opentable" {
            if let webUrl = URL(string: safariUrl) {
                openURL(webUrl)
            }
        } else {
            if let customScheme = URL(string: urlScheme) {
                openURL(customScheme) { accepted in
                    if !accepted {
                        print("failed to open app")
                        print("using safariUrl: \(safariUrl)")
                        if let webUrl = URL(string: safariUrl) {
                            openURL(webUrl)
                        }
                    }
                }
            }
        }
    }
}


struct SavedRestaurantsDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        SavedRestaurantsDetailsView(restaurantId: "WavvLdfdP6g8aZTtbBQHTw")
    }
}
