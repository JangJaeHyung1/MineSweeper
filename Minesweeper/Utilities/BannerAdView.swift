//
//  BannerAdView.swift
//  Minesweeper
//
//  Created by jh on 2/15/25.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    var adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        print("adUnitID:\(adUnitID)")
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
        bannerView.load(GADRequest())
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
