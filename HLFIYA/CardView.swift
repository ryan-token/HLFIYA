//
//  CardView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//


import SwiftUI

struct CardView: View {
    var totalBusinesses: Int
    let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])
    
    @State private var showingBusinessDetails = false
    @State private var userTappedToShowMorePhotos = false
    @State private var selectedTab = 1
    @State private var imageUrls = [String]()
    @State private var apiError = false
    @State private var undoTapped = false
    
    @Binding var business: Business
    @Binding var nearbyBusinesses: [Business]
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    @Binding var businessesSwipedLeft: [Business]
    @Binding var businessesSwipedRight: [Business]
    
    @Environment(\.managedObjectContext) private var moc
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if apiError {
                Text("😕 Error loading business photos")
                    .font(Font.system(.body, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.leading)
            }
            
            Color.black
            
            if userTappedToShowMorePhotos {
                ImageSliderView(selectedTab: $selectedTab, imageUrls: imageUrls)
            } else {
                ImageSliderView(selectedTab: $selectedTab, imageUrls: [business.image_url])
            }
            
            LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom)
            
            VStack {
                if currentBusinessIndex == 0 {
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
                    Text(business.name)
                        .font(Font.system(.largeTitle, design: .rounded))
                        .bold()
                    
                    HStack {
                        StarRatingView(rating: business.rating, label: "")
                        Spacer()
                        Button(action: {
                            undo()
                        }) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(Font.system(size: 40, design: .rounded))
                                .foregroundColor(totalBusinesses != remainingBusinessesInList ? .yellow : .gray)
                        }
                        .accessibilityLabel("Undo")
                    }
                    
                    DollarView(price: business.price ?? "", label: "")
                    
                    HStack {
                        Text(business.categories[0].title)
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
                    .foregroundColor(.orange)
                    .bold()
                    .padding(5)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange, lineWidth: 4)
                    )
                    .rotationEffect(Angle(degrees: -25))
                    .opacity(Double(business.x/10 - 1))
                
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
                    .opacity(Double(business.x/10 * -1 - 1))
            }
            .padding(.top, 35)
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        .cornerRadius(8)
        .offset(x: business.x, y: business.y)
        .rotationEffect(.init(degrees: business.degree))
        
        .onTapGesture {
            if userTappedToShowMorePhotos == false {
                Task {
                    await getBusinessPhotos(id: business.id)
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
                    withAnimation(.default) {
                        business.x = value.translation.width
                        business.y = value.translation.height
                        business.degree = 7 * (value.translation.width > 0 ? 1 : -1)
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
                            business.x = 0
                            business.y = 0
                        }
                    }
                }
        )
        
        .sheet(isPresented: $showingBusinessDetails) {
            BusinessView(business: business)
        }
    }
    
    func getBusinessPhotos(id: String) async {
        Task {
            do {
                let businessDetails = try await BusinessFetcher.getBusiness(id: id)
                print("businessDetails: \(businessDetails)")
                imageUrls = businessDetails.photos ?? [business.image_url]
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
        if totalBusinesses != remainingBusinessesInList {
            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 100, initialVelocity: 7)) {
                nearbyBusinesses[currentBusinessIndex-1].x = 0
                nearbyBusinesses[currentBusinessIndex-1].y = 0
                nearbyBusinesses[currentBusinessIndex-1].degree = 0.0
            }
            
            remainingBusinessesInList += 1
            currentBusinessIndex -= 1
        } else {
            print("nothing to undo")
        }
    }
    
    func almostSwipedLeft() {
        business.x = 0
        business.degree = 0
        business.y = 0
        
        print("almost swiped left")
    }
    
    func swipedLeft() {
        business.x = -500
        business.y = -12
        
        remainingBusinessesInList -= 1
        if remainingBusinessesInList != 0 {
            currentBusinessIndex += 1
        }
        
        businessesSwipedLeft.append(business)
        
        addSwipeToCoreData(direction: "left")
        
        print("swiped left")
        print("businessesSwipedLeft: \(businessesSwipedLeft)")
        print("remaining businesses: \(remainingBusinessesInList)")
    }
    
    func almostSwipedRight() {
        business.x = 0
        business.degree = 0
        business.y = 0
        
        print("almost swiped right")
    }
    
    func swipedRight() {
        business.x = 0
        business.y = 0
        business.degree = 0
        
        businessesSwipedRight.append(business)
        
        addSwipeToCoreData(direction: "right")
        
        print("swiped right")
        
        showingBusinessDetails.toggle()
    }
    
    func addSwipeToCoreData(direction: String) {
        if direction == "right" {
            let rightSwipe = RightSwipe(context: moc)
            rightSwipe.name = business.name
            rightSwipe.uuid = UUID()
            
            try? moc.save()
        } else if direction == "left" {
            let leftSwipe = LeftSwipe(context: moc)
            leftSwipe.name = business.name
            leftSwipe.uuid = UUID()
            
            try? moc.save()
        } else {
            print("Unknown swipe direction?")
        }
    }
}

//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardView(business: Business.data[0])
//    }
//}
