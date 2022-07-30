//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI
import MapKit
import GoogleMobileAds
import StoreKit

struct MainView: View {
    @State private var currentLocationSet = false
    @State private var nearbyBusinesses = [Business]()
    @State private var remainingBusinessesInList = Int()
    @State private var currentBusinessIndex = 0
    @State private var showRefreshButton = false
    @State private var apiError = false
    @State private var isShowingError = false
    @State private var errorTitle = ""
    
    @State private var businessesSwipedLeft = [Business]()
    @State private var businessesSwipedRight = [Business]()
    
    @StateObject var filters = FiltersState()
    @StateObject var storeManager = StoreManager()
    @EnvironmentObject var locationViewModel: LocationViewModel
    
    @Environment(\.managedObjectContext) var moc
    @AppStorage("userHasOpenedAppBefore") var userHasOpenedAppBefore = false
    
    init() {
        let design = UIFontDescriptor.SystemDesign.rounded
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
            .withDesign(design)!
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits.traitBold)!
        let font = UIFont.init(descriptor: descriptor, size: 30)
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : font]
    }
    
    var body: some View {
        VStack {
            TopBarView()
            
            if apiError {
                Text("😕 Error loading businesses")
                    .foregroundColor(.gray)
            }
            
            if !nearbyBusinesses.isEmpty {
                Text(nearbyBusinesses[currentBusinessIndex].location.city)
                    .font(Font.system(.title, design: .rounded))
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                    .bold()
                    .padding(5)
                    .animation(.none, value: currentBusinessIndex)
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Categories:")
                        .foregroundColor(.gray)
                    Text(filters.categoriesNames)
                        .bold()
                }
                .animation(.interactiveSpring(), value: filters.categories)
                
                HStack {
                    Text("Prices:")
                        .foregroundColor(.gray)
                    Text(filters.priceName)
                        .bold()
                }
                .animation(.interactiveSpring(), value: filters.priceName)
                
                HStack {
                    Text("Location:")
                        .foregroundColor(.gray)
                    Text("Within \(String(format:"%.1f", filters.customRadius)) Miles")
                        .bold()
                }
                .animation(.interactiveSpring(), value: filters.customRadius)
            }
            .font(Font.system(.body, design: .rounded))
            
            ZStack {
                if nearbyBusinesses.isEmpty && apiError == false {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else {
                    ForEach($nearbyBusinesses.reversed()) { business in
                        CardView(totalBusinesses: nearbyBusinesses.count, business: business, nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, businessesSwipedLeft: $businessesSwipedLeft, businessesSwipedRight: $businessesSwipedRight)
                            .padding(8)
                    }
                    .accessibilityLabel("\(nearbyBusinesses[currentBusinessIndex].name), \(nearbyBusinesses[currentBusinessIndex].rating, specifier: "%.1f") stars, \(nearbyBusinesses[currentBusinessIndex].price?.count ?? -1) dollar signs, \(nearbyBusinesses[currentBusinessIndex].categories.first?.title ?? ""). Swipe left to skip, swipe right for details.")
                }
                
                if remainingBusinessesInList == 0 && showRefreshButton {
                    AsyncButton(action: {
                        let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationViewModel: locationViewModel, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices)
                        setState(fetchedBusinesses: fetchedBusinesses)
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                            Text("Refresh Food")
                        }
                        .frame(width: 150, height: 100)
                        .font(Font.system(.headline, design: .rounded))
                        .foregroundColor(.red)
                    })
                }
            }
            .zIndex(1.0)
            
            BottomBarView(nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, showRefreshButton: $showRefreshButton, apiError: $apiError, filters: filters)
            
            
            if storeManager.purchasedIds.isEmpty {
                VStack(alignment: .trailing, spacing: 0) {
                    if let removeAdsProduct = storeManager.products.first {
                        AsyncButton(action: {
                            await purchaseRemoveAds(product: removeAdsProduct)
                        }) {
                            Text("Remove Ads")
                                .font(Font.system(.callout, design: .rounded))
                        }
                    }
                    GADBannerViewController()
                        .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
                }
            }
        }
        
        .task {
            if nearbyBusinesses.isEmpty {
                print("refreshing businesses")
                let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationViewModel: locationViewModel, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices)
                setState(fetchedBusinesses: fetchedBusinesses)
            } else {
                print("We already have businesses, not fetching onAppear")
            }
        }
        
        .onAppear() {
            if !userHasOpenedAppBefore {
                print("User hasn't opened the app before; adding a Favorites list")
                let favoritesList = SavedList(context: moc)
                favoritesList.name = "Favorites"

                try? moc.save()
                
                userHasOpenedAppBefore = true
            }
        }
        
        .environmentObject(storeManager)
        
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
        })
    }
    
    // radius is in meters
    static func refreshBusinesses(customLatitude: CLLocationDegrees, customLongitude: CLLocationDegrees, locationViewModel: LocationViewModel, customRadius: Double, categories: Set<String>, prices: Set<String>) async -> [Business] {
        var latitude: CLLocationDegrees
        var longitude: CLLocationDegrees
        var fetchedBusinesses: [Business]
        
        if customLatitude != 0.000000 && customLongitude != 0.000000 {
            latitude = customLatitude
            longitude = customLongitude
        } else {
            if let currentLocation = locationViewModel.location {
                latitude = currentLocation.coordinate.latitude
                longitude = currentLocation.coordinate.longitude
            } else {
                latitude = 0.000000
                longitude = 0.000000
            }
        }
        
        var stringPrices: String
        if prices == ["All Prices"] {
            stringPrices = "1,2,3,4"
        } else {
            stringPrices = prices.joined(separator: ",")
        }
        
        do {
            fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: Utils.convertMilesToMeters(miles: customRadius), categories: categories, prices: stringPrices)
        } catch {
            print("Request failed with error: \(error)")
            fetchedBusinesses = []
        }
        
        return fetchedBusinesses
    }
    
    func setState(fetchedBusinesses: [Business]) {
        nearbyBusinesses = fetchedBusinesses
        remainingBusinessesInList = fetchedBusinesses.count
        currentBusinessIndex = 0
        showRefreshButton = true
        apiError = false
    }
    
    func checkForApiError(fetchedBusinesses: [Business]) {
        if (fetchedBusinesses.count == 0) {
            apiError = true
        } else {
            apiError = false
        }
    }
    
    func purchaseRemoveAds(product: Product) async {
        do {
            if try await storeManager.purchase(product) != nil {
                print("Purchase was successful")
            }
        } catch StoreError.failedVerification {
            HapticGenerator.playErrorHaptic()
            errorTitle = "Your purchase could not be verified by the App Store"
            isShowingError.toggle()
        } catch {
            HapticGenerator.playErrorHaptic()
            print("Failed purchase for \(product.id): \(error)")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
