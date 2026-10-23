//
//  RemoveAdsBannerView.swift
//  HLFIYA
//

import GoogleMobileAds
import SwiftUI

/// The banner ad, with a "Remove Ads" purchase button, shown until ads are removed.
struct RemoveAdsBannerView: View {
    @Environment(StoreManager.self) private var storeManager
    @State private var purchaseErrorMessage: String?

    var body: some View {
        if !storeManager.hasRemovedAds {
            VStack(alignment: .trailing, spacing: 0) {
                if storeManager.removeAdsProduct != nil {
                    AsyncButton(action: purchase) {
                        Text("Remove Ads")
                            .font(.callout)
                            .foregroundStyle(.fuchsia)
                    }
                }

                GADBannerViewController()
                    .frame(width: AdSizeBanner.size.width, height: AdSizeBanner.size.height)
            }
            .frame(maxWidth: .infinity)
            .alert("Purchase Failed", item: $purchaseErrorMessage) { _ in
            } message: { message in
                Text(message)
            }
            .sensoryFeedback(.error, trigger: purchaseErrorMessage != nil) { _, isShowingError in
                isShowingError
            }
        }
    }

    private func purchase() async {
        purchaseErrorMessage = await storeManager.purchaseRemoveAds()
    }
}
