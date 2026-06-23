//
//  StoreReviewHelper.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 12/2/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import StoreKit
import UIKit

struct StoreReviewHelper {
    static func incrementFetchCount() {
        guard var fetchCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.FETCH_COUNT) as? Int else {
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.FETCH_COUNT)
            return
        }
        fetchCount += 1
        UserDefaults.standard.set(fetchCount, forKey: UserDefaultsKeys.FETCH_COUNT)
    }

    static func checkAndAskForReview() {
        guard let fetchCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.FETCH_COUNT) as? Int else {
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.FETCH_COUNT)
            return
        }

        switch fetchCount {
        case 3, 15:
            StoreReviewHelper().requestReview()
        case _ where fetchCount % 100 == 0:
            StoreReviewHelper().requestReview()
        default:
            print("Fetch count is: \(fetchCount)")
            break
        }
    }

    @MainActor
    func requestReview() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        SKStoreReviewController.requestReview(in: windowScene)
    }
}
