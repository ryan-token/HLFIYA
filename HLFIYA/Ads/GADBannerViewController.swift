//
//  GADBannerViewController.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import GoogleMobileAds
import SwiftUI
import UIKit

struct GADBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let view = BannerView(adSize: AdSizeBanner)
        let viewController = UIViewController()
        var adUnitId = "ca-app-pub-9555658360488346/5793158598" // prod ad unit ID
        #if DEBUG
            adUnitId = "ca-app-pub-3940256099942544/2934735716" // test ad unit ID
        #endif
        print("using ad unit ID \(adUnitId)")
        view.adUnitID = adUnitId
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: AdSizeBanner.size)
        view.load(Request())
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
