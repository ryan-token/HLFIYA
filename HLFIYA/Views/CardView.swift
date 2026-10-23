//
//  CardView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import CoreData
import SwiftUI

/// A swipeable restaurant card. Swipe left to skip, swipe right for details,
/// and tap to page through more photos.
struct CardView: View {
    let business: Business
    let isSwipedAway: Bool
    let isTopCard: Bool
    let showsSwipeHint: Bool
    let feed: RestaurantFeed

    @State private var dragOffset = CGSize.zero
    @State private var cardWidth = 0.0
    @State private var isShowingDetails = false
    @State private var photoURLs: [String] = []
    @State private var selectedPhoto = 0
    @State private var photoLoadState = PhotoLoadState.notRequested

    @Environment(\.managedObjectContext) private var moc
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum PhotoLoadState {
        case notRequested, loading, loaded, failed
    }

    private enum SwipeDirection {
        case left, right
    }

    private static let swipeAnimation = Animation.interpolatingSpring(mass: 1, stiffness: 50, damping: 8)

    var body: some View {
        ImageSliderView(selection: $selectedPhoto, imageURLs: displayedPhotoURLs)
            .allowsHitTesting(false)
            .overlay {
                LinearGradient(colors: [.clear, .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    .allowsHitTesting(false)
            }
            .overlay {
                // Tapping anywhere on the photo shows more photos. VoiceOver uses
                // the card's own actions instead.
                Button(action: showMorePhotos) {
                    Color.clear
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
            .overlay(alignment: .top) {
                CardStatusBadge(showsSwipeHint: showsSwipeHint, photosFailedToLoad: photoLoadState == .failed)
            }
            .overlay(alignment: .bottom) {
                CardFooter(
                    name: business.name ?? "",
                    rating: business.rating ?? 0,
                    price: business.price ?? "",
                    category: business.categories?.first?.title ?? "",
                    canUndo: feed.canUndo,
                    undo: UndoSwipeAction(feed: feed)
                )
            }
            .overlay {
                HotNotOverlay(dragDistance: dragOffset.width)
            }
            .background(.black)
            .clipShape(.rect(cornerRadius: 8))
            .padding(8)
            .onGeometryChange(for: Double.self) { proxy in
                proxy.size.width
            } action: { width in
                cardWidth = width
            }
            .offset(x: horizontalOffset, y: verticalOffset)
            .rotationEffect(.degrees(rotation))
            .highPriorityGesture(dragGesture, isEnabled: isTopCard)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint("Swipe left to skip, or open details.")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(named: "Show Details", swipeRight)
            .accessibilityAction(named: "Skip", swipeLeft)
            .accessibilityAction(named: "More Photos", showMorePhotos)
            .accessibilityAction(named: "Undo") {
                UndoSwipeAction(feed: feed)()
            }
            .accessibilityHidden(!isTopCard)
            .sheet(isPresented: $isShowingDetails) {
                RestaurantDetailsSheet(restaurantID: business.id ?? "", restaurantName: business.name ?? "")
            }
            // Keyed by the load state so the fetch is cancelled if the card
            // leaves the deck before it completes.
            .task(id: photoLoadState == .loading) {
                guard photoLoadState == .loading else { return }
                await loadPhotos()
            }
    }

    // MARK: Layout

    private var displayedPhotoURLs: [String] {
        photoURLs.isEmpty ? [business.imageURL ?? ""] : photoURLs
    }

    /// How far a card travels when swiped away, relative to its width so it
    /// always leaves the screen, even on iPhone Duo's inner display.
    private var swipeAwayDistance: Double {
        max(cardWidth, 320) * 1.5
    }

    private var swipeThreshold: Double {
        max(cardWidth / 4, 80)
    }

    private var horizontalOffset: Double {
        isSwipedAway ? -swipeAwayDistance : dragOffset.width
    }

    private var verticalOffset: Double {
        isSwipedAway ? -12 : dragOffset.height
    }

    private var rotation: Double {
        if isSwipedAway {
            -7
        } else if dragOffset == .zero {
            0
        } else {
            dragOffset.width > 0 ? 7 : -7
        }
    }

    private var accessibilityLabel: String {
        let rating = (business.rating ?? 0).formatted(.number.precision(.fractionLength(1)))
        let price = business.price ?? ""
        let category = business.categories?.first?.title ?? ""
        return [business.name ?? "", "\(rating) stars", "\(price.count) dollar signs", category]
            .filter { !$0.isEmpty }
            .formatted(.list(type: .and, width: .narrow))
    }

    // MARK: Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                    dragOffset = value.translation
                }
            }
            .onEnded { value in
                if value.translation.width > swipeThreshold {
                    swipeRight()
                } else if value.translation.width < -swipeThreshold {
                    swipeLeft()
                } else {
                    withAnimation(Self.swipeAnimation) { dragOffset = .zero }
                }
            }
    }

    private func swipeLeft() {
        withAnimation(Self.swipeAnimation) {
            dragOffset = .zero
            feed.swipeLeft()
        }
        recordSwipe(.left)
    }

    private func swipeRight() {
        withAnimation(Self.swipeAnimation) { dragOffset = .zero }
        recordSwipe(.right)
        isShowingDetails = true
    }

    // MARK: Photos

    private func showMorePhotos() {
        switch photoLoadState {
        case .loaded where photoURLs.count > 1:
            selectedPhoto = (selectedPhoto + 1) % photoURLs.count
        case .notRequested, .failed:
            photoLoadState = .loading
        default:
            break
        }
    }

    private func loadPhotos() async {
        do {
            let details = try await BusinessFetcher.getBusiness(id: business.id ?? "")
            try Task.checkCancellation()

            let photos = details.photoURLs
            if !photos.isEmpty {
                photoURLs = photos
                // The first photo is usually the cover already showing, so jump to the next.
                selectedPhoto = photos.count > 1 ? 1 : 0
            }
            photoLoadState = .loaded
        } catch is CancellationError {
            photoLoadState = .notRequested
        } catch {
            photoLoadState = .failed
        }
    }

    // MARK: Persistence

    private func recordSwipe(_ direction: SwipeDirection) {
        let name = business.name ?? ""
        switch direction {
        case .right:
            let swipe = RightSwipe(context: moc)
            swipe.name = name
            swipe.uuid = UUID()
        case .left:
            let swipe = LeftSwipe(context: moc)
            swipe.name = name
            swipe.uuid = UUID()
        }

        do {
            try moc.save()
        } catch {
            moc.rollback()
        }
    }
}

#Preview {
    CardView(
        business: Business.data[0],
        isSwipedAway: false,
        isTopCard: true,
        showsSwipeHint: true,
        feed: RestaurantFeed()
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
