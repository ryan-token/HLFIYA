//
//  GADBannerViewController.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import GoogleMobileAds
import SwiftUI

/// Hosts a Google Mobile Ads banner, which needs a UIKit view controller to present from.
struct GADBannerViewController: UIViewControllerRepresentable {
    #if DEBUG
    private static let adUnitID = "ca-app-pub-3940256099942544/2934735716" // Google's test ad unit
    #else
    private static let adUnitID = "ca-app-pub-9555658360488346/5793158598"
    #endif

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = Self.adUnitID
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        viewController.view.frame = CGRect(origin: .zero, size: AdSizeBanner.size)
        bannerView.load(Request())
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
