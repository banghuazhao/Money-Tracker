//
//  SceneDelegate.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import Bugly
import CoreData
import GoogleMobileAds
import IQKeyboardManagerSwift
import SwiftDate
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowScene = windowScene
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = window

        #if !DEBUG
            let config = BuglyConfig()
            config.reportLogLevel = .warn // 报告级别
            config.debugMode = false
            Bugly.start(withAppId: "62893b4dad", config: config)
        #endif

        GADMobileAds.sharedInstance().start(completionHandler: nil)

        IQKeyboardManager.shared.enable = true

        StoreReviewHelper.incrementFetchCount()
        StoreReviewHelper.checkAndAskForReview()

        setupDefaultTransactions()

        let navigationController = MyNavigationController(rootViewController: HomeViewController())
        navigationController.setBackground(color: .systemBackground)
        navigationController.setTintColor(color: .themeColor)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

// MARK: - other functions

extension SceneDelegate {
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
