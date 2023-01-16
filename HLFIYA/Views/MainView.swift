//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI
import CoreData
import MapKit
import GoogleMobileAds
import StoreKit

struct MainView: View {
    @State private var currentLocationSet = false
    @State private var nearbyRestaurants = [Business]()
    @State private var remainingRestaurantsInList = Int()
    @State private var currentRestaurantIndex = 0
    @State private var showRefreshButton = false
    @State private var noResultsFound = false
    @State private var apiError = false
    @State private var isShowingError = false
    @State private var errorTitle = ""
    
    @State private var restaurantsSwipedLeft = [Business]()
    @State private var restaurantsSwipedRight = [Business]()
    
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
                Text("😕 Error loading restaurants")
                    .foregroundColor(.gray)
            }
            
            if !nearbyRestaurants.isEmpty {
                Text(nearbyRestaurants[currentRestaurantIndex].location?.city ?? "")
                    .font(Font.system(.title, design: .rounded))
                    .bold()
                    .padding(5)
                    .animation(.default, value: currentRestaurantIndex)
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Categories:")
                        .foregroundColor(.gray)
                    Text(filters.categoriesNames)
                        .bold()
                        .lineLimit(1)
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
                if noResultsFound {
                    VStack {
                        Spacer()
                        Text("No results found. Try changing the filters at the bottom")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else if nearbyRestaurants.isEmpty && apiError == false {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else {
                    if !nearbyRestaurants.isEmpty {
                        ForEach($nearbyRestaurants.reversed()) { restaurant in
                            CardView(totalRestaurants: nearbyRestaurants.count, restaurant: restaurant, nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, restaurantsSwipedLeft: $restaurantsSwipedLeft, restaurantsSwipedRight: $restaurantsSwipedRight)
                                .padding(8)
                        }
                        .accessibilityLabel("\(nearbyRestaurants[currentRestaurantIndex].name ?? ""), \(nearbyRestaurants[currentRestaurantIndex].rating ?? 0.0, specifier: "%.1f") stars, \(nearbyRestaurants[currentRestaurantIndex].price?.count ?? -1) dollar signs, \(nearbyRestaurants[currentRestaurantIndex].categories?.first?.title ?? ""). Swipe left to skip, swipe right for details.")
                    }
                }
                
                if remainingRestaurantsInList == 0 && showRefreshButton && !noResultsFound {
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
            
            BottomBarView(nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, showRefreshButton: $showRefreshButton, noResultsFound: $noResultsFound, apiError: $apiError, filters: filters)
            
            
            if storeManager.purchasedIds.isEmpty {
                VStack(alignment: .trailing, spacing: 0) {
                    if let removeAdsProduct = storeManager.products.first {
                        AsyncButton(action: {
                            await purchaseRemoveAds(product: removeAdsProduct)
                        }) {
                            Text("Remove Ads")
                                .font(Font.system(.callout, design: .rounded))
                                .foregroundColor(Color(UIColor(named: "fuchsia")!))
                        }
                    }
                    GADBannerViewController()
                        .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
                }
            }
        }
        
        // First, check if we have cached data to use. Use that if we do
        // Clear all caches once we have any files that 
        // If we don't have a local cache, run the network request (which saves results to the cache)
        .task {
            Utils.clearAnyCacheFilesOverAMonthOld()
            
            let localYelpCache = Utils.getLocalYelpCache()
            
            if !localYelpCache.isEmpty {
                setState(fetchedBusinesses: localYelpCache)
                print("set state based on cached data")
                useCachedCategoriesFilter()
                useCachedPricesFilter()
                useCachedLocationFilter()
            } else if nearbyRestaurants.isEmpty {
                print("refreshing restaurants")
                let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationViewModel: locationViewModel, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices)
                setState(fetchedBusinesses: fetchedBusinesses)
                print("set state based on network data")
            } else {
                print("We already have restaurants, not fetching onAppear")
            }
        }
        
        .onAppear() {
            if locationViewModel.location == nil {
                locationViewModel.location = CLLocation(latitude: 37.334633, longitude: -122.012682)
            }
            
            if !userHasOpenedAppBefore && !itemExists("Favorites") {
                print("User hasn't opened the app before; adding a Favorites list")
                let favoritesList = SavedList(context: moc)
                favoritesList.name = "Favorites"

                try? moc.save()
            }
            
            if !userHasOpenedAppBefore {
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
                latitude = 37.334633
                longitude = -122.012682
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
            print("fetched businesses from API: \(fetchedBusinesses)")
        } catch {
            print("Request failed with error: \(error)")
            fetchedBusinesses = []
        }
        
        return fetchedBusinesses
    }
    
    func setState(fetchedBusinesses: [Business]) {
        nearbyRestaurants = fetchedBusinesses
        remainingRestaurantsInList = fetchedBusinesses.count
        currentRestaurantIndex = 0
        showRefreshButton = true
        apiError = false
        if fetchedBusinesses.isEmpty {
            noResultsFound = true
        }
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
    
    func useCachedCategoriesFilter() {
        let localCategoriesFilter = Utils.getCategoriesFilterCache()
        filters.categories = localCategoriesFilter.categories
        filters.categoriesNames = localCategoriesFilter.categoriesNames
    }
    
    func useCachedPricesFilter() {
        let localPricesFilter = Utils.getPricesFilterCache()
        filters.prices = localPricesFilter.prices
        filters.priceName = localPricesFilter.priceName
    }
    
    func useCachedLocationFilter() {
        let localLocationFilter = Utils.getLocationFilterCache()
        filters.customLatitude = localLocationFilter.customLatitude
        filters.customLongitude = localLocationFilter.customLongitude
        filters.customRadius = localLocationFilter.customRadius
    }
    
    private func itemExists(_ item: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedList")
        fetchRequest.predicate = NSPredicate(format: "name == %@", item)
        return ((try? moc.count(for: fetchRequest)) ?? 0) > 0
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(LocationViewModel())
    }
}
