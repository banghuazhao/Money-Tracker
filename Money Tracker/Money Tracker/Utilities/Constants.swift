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

    // google ads app id: ca-app-pub-4766086782456413~7297740247
    #if DEBUG
        static let bannerViewAdUnitID = ""
//    static let interstitialAdID = ""

//        static let bannerViewAdUnitID = "ca-app-pub-3940256099942544/2934735716"
        static let rewardAdUnitID = "ca-app-pub-3940256099942544/1712485313"
        static let interstitialAdID = "ca-app-pub-3940256099942544/1033173712"

    #else
        static let bannerViewAdUnitID = "ca-app-pub-4766086782456413/9732331897"
        static let interstitialAdID = "ca-app-pub-4766086782456413/2754175798"
        static let rewardAdUnitID = "ca-app-pub-4766086782456413/1902368364"
    #endif
}

struct UserDefaultsKeys {
    static let FETCH_COUNT = "FETCH_COUNT"
    static let CURRENCY = "CURRENCY"
    static let timesToOpenInterstitialAds = "timesToOpenInterstitialAds"
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
    "Other Expense",
]
let categoryIncomes: [String] = [
    "Salary",
    "Investment Income",
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
