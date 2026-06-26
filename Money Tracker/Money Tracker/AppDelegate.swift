//
//  AppDelegate.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import CoreData
#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
    import IQKeyboardManagerSwift
#endif

import StoreKit
import SwiftDate
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Format and parse dates in the device's local time zone. Without this,
        // SwiftDate defaults to UTC, which shifts a picked date back a day for
        // users east of UTC (e.g. "3/14" shown as "3/13" in UTC+8).
        SwiftDate.defaultRegion = Region.local

        IAPManager.shared.startObserving()

        #if !targetEnvironment(macCatalyst)
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            IQKeyboardManager.shared.enable = true
            if !IAPManager.shared.adsRemoved {
                AppOpenAdManager.shared.loadAd()
            }
        #endif

        StoreReviewHelper.incrementFetchCount()
        StoreReviewHelper.checkAndAskForReview()

        setupDefaultTransactions()

        let homeNav = MyNavigationController(rootViewController: HomeViewController())
        homeNav.setBackground(color: .systemBackground)
        homeNav.setTintColor(color: .themeColor)
        homeNav.tabBarItem = UITabBarItem(
            title: "Net Worth".localized(),
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let calcNav = MyNavigationController(rootViewController: CalculatorsViewController())
        calcNav.setBackground(color: .systemBackground)
        calcNav.setTintColor(color: .themeColor)
        calcNav.tabBarItem = UITabBarItem(
            title: "Calculators".localized(),
            image: UIImage(systemName: "function"),
            selectedImage: nil
        )

        let menuNav = MyNavigationController(rootViewController: MenuViewController())
        menuNav.setBackground(color: .systemBackground)
        menuNav.setTintColor(color: .themeColor)
        menuNav.tabBarItem = UITabBarItem(
            title: "More".localized(),
            image: UIImage(systemName: "ellipsis.circle"),
            selectedImage: UIImage(systemName: "ellipsis.circle.fill")
        )

        let tabBar = UITabBarController()
        tabBar.viewControllers = [homeNav, calcNav, menuNav]
        tabBar.tabBar.tintColor = .themeColor

        window = UIWindow()
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Show an app-open ad only when the user returns after being away a while
        // (handled in the manager). Never interrupts the first cold start.
        #if !targetEnvironment(macCatalyst)
            if !IAPManager.shared.adsRemoved {
                AppOpenAdManager.shared.showAdIfAvailable()
            }
        #endif
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        #if !targetEnvironment(macCatalyst)
            AppOpenAdManager.shared.appDidEnterBackground()
        #endif
    }
}

// MARK: - other functions

extension AppDelegate {
    func setupDefaultTransactions() {
        let defaultValues = ["firstRun": true]
        UserDefaults.standard.register(defaults: defaultValues)

        guard UserDefaults.standard.bool(forKey: "firstRun") else { return }

        let currentLocale = Locale.current
        if let currencyCode = currentLocale.currency?.identifier {
            print("first setup currencyCode: \(currencyCode)")
            UserDefaults.standard.set(currencyCode, forKey: UserDefaultsKeys.CURRENCY)
        } else {
            UserDefaults.standard.set("USD", forKey: UserDefaultsKeys.CURRENCY)
        }

        let context = CoreDataManager.shared.persistentContainer.viewContext

        let userTransactions = [
            UserTransaction(date: Date(), amount: -198.34, category: "Grocery", title: "\("Food, snacks and fruits".localized()) 🍔🍭🍒"),
            UserTransaction(date: Date() - 1.days, amount: -1000, category: "Transportation", title: "\("Flight to Silicon Valley".localized()) ✈️"),
            UserTransaction(date: Date() - 6.days, amount: -99, category: "Entertainment", title: "\("Watched a new moive".localized()) 🍿"),
            UserTransaction(date: Date() - 7.days, amount: -180, category: "Restaurant"),
            UserTransaction(date: Date() - 1.months, amount: 2000, category: "Investment Income", title: "Dividend from stock".localized()),
            UserTransaction(date: Date() - 1.months - 2.days, amount: -800, category: "House Rent"),
            UserTransaction(date: Date() - 1.months - 4.days, amount: -512, category: "Insurance", title: "Car insurance".localized()),
            UserTransaction(date: Date() - 2.months, amount: -189.25, category: "Grocery", title: "\("clothes and vegetable".localized())  👗🌽🥬"),
            UserTransaction(date: Date() - 2.months - 5.days, amount: 3000, category: "Other Income", title: "Payment for an article".localized()),
            UserTransaction(date: Date() - 2.months - 8.days, amount: -2000, category: "Travel", title: "\("Travel to Hawaii".localized()) 🏖"),
            UserTransaction(date: Date() - 3.months - 10.days, amount: -20, category: "Other Expense", title: "Massage"),
            UserTransaction(date: Date() - 4.months - 13.days, amount: -2000, category: "Education"),
            UserTransaction(date: Date() - 5.months, amount: -799, category: "Consumer Electronics", title: "\("New iPhone".localized()) 📱"),
            UserTransaction(date: Date() - 8.months, amount: 5000, category: "Salary"),
        ]

        for userTransaction in userTransactions {
            let transaction = Transaction(context: context)
            transaction.date = userTransaction.date
            transaction.amount = userTransaction.amount
            transaction.category = userTransaction.category
            transaction.title = userTransaction.title
        }

        do {
            try context.save()
            UserDefaults.standard.set(false, forKey: "firstRun")
            // Mark these as sample data so the Home screen can offer a one-tap
            // clear and so they're auto-removed when the user adds a real entry.
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSampleData)
        } catch let saveErr {
            print("Failed to save user transactions:", saveErr)
        }
    }
}

#if targetEnvironment(macCatalyst)
    extension AppDelegate {
        override func buildMenu(with builder: UIMenuBuilder) {
            super.buildMenu(with: builder)
            builder.remove(menu: .help)
            builder.remove(menu: .format)
        }
    }
#endif
