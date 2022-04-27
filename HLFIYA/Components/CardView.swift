//
//  CardView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//


import SwiftUI

struct CardView: View {
    @State private var showingBusinessDetails = false
    
    @Binding var business: Business
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    
    var totalBusinesses: Int
    
    let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: business.image_url)) { image in
                image.resizable()
            } placeholder: {
                Color.blue
            }
            
            LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom)
            
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text(business.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    StarRatingView(rating: business.rating, label: "")
                        .padding(.bottom, 5)
                    
                    Text(business.categories[0].title)
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
}

//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardView(business: Business.data[0])
//    }
//}
