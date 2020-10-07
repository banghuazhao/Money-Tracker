//
//  AppOpenAdManager.swift
//  Money Tracker
//
//  Lightweight app-open ad manager. Loads an app-open ad and shows it when the
//  app returns to the foreground, with a frequency cap so it never feels spammy.
//

#if !targetEnvironment(macCatalyst)

import GoogleMobileAds
import UIKit

final class AppOpenAdManager: NSObject {
    static let shared = AppOpenAdManager()

    private var appOpenAd: GADAppOpenAd?
    private var isLoadingAd = false
    private var isShowingAd = false

    /// When the currently cached ad was loaded. Ads expire after 4 hours.
    private var loadTime: Date?
    private let adExpiry: TimeInterval = 3600 * 4

    /// When we last *showed* an app-open ad, used for the frequency cap.
    private var lastShowTime: Date?
    /// Minimum gap between two app-open ads so returning users aren't bombarded.
    private let minIntervalBetweenAds: TimeInterval = 4 * 60

    private var adUnitID: String { Constants.appOpenAdID }

    private override init() { super.init() }

    // MARK: - Loading

    func loadAd() {
        guard !adUnitID.isEmpty, !isLoadingAd, !isAdAvailable() else { return }
        isLoadingAd = true
        GADAppOpenAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
            guard let self = self else { return }
            self.isLoadingAd = false
            if let error = error {
                print("App-open ad failed to load: \(error.localizedDescription)")
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
        }
    }

    // MARK: - Showing

    func showAdIfAvailable() {
        guard !isShowingAd else { return }

        // Respect the frequency cap.
        if let lastShowTime, Date().timeIntervalSince(lastShowTime) < minIntervalBetweenAds {
            return
        }

        guard isAdAvailable(), let ad = appOpenAd else {
            loadAd()
            return
        }

        guard let root = Self.topViewController() else { return }

        // Don't cover another modal/full-screen ad that's already presented.
        if root is GADFullScreenPresentingAd { return }

        isShowingAd = true
        ad.present(fromRootViewController: root)
    }

    // MARK: - Helpers

    private func isAdAvailable() -> Bool {
        guard appOpenAd != nil, let loadTime else { return false }
        return Date().timeIntervalSince(loadTime) < adExpiry
    }

    private static func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}

// MARK: - GADFullScreenContentDelegate

extension AppOpenAdManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        appOpenAd = nil
        isShowingAd = false
        lastShowTime = Date()
        loadAd()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("App-open ad failed to present: \(error.localizedDescription)")
        appOpenAd = nil
        isShowingAd = false
        loadAd()
    }
}

#endif
