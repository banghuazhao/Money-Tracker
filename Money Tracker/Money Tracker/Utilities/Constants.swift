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
        static let countdownDaysAppID = "1525084657"
        static let moneyTrackerAppID = "1534244892"
        static let tripMarkAppID = "6464474080"
        static let BMIDiaryAppID = "1521281509"
        static let novelsHubAppID = "1528820845"
        static let swiftSumAppID = "1610829871"
        static let showsAppID = "1624910011"
        static let fallingBlockPuzzleAppID = "1609440799"
        static let calmCanvasAppID = "1618712178"
        static let wePlayPianoAppID = "1625018611"
        static let worldWeatherLiveAppID = "1612773646"
        static let minesweeperZAppID = "1621899572"
        static let sudokuLoverAppID = "1620749798"
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

extension Notification.Name {
    static let currencyDidChange = Notification.Name("currencyDidChange")
    static let backupDidRestore = Notification.Name("backupDidRestore")
}

struct UserDefaultsKeys {
    static let FETCH_COUNT = "FETCH_COUNT"
    static let CURRENCY = "CURRENCY"
    static let timesToOpenInterstitialAds = "timesToOpenInterstitialAds"
    /// True while the only transactions are the first-run sample data.
    static let hasSampleData = "hasSampleData"
    /// True once the user has paid to remove ads forever.
    static let adsRemoved = "adsRemoved"
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
    "Rental Income",
    "Freelance",
    "Bonus",
    "Interest Income",
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
        "Clothing".localized(),
        "Beauty".localized(),
        "Membership".localized(),
        "Fitness".localized(),
        "Pets".localized(),
        "Utilities".localized(),
        "Childcare".localized(),
        "Other Expense".localized(),
    ]
    let categoryIncomesLocalization: [String] = [
        "Salary".localized(),
        "Investment Income".localized(),
        "Rental Income".localized(),
        "Freelance".localized(),
        "Bonus".localized(),
        "Interest Income".localized(),
        "Savings".localized(),
        "Side Hustle Income".localized(),
        "Other Income".localized(),
    ]
}
