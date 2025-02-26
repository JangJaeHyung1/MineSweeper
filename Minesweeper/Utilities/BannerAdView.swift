//
//  BannerAdView.swift
//  Minesweeper
//
//  Created by jh on 2/15/25.
//
import UnityAdapter
import UnityAds
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    var adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
        bannerView.delegate = context.coordinator
        let request = GADRequest()
        bannerView.load(request)
        return bannerView
    }
    
    func makeCoordinator() -> Coordinator {
            return Coordinator()
        }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
    class Coordinator: NSObject, GADBannerViewDelegate {
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("📢 AdMob 광고 실패: \(error.localizedDescription)")
            print("✅ Unity Ads로 대체되는지 확인하세요 (미디에이션 설정 필요)")
        }
    }
}
