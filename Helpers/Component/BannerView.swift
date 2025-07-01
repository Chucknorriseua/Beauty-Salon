//
//  BannerView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 06.05.2025.
//

import GoogleMobileAds
import SwiftUI

class InterstitialAdViewModel: NSObject, ObservableObject, FullScreenContentDelegate {
    
    static var shared = InterstitialAdViewModel()
    
    private var interstitial: InterstitialAd?
    @AppStorage("firstSignIn") var firstSignIn: Bool = false

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = Request()
        InterstitialAd.load(with: "ca-app-pub-1923324197362942/8376442176",
                               request: request) { [weak self] ad, error in
            if let error = error {
                print("Ошибка загрузки рекламы: \(error.localizedDescription)")
                return
            }
            print("Реклама успешно загружена")
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        }
    }
    

    func showAd(from rootViewController: UIViewController) {
        if let ad = interstitial {
            ad.present(from: rootViewController)
        } else {
            print("Реклама не загружена")
            DispatchQueue.main.async { [weak self] in
                self?.loadAd() // перезагрузить рекламу, если не готова
            }
        }
    }

    // MARK: - GADFullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Реклама закрыта пользователем")
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if !self.firstSignIn {
                self.loadAd()
            } else {
                self.loadAd()
            }
        }
    }
}
