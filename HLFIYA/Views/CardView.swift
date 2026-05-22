//
//  CardView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI

struct CardView: View {
    var totalRestaurants: Int

    @State private var showingRestaurantDetails = false
    @State private var wantsMorePhotos = false
    @State private var selectedTab = 1
    @State private var imageUrls = [String]()
    @State private var apiError = false
    @State private var thereAreImages = true

    @Binding var restaurant: Business
    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var restaurantsSwipedLeft: [Business]
    @Binding var restaurantsSwipedRight: [Business]

    @Environment(\.managedObjectContext) private var moc

    private let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])

    var body: some View {
        ZStack(alignment: .topLeading) {
            if apiError {
                Text("😕 Error loading restaurant photos")
                    .foregroundStyle(.gray)
                    .padding(.leading)
            }

            Color.black

            ImageSliderView(
                selectedTab: $selectedTab,
                imageUrls: wantsMorePhotos && !imageUrls.isEmpty ? imageUrls : [restaurant.image_url ?? ""]
            )

            LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom)

            VStack {
                if currentRestaurantIndex == 0 {
                    Text("Swipe ← to skip, swipe → for details")
                        .foregroundStyle(.white)
                        .font(.footnote)
                        .padding(8)
                        .background(Color.gray.opacity(0.6))
                        .clipShape(.capsule)
                        .padding(.top)
                }
                Spacer()

                CardFooter(
                    restaurant: restaurant,
                    canUndo: totalRestaurants != remainingRestaurantsInList,
                    undoAction: undo
                )
            }
            .padding(.horizontal)
            .foregroundStyle(.white)

            HotNotOverlay(opacity: restaurant.x)
        }
        .clipShape(.rect(cornerRadius: 8))
        .offset(x: restaurant.x, y: restaurant.y)
        .rotationEffect(.degrees(restaurant.degree))
        .onTapGesture {
            handleCardTap()
        }
        .accessibilityAddTraits(.isButton)
        .gesture(dragGesture)
        .sheet(isPresented: $showingRestaurantDetails) {
            RestaurantDetailsView(restaurant: restaurant)
        }
        // Driven by `wantsMorePhotos` so the fetch is auto-cancelled if the
        // card disappears (e.g. user swipes away) before it completes.
        .task(id: wantsMorePhotos) {
            guard wantsMorePhotos, thereAreImages, imageUrls.isEmpty else { return }
            await loadBusinessPhotos(id: restaurant.id ?? "")
        }
    }

    private var dragGesture: some Gesture {
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
    }

    private func handleCardTap() {
        if wantsMorePhotos, !imageUrls.isEmpty {
            selectedTab = selectedTab == imageUrls.count ? 1 : selectedTab + 1
        } else {
            wantsMorePhotos = true
        }
    }

    private func loadBusinessPhotos(id: String) async {
        do {
            let details = try await BusinessFetcher.getBusiness(id: id)
            try Task.checkCancellation()
            let urls = details.photos ?? [restaurant.image_url ?? ""]
            apiError = false

            if urls.isEmpty {
                thereAreImages = false
            } else {
                imageUrls = urls
                selectedTab = 2
            }
        } catch is CancellationError {
            // Card disappeared mid-fetch — let the new view drive its own load.
        } catch {
            print("Request failed with error: \(error)")
            apiError = true
        }
    }

    private func undo() {
        guard totalRestaurants != remainingRestaurantsInList else { return }
        withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 100, initialVelocity: 7)) {
            nearbyRestaurants[currentRestaurantIndex - 1].x = 0
            nearbyRestaurants[currentRestaurantIndex - 1].y = 0
            nearbyRestaurants[currentRestaurantIndex - 1].degree = 0.0
        }
        remainingRestaurantsInList += 1
        currentRestaurantIndex -= 1
    }

    private func almostSwipedLeft() {
        restaurant.x = 0
        restaurant.degree = 0
        restaurant.y = 0
    }

    private func swipedLeft() {
        restaurant.x = -500
        restaurant.y = -12

        remainingRestaurantsInList -= 1
        if remainingRestaurantsInList > 0 {
            currentRestaurantIndex += 1
        }

        restaurantsSwipedLeft.append(restaurant)
        addSwipeToCoreData(direction: .left)
    }

    private func almostSwipedRight() {
        restaurant.x = 0
        restaurant.degree = 0
        restaurant.y = 0
    }

    private func swipedRight() {
        restaurant.x = 0
        restaurant.y = 0
        restaurant.degree = 0

        restaurantsSwipedRight.append(restaurant)
        addSwipeToCoreData(direction: .right)
        showingRestaurantDetails.toggle()
    }

    private enum SwipeDirection { case left, right }

    private func addSwipeToCoreData(direction: SwipeDirection) {
        switch direction {
        case .right:
            let rightSwipe = RightSwipe(context: moc)
            rightSwipe.name = restaurant.name ?? ""
            rightSwipe.uuid = UUID()
        case .left:
            let leftSwipe = LeftSwipe(context: moc)
            leftSwipe.name = restaurant.name ?? ""
            leftSwipe.uuid = UUID()
        }

        do {
            try moc.save()
        } catch {
            print("Failed to save swipe to Core Data: \(error)")
        }
    }
}

private struct CardFooter: View {
    let restaurant: Business
    let canUndo: Bool
    let undoAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(restaurant.name ?? "")
                .font(.largeTitle)
                .bold()

            HStack {
                StarRatingView(rating: restaurant.rating ?? 0.0)
                Spacer()
                Button(action: undoAction) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(canUndo ? .yellow : .gray)
                }
                .disabled(!canUndo)
                .accessibilityLabel("Undo")
            }

            DollarView(price: restaurant.price ?? "", label: "")

            HStack {
                Text(restaurant.categories?.first?.title ?? "")
                Spacer()
                Image("yelp_burst")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .padding(.bottom, 12)
                    .padding(.trailing, 7)
                    .accessibilityLabel("Yelp Logo")
            }
        }
    }
}

private struct HotNotOverlay: View {
    let opacity: Double

    var body: some View {
        HStack {
            Text("HOT 🥵")
                .font(.system(size: 40))
                .foregroundStyle(.fuchsia)
                .bold()
                .padding(5)
                .background(Color.white)
                .clipShape(.rect(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.fuchsia, lineWidth: 4)
                }
                .rotationEffect(.degrees(-25))
                .opacity(opacity / 10 - 1)

            Spacer()

            Text("NOT 😑")
                .font(.system(size: 40))
                .foregroundStyle(.black)
                .bold()
                .padding(5)
                .background(Color.gray)
                .clipShape(.rect(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 4)
                }
                .rotationEffect(.degrees(25))
                .opacity(opacity / 10 * -1 - 1)
        }
        .padding(.top, 35)
        .padding(.horizontal, 10)
    }
}

#Preview {
    CardView(
        totalRestaurants: 50,
        restaurant: .constant(Business.data[0]),
        nearbyRestaurants: .constant(Business.data),
        remainingRestaurantsInList: .constant(45),
        currentRestaurantIndex: .constant(5),
        restaurantsSwipedLeft: .constant([Business.data[0]]),
        restaurantsSwipedRight: .constant([Business.data[1]])
    )
}
