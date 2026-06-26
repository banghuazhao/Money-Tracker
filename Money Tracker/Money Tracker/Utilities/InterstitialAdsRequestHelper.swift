//
//  InterstitialAdsRequestHelper.swift
//  Financial Statements Go
//
//  Created by Banghua Zhao on 2021/1/13.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import Foundation

struct InterstitialAdsRequestHelper {
    /// Show an interstitial only every Nth transaction add (adding is the core
    /// action — interrupting it too often is what users complained about).
    static let requestThreshold = 5
    /// Never show two interstitials closer together than this, regardless of count.
    static let minInterval: TimeInterval = 3 * 60

    private static let lastShownKey = "lastInterstitialShownDate"

    static func incrementRequestCount() {
        if var requestCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.timesToOpenInterstitialAds) as? Int {
            requestCount += 1
            UserDefaults.standard.setValue(requestCount, forKey: UserDefaultsKeys.timesToOpenInterstitialAds)
        } else {
            UserDefaults.standard.setValue(1, forKey: UserDefaultsKeys.timesToOpenInterstitialAds)
        }
    }

    static func increaseRequestAndCheckLoadInterstitialAd() -> Bool {
        incrementRequestCount()
        let requestCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.timesToOpenInterstitialAds)
        print("requestCount: \(requestCount)")
        guard requestCount >= requestThreshold else { return false }

        // Enforce a time cooldown so a burst of quick adds can't chain ads.
        if let last = UserDefaults.standard.object(forKey: lastShownKey) as? Date,
           Date().timeIntervalSince(last) < minInterval {
            return false
        }
        return true
    }

    static func resetRequestCount() {
        UserDefaults.standard.setValue(0, forKey: UserDefaultsKeys.timesToOpenInterstitialAds)
        UserDefaults.standard.setValue(Date(), forKey: lastShownKey)
        print("resetRequestCount")
    }
}

