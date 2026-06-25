//
//  Constants.swift
//  Weather Tracker
//
//  Created by Banghua Zhao on 7/6/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import UIKit

struct Constants {
    static let appID = "1534244892"

    static let facebookPageID = "104357371640600"

    struct AppID {
        static let financeGoAppID = "1519476344"
        static let finanicalRatiosGoMacOSAppID = "1486184864"
        static let financialRatiosGoAppID = "1481582303"
        static let countdownDaysAppID = "1525084657"
        static let moneyTrackerAppID = "1534244892"
    }

    // Ad unit IDs injected per build configuration via xcconfig (Info.plist):
    //   Config/Debug.xcconfig    — Google test IDs (committed)
    //   Config/Release.xcconfig  — production IDs (git-ignored)
    static let bannerViewAdUnitID = infoPlistString("bannerViewAdUnitID")
    static let appOpenAdID = infoPlistString("appOpenAdID")
    static let interstitialAdID = infoPlistString("interstitialAdID")
    static let rewardAdUnitID = infoPlistString("rewardAdUnitID")

    private static func infoPlistString(_ key: String) -> String {
        (Bundle.main.object(forInfoDictionaryKey: key) as? String) ?? ""
    }
}

struct UserDefaultsKeys {
    static let FETCH_COUNT = "FETCH_COUNT"
    static let CURRENCY = "CURRENCY"
    static let timesToOpenInterstitialAds = "timesToOpenInterstitialAds"
    /// True while the only transactions are the first-run sample data.
    static let hasSampleData = "hasSampleData"
}

let categoryExpenses: [String] = [
    "Grocery",
    "Transportation",
    "Entertainment",
    "Restaurant",
    "House Rent",
    "Insurance",
    "Travel",
    "Education",
    "Consumer Electronics",
    "Gift",
    "Medicine",
    "Clothing",
    "Beauty",
    "Membership",
    "Fitness",
    "Pets",
    "Utilities",
    "Childcare",
    "Other Expense",
]
let categoryIncomes: [String] = [
    "Salary",
    "Investment Income",
    "Savings",
    "Side Hustle Income",
    "Other Income",
]

struct JustForLocalization {
    let categoryExpensesLocalization: [String] = [
        "Grocery".localized(),
        "Transportation".localized(),
        "Entertainment".localized(),
        "Restaurant".localized(),
        "House Rent".localized(),
        "Insurance".localized(),
        "Travel".localized(),
        "Education".localized(),
        "Consumer Electronics".localized(),
        "Gift".localized(),
        "Medicine".localized(),
        "Other Expense".localized(),
    ]
    let categoryIncomesLocalization: [String] = [
        "Salary".localized(),
        "Investment Income".localized(),
        "Other Income".localized(),
    ]
}
