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
    /// How far left a swiped card travels to clear the screen, measured by the deck.
    let swipeAwayDistance: Double
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

    private static let bouncySwipeAnimation = Animation.interpolatingSpring(mass: 1, stiffness: 50, damping: 8)

    private var swipeAnimation: Animation {
        reduceMotion ? .smooth : Self.bouncySwipeAnimation
    }

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
            // Dragging doesn't animate, so tilt quickly to the new side when a drag
            // crosses the middle, rather than flipping in a single frame.
            .transaction { transaction in
                if transaction.animation == nil {
                    transaction.animation = .snappy(duration: 0.2)
                }
            } body: { card in
                card.rotationEffect(.degrees(rotation))
            }
            .highPriorityGesture(dragGesture, isEnabled: isTopCard)
            .cardAccessibility(
                label: accessibilityLabel,
                showDetails: swipeRight,
                skip: swipeLeft,
                showMorePhotos: showMorePhotos,
                undo: UndoSwipeAction(feed: feed)
            )
            .accessibilityHidden(!isTopCard)
            .sheet(isPresented: $isShowingDetails) {
                RestaurantDetailsSheet(restaurantID: business.id ?? "", restaurantName: business.name ?? "")
            }
            // Keyed by the load state so tapping the card starts the fetch.
            .task(id: photoLoadState == .loading) {
                guard photoLoadState == .loading else { return }
                await loadPhotos()
            }
            #if DEBUG
            .onAppear(perform: applyScreenshotState)
            #endif
    }

    #if DEBUG
    /// Holds the top card mid-swipe or opens its details, as screenshot mode's launch arguments ask.
    private func applyScreenshotState() {
        guard ScreenshotMode.isEnabled, isTopCard else { return }
        dragOffset = CGSize(width: ScreenshotMode.dragDistance, height: 0)
        isShowingDetails = ScreenshotMode.opensDetails
    }
    #endif

    // MARK: Layout

    private var displayedPhotoURLs: [String] {
        photoURLs.isEmpty ? [business.imageURL ?? ""] : photoURLs
    }

    private var swipeThreshold: Double {
        max(cardWidth / 4, 80)
    }

    private var horizontalOffset: Double {
        isSwipedAway ? -max(swipeAwayDistance, max(cardWidth, 320) * 1.5) : dragOffset.width
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
                dragOffset = value.translation
            }
            .onEnded { value in
                if value.translation.width > swipeThreshold {
                    swipeRight()
                } else if value.translation.width < -swipeThreshold {
                    swipeLeft()
                } else {
                    withAnimation(swipeAnimation) { dragOffset = .zero }
                }
            }
    }

    private func swipeLeft() {
        withAnimation(swipeAnimation) {
            dragOffset = .zero
            feed.swipeLeft()
        }
        recordSwipe(.left)
    }

    private func swipeRight() {
        withAnimation(swipeAnimation) { dragOffset = .zero }
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
        } catch {
            // URLSession reports cancellation as `URLError(.cancelled)`, not `CancellationError`.
            photoLoadState = Task.isCancelled ? .notRequested : .failed
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

private extension View {
    /// One VoiceOver element whose default action opens details. Kept out of
    /// `CardView.body` so the compiler type-checks the two chains separately.
    func cardAccessibility(
        label: String,
        showDetails: @escaping () -> Void,
        skip: @escaping () -> Void,
        showMorePhotos: @escaping () -> Void,
        undo: UndoSwipeAction
    ) -> some View {
        accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityHint("Opens details. Swipe up or down for more actions.")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default, showDetails)
            .accessibilityAction(named: "Show Details", showDetails)
            .accessibilityAction(named: "Skip", skip)
            .accessibilityAction(named: "More Photos", showMorePhotos)
            .accessibilityAction(named: "Undo") { undo() }
    }
}

#Preview {
    CardView(
        business: Business.data[0],
        isSwipedAway: false,
        isTopCard: true,
        showsSwipeHint: true,
        swipeAwayDistance: 0,
        feed: RestaurantFeed()
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
