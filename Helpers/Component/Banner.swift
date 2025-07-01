//
//  Banner.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 07.05.2025.
//

import Foundation
import SwiftUI
import GoogleMobileAds

struct Banner: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
//    .overlay(alignment: .bottom) {
//        Banner(adUnitID: "ca-app-pub-1923324197362942/6504418305")
//            .frame(width: 320, height: 50)
//    }
