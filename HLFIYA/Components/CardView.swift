//
//  CardView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//


import SwiftUI

struct CardView: View {
    @State var card: Card
    
    let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(card.imageName)
                .resizable()
            
            LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom)
            
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text(card.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(String(card.age))
                            .font(.title)
                    }
                    Text(card.bio)
                }
            }
            .padding()
            .foregroundColor(.white)
            
            HStack {
                Image("yes")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .opacity(Double(card.x/10 - 1))
                
                Spacer()
                
                Image("nope")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .opacity(Double(card.x/10 * -1 - 1))
            }
        }
        .cornerRadius(8)
        .offset(x: card.x, y: card.y)
        .rotationEffect(.init(degrees: card.degree))
        
        .gesture (
            DragGesture()
                .onChanged { value in
                    withAnimation(.default) {
                        card.x = value.translation.width
                        card.y = value.translation.height
                        card.degree = 7 * (value.translation.width > 0 ? 1 : -1)
                    }
                }
            
                .onEnded { value in
                    withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                        switch value.translation.width {
                        case 0...100:
                            card.x = 0
                            card.degree = 0
                            card.y = 0
                            print("swiping right")
                        case let x where x > 100:
                            card.x = 500
                            card.degree = 12
                            print("swiped right")
                        case (-100)...(-1):
                            card.x = 0
                            card.degree = 0
                            card.y = 0
                            print("swiping left")
                        case let x where x < -100:
                            card.x = -500
                            card.y = -12
                            print("swiped left")
                        default:
                            card.x = 0
                            card.y = 0
                        }
                    }
                }
        )
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.data[0])
    }
}
