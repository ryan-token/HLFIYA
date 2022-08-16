//
//  CardView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//


import SwiftUI

struct CardView: View {
    var totalRestaurants: Int
    let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])
    
    @State private var showingRestaurantDetails = false
    @State private var userTappedToShowMorePhotos = false
    @State private var selectedTab = 1
    @State private var imageUrls = [String]()
    @State private var apiError = false
    @State private var undoTapped = false
    
    @Binding var restaurant: Business
    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var restaurantsSwipedLeft: [Business]
    @Binding var restaurantsSwipedRight: [Business]
    
    @Environment(\.managedObjectContext) private var moc
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if apiError {
                Text("😕 Error loading restaurant photos")
                    .font(Font.system(.body, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.leading)
            }
            
            Color.black
            
            if userTappedToShowMorePhotos {
                ImageSliderView(selectedTab: $selectedTab, imageUrls: imageUrls)
            } else {
                ImageSliderView(selectedTab: $selectedTab, imageUrls: [restaurant.image_url])
            }
            
            LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom)
            
            VStack {
                if currentRestaurantIndex == 0 {
                    Text("Swipe ← to skip, swipe → for details")
                        .foregroundColor(.white)
                        .font(Font.system(.caption, design: .rounded))
                        .padding(8)
                        .background(Color.gray.opacity(0.6))
                        .clipShape(Capsule())
                        .padding(.top)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    Text(restaurant.name)
                        .font(Font.system(.largeTitle, design: .rounded))
                        .bold()
                    
                    HStack {
                        StarRatingView(rating: restaurant.rating)
                        Spacer()
                        Button(action: {
                            undo()
                        }) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(Font.system(size: 40, design: .rounded))
                                .foregroundColor(totalRestaurants != remainingRestaurantsInList ? .yellow : .gray)
                        }
                        .accessibilityLabel("Undo")
                    }
                    
                    DollarView(price: restaurant.price ?? "", label: "")
                    
                    HStack {
                        Text(restaurant.categories[0].title)
                        Spacer()
                        Image("yelp_burst")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .padding(.bottom, 12)
                            .padding(.trailing, 7)
                    }
                    .accessibilityLabel("Yelp Logo")
                }
            }
            .padding(.horizontal)
            .foregroundColor(.white)
            
            HStack {
                Text("HOT 🥵")
                    .font(Font.system(size: 40, design: .rounded))
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
                    .bold()
                    .padding(5)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(UIColor(named: "fuchsia")!), lineWidth: 4)
                    )
                    .rotationEffect(Angle(degrees: -25))
                    .opacity(Double(restaurant.x/10 - 1))
                
                Spacer()
                
                Text("NOT 😑")
                    .font(Font.system(size: 40, design: .rounded))
                    .foregroundColor(.black)
                    .bold()
                    .padding(5)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 4)
                    )
                    .rotationEffect(Angle(degrees: 25))
                    .opacity(Double(restaurant.x/10 * -1 - 1))
            }
            .padding(.top, 35)
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        .cornerRadius(8)
        .offset(x: restaurant.x, y: restaurant.y)
        .rotationEffect(.init(degrees: restaurant.degree))
        
        .onTapGesture {
            if userTappedToShowMorePhotos == false {
                Task {
                    await getBusinessPhotos(id: restaurant.id)
                }
            } else {
                if selectedTab == imageUrls.count {
                    selectedTab = 1
                } else {
                    selectedTab = selectedTab + 1
                }
            }
        }
        
        .gesture (
            DragGesture()
                .onChanged { value in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        restaurant.x = value.translation.width
                        restaurant.y = value.translation.height
                        restaurant.degree = 7 * (value.translation.width > 0 ? 1 : -1)
                    }
                }
            
                .onEnded { value in
                    withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                        switch value.translation.width {
                        case 0...100:
                            almostSwipedRight()
                        case let x where x > 100:
                            swipedRight()
                        case (-100)...(-1):
                            almostSwipedLeft()
                        case let x where x < -100:
                            swipedLeft()
                        default:
                            restaurant.x = 0
                            restaurant.y = 0
                        }
                    }
                }
        )
        
        .sheet(isPresented: $showingRestaurantDetails) {
            RestaurantDetailsView(restaurant: restaurant)
        }
    }
    
    func getBusinessPhotos(id: String) async {
        Task {
            do {
                let restaurantDetails = try await BusinessFetcher.getBusiness(id: id)
                print("restaurantDetails: \(restaurantDetails)")
                imageUrls = restaurantDetails.photos ?? [restaurant.image_url]
                print("imageUrls: \(imageUrls)")
                apiError = false
                selectedTab = 2
                userTappedToShowMorePhotos = true
            } catch {
                print("Request failed with error: \(error)")
                apiError = true
            }
        }
    }
    
    func undo() {
        if totalRestaurants != remainingRestaurantsInList {
            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 100, initialVelocity: 7)) {
                nearbyRestaurants[currentRestaurantIndex-1].x = 0
                nearbyRestaurants[currentRestaurantIndex-1].y = 0
                nearbyRestaurants[currentRestaurantIndex-1].degree = 0.0
            }
            
            remainingRestaurantsInList += 1
            currentRestaurantIndex -= 1
        } else {
            print("nothing to undo")
        }
    }
    
    func almostSwipedLeft() {
        restaurant.x = 0
        restaurant.degree = 0
        restaurant.y = 0
        
        print("almost swiped left")
    }
    
    func swipedLeft() {
        restaurant.x = -500
        restaurant.y = -12
        
        remainingRestaurantsInList -= 1
        if remainingRestaurantsInList != 0 {
            currentRestaurantIndex += 1
        }
        
        restaurantsSwipedLeft.append(restaurant)
        
        addSwipeToCoreData(direction: "left")
        
        print("swiped left")
        print("restaurantsSwipedLeft: \(restaurantsSwipedLeft)")
        print("remaining restaurants: \(remainingRestaurantsInList)")
    }
    
    func almostSwipedRight() {
        restaurant.x = 0
        restaurant.degree = 0
        restaurant.y = 0
        
        print("almost swiped right")
    }
    
    func swipedRight() {
        restaurant.x = 0
        restaurant.y = 0
        restaurant.degree = 0
        
        restaurantsSwipedRight.append(restaurant)
        
        addSwipeToCoreData(direction: "right")
        
        print("swiped right")
        
        showingRestaurantDetails.toggle()
    }
    
    func addSwipeToCoreData(direction: String) {
        if direction == "right" {
            let rightSwipe = RightSwipe(context: moc)
            rightSwipe.name = restaurant.name
            rightSwipe.uuid = UUID()
            
            try? moc.save()
        } else if direction == "left" {
            let leftSwipe = LeftSwipe(context: moc)
            leftSwipe.name = restaurant.name
            leftSwipe.uuid = UUID()
            
            try? moc.save()
        } else {
            print("Unknown swipe direction?")
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(totalRestaurants: 50, restaurant: .constant(Business.data[0]), nearbyRestaurants: .constant(Business.data), remainingRestaurantsInList: .constant(45), currentRestaurantIndex: .constant(5), restaurantsSwipedLeft: .constant([Business.data[0]]), restaurantsSwipedRight: .constant([Business.data[1]]))
    }
}
