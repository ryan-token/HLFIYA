//
//  BottomBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI

struct BottomBarView: View {
    @State private var showingCategoryOptions = false
    @State private var showingPriceOptions = false
    @State private var showingRadiusSlider = false
    
    @Binding var nearbyBusinesses: [Business]
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var apiError: Bool

    @Binding var radiusFilter: Double
    @Binding var categoriesFilter: String
    @Binding var categoriesName: String
    @Binding var priceFilter: String
    @Binding var priceName: String
    
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        HStack {
            Spacer()
            
            AsyncButton(action: {
                await refreshBusinesses()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.cyan)
                    Text("Reload")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                showingCategoryOptions = true
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Category")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                showingPriceOptions = true
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.green)
                    Text("Price")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                showingRadiusSlider = true
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "map.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.pink)
                    Text("Radius")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            .confirmationDialog("Select a category", isPresented: $showingCategoryOptions, titleVisibility: .visible) {
                
                Group {
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "breakfast_brunch", name: "Breakfast & Brunch")
                    }) {
                        Text("Breakfast & Brunch")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "british", name: "British")
                    }) {
                        Text("British")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "burgers", name: "Burgers")
                    }) {
                        Text("Burgers")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "chinese", name: "Chinese")
                    }) {
                        Text("Chinese")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "comfortfood", name: "Comfort Food")
                    }) {
                        Text("Comfort Food")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "fooddeliveryservices", name: "Delivery Options")
                    }) {
                        Text("Delivery Options")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "hotdogs", name: "Fast Food")
                    }) {
                        Text("Fast Food")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "foodtrucks", name: "Food Trucks")
                    }) {
                        Text("Food Trucks")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "french", name: "French")
                    }) {
                        Text("French")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "german", name: "German")
                    }) {
                        Text("German")
                    }
                }
                
                Group {
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "greek", name: "Greek")
                    }) {
                        Text("Greek")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "indpak", name: "Indian")
                    }) {
                        Text("Indian")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "italian", name: "Italian")
                    }) {
                        Text("Italian")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "japanese", name: "Japanese")
                    }) {
                        Text("Japanese")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "korean", name: "Korean")
                    }) {
                        Text("Korean")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "mexican", name: "Mexican")
                    }) {
                        Text("Mexican")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "mideastern", name: "Middle Eastern")
                    }) {
                        Text("Middle Eastern")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "pizza", name: "Pizza")
                    }) {
                        Text("Pizza")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "seafood", name: "Seafood")
                    }) {
                        Text("Seafood")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "steak", name: "Steakhouses")
                    }) {
                        Text("Steakhouses")
                    }
                }
                
                Group {
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "sushi", name: "Sushi")
                    }) {
                        Text("Sushi")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "thai", name: "Thai")
                    }) {
                        Text("Thai")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "vegan", name: "Vegan")
                    }) {
                        Text("Vegan")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "vegetarian", name: "Vegetarian")
                    }) {
                        Text("Vegetarian")
                    }
                    
                    AsyncButton(action: {
                        await setCategoriesFilter(category: "food", name: "All Food")
                    }) {
                        Text("All Food")
                    }
                }
            }
            
            .confirmationDialog("Select a price range", isPresented: $showingPriceOptions, titleVisibility: .visible) {
                AsyncButton(action: {
                    await setPriceFilter(price: "1", name: "$")
                }) {
                    Text("$")
                }
                
                AsyncButton(action: {
                    await setPriceFilter(price: "2", name: "$$")
                }) {
                    Text("$$")
                }
                
                AsyncButton(action: {
                    await setPriceFilter(price: "3", name: "$$$")
                }) {
                    Text("$$$")
                }
                
                AsyncButton(action: {
                    await setPriceFilter(price: "4", name: "$$$$")
                }) {
                    Text("$$$$")
                }
                
                AsyncButton(action: {
                    await setPriceFilter(price: "1,2,3,4", name: "All Prices")
                }) {
                    Text("All Prices")
                }
            }
            
            .popover(isPresented: $showingRadiusSlider) {
                RadiusSlider(radiusFilter: $radiusFilter, categoriesFilter: categoriesFilter, priceFilter: priceFilter, nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, showRefreshButton: $showRefreshButton, apiError: $apiError)
            }
        }
    }
    
    func setCategoriesFilter(category: String, name: String) async {
        categoriesFilter = category
        categoriesName = name
        await refreshBusinesses()
    }
    
    func setPriceFilter(price: String, name: String) async {
        priceFilter = price
        priceName = name
        await refreshBusinesses()
    }
    
    func refreshBusinesses() async {
        if let location = locationManager.location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            do {
                let fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: Utils.convertMilesToMeters(miles: radiusFilter), categories: categoriesFilter, price: priceFilter)
                nearbyBusinesses = fetchedBusinesses
                print(nearbyBusinesses)
                remainingBusinessesInList = fetchedBusinesses.count
                currentBusinessIndex = 0
                showRefreshButton = true
                apiError = false
            } catch {
                print("Request failed with error: \(error)")
                apiError = true
            }
        }
    }
}

//struct BottomBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        BottomBarView()
//    }
//}
