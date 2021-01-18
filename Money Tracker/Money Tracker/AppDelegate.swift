//
//  AppDelegate.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import CoreData
#if !targetEnvironment(macCatalyst)
    import Bugly
    import GoogleMobileAds
    import IQKeyboardManagerSwift
#endif

import SwiftDate
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        #if !targetEnvironment(macCatalyst)
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            IQKeyboardManager.shared.enable = true
            #if !DEBUG
                let config = BuglyConfig()
                config.reportLogLevel = .warn // 报告级别
                config.debugMode = false
                Bugly.start(withAppId: "62893b4dad", config: config)
            #endif

        #endif

        StoreReviewHelper.incrementFetchCount()
        StoreReviewHelper.checkAndAskForReview()

        setupDefaultTransactions()

        let navigationController = MyNavigationController(rootViewController: HomeViewController())
        navigationController.setBackground(color: .systemBackground)
        navigationController.setTintColor(color: .themeColor)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

// MARK: - other functions

extension AppDelegate {
    func setupDefaultTransactions() {
        let defaultValues = ["firstRun": true]
        UserDefaults.standard.register(defaults: defaultValues)

        guard UserDefaults.standard.bool(forKey: "firstRun") else { return }

        let currentLocale = Locale.current
        if let currencyCode = currentLocale.currencyCode {
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
            let transaction = NSEntityDescription.insertNewObject(forEntityName: "Transaction", into: context) as! Transaction

            transaction.setValue(userTransaction.date, forKey: "date")
            transaction.setValue(userTransaction.amount, forKey: "amount")
            transaction.setValue(userTransaction.category, forKey: "category")
            transaction.setValue(userTransaction.title, forKey: "title")
        }

        // perform the save
        do {
            try context.save()

            // success
            UserDefaults.standard.set(false, forKey: "firstRun")
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
