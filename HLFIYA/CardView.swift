//
//  CardView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//


import SwiftUI

struct CardView: View {
    @State private var showingBusinessDetails = false
    @State private var userTappedToShowMorePhotos = false
    @State private var selectedTab = 1
    @State private var imageUrls = [String]()
    @State private var apiError = false
    
    @Binding var business: Business
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    
    var totalBusinesses: Int
    
    let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if apiError {
                Text("😕 Error loading business photos")
                    .foregroundColor(.gray)
                    .padding(.leading)
            }
            
            if userTappedToShowMorePhotos {
                ImageSliderView(selectedTab: $selectedTab, imageUrls: imageUrls)
            } else {
                ImageSliderView(selectedTab: $selectedTab, imageUrls: [business.image_url])
            }
            
            LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom)
            
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text(business.name)
                        .font(Font.system(.largeTitle, design: .rounded))
                        .bold()
                        .padding(.bottom, 10)
                    
                    StarRatingView(rating: business.rating, label: "")
                        .padding(.bottom, 15)
                    
                    PriceView(price: business.price ?? "", label: "")
                    
                    HStack {
                        Text(business.categories[0].title)
                        Spacer()
                        Image("yelp_burst")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .padding(.bottom, 4)
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            
            HStack {
                Image("yes")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .opacity(Double(business.x/10 - 1))
                
                Spacer()
                
                Image("nope")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .opacity(Double(business.x/10 * -1 - 1))
            }
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
                            business.x = 0
                            business.degree = 0
                            business.y = 0
                            print("swiping right")
                        case let x where x > 100:
                            business.x = 500
                            business.degree = 12
                            remainingBusinessesInList -= 1
                            if remainingBusinessesInList != 0 {
                                currentBusinessIndex += 1
                            }
                            
                            showingBusinessDetails.toggle()
                            
                            print("swiped right")
                            print("remaining businesses: \(remainingBusinessesInList)")
                        case (-100)...(-1):
                            business.x = 0
                            business.degree = 0
                            business.y = 0
                            print("swiping left")
                        case let x where x < -100:
                            business.x = -500
                            business.y = -12
                            remainingBusinessesInList -= 1
                            if remainingBusinessesInList != 0 {
                                currentBusinessIndex += 1
                            }
                            print("swiped left")
                            print("remaining businesses: \(remainingBusinessesInList)")
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
}

//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardView(business: Business.data[0])
//    }
//}
