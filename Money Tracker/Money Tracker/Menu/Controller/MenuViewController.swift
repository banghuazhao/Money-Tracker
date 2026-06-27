//
//  MenuViewController.swift
//  Countdown Days
//
//  Created by Banghua Zhao on 8/1/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import MessageUI
import SafariServices
import SnapKit
import StoreKit
import Then
import UIKit

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
    import ProgressHUD
#endif

class MenuViewController: UIViewController, MFMailComposeViewControllerDelegate {
    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()

        var userDidEarn = false
        var rewardedAd: GADRewardedAd?
    #endif

    // Section 1 items — "Remove Ads Forever" lives in section 0, not here.
    #if !targetEnvironment(macCatalyst)
        let menuItems = [
            MyMenuItem(title: "Change currency symbol".localized(), icon: UIImage(systemName: "dollarsign.circle")),
            MyMenuItem(title: "Manage Categories".localized(), icon: UIImage(systemName: "tag")),
            MyMenuItem(title: "Back up Data".localized(), icon: UIImage(systemName: "icloud.and.arrow.up")),
            MyMenuItem(title: "Feedback".localized(), icon: UIImage(systemName: "bubble.left")),
            MyMenuItem(title: "Rate this App".localized(), icon: UIImage(systemName: "star")),
            MyMenuItem(title: "Share this App".localized(), icon: UIImage(systemName: "square.and.arrow.up")),
            MyMenuItem(title: "Support this App".localized(), icon: UIImage(systemName: "hand.thumbsup")),
            MyMenuItem(title: "More Apps".localized(), icon: UIImage(systemName: "ellipsis")),
        ]
    #else
        let menuItems = [
            MyMenuItem(title: "Change currency symbol".localized(), icon: UIImage(systemName: "dollarsign.circle")),
            MyMenuItem(title: "Manage Categories".localized(), icon: UIImage(systemName: "tag")),
            MyMenuItem(title: "Back up Data".localized(), icon: UIImage(systemName: "icloud.and.arrow.up")),
            MyMenuItem(title: "Feedback".localized(), icon: UIImage(systemName: "bubble.left")),
            MyMenuItem(title: "Rate this App".localized(), icon: UIImage(systemName: "star")),
            MyMenuItem(title: "Share this App".localized(), icon: UIImage(systemName: "square.and.arrow.up")),
            MyMenuItem(title: "More Apps".localized(), icon: UIImage(systemName: "ellipsis")),
        ]
    #endif

    lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).then { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(MenuCell.self, forCellReuseIdentifier: "MenuCell")
        #if !targetEnvironment(macCatalyst)
            tv.register(IAPStatusCell.self, forCellReuseIdentifier: "IAPStatusCell")
        #endif
        tv.rowHeight = UITableView.automaticDimension
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings".localized()

        view.addSubview(tableView)

        #if !targetEnvironment(macCatalyst)
            if !IAPManager.shared.adsRemoved {
                view.addSubview(bannerView)
                bannerView.snp.makeConstraints { make in
                    make.bottom.equalTo(view.safeAreaLayoutGuide)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(50)
                }
            }
            IAPManager.shared.prefetchProduct()
            IAPManager.shared.onProductFetched = { [weak self] in
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        #endif

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    deinit {
        print("MenuController deinit")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if !targetEnvironment(macCatalyst)
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
            if IAPManager.shared.adsRemoved {
                bannerView.removeFromSuperview()
            }
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if !targetEnvironment(macCatalyst)
            ProgressHUD.dismiss()
        #endif
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        #if !targetEnvironment(macCatalyst)
            return 2
        #else
            return 1
        #endif
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        #if !targetEnvironment(macCatalyst)
            if section == 0 { return 1 }
        #endif
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        #if !targetEnvironment(macCatalyst)
            if indexPath.section == 0 { return 70 }
        #endif
        return 62
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        #if !targetEnvironment(macCatalyst)
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "IAPStatusCell", for: indexPath) as! IAPStatusCell
                cell.configure(purchased: IAPManager.shared.adsRemoved, price: IAPManager.shared.localizedPrice)
                return cell
            }
        #endif
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.menuItem = menuItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        #if !targetEnvironment(macCatalyst)
            if section == 0 {
                return IAPManager.shared.adsRemoved ? "Pro Member".localized() : "Upgrade".localized()
            }
        #endif
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        #if !targetEnvironment(macCatalyst)
            if indexPath.section == 0 {
                if !IAPManager.shared.adsRemoved {
                    navigationController?.pushViewController(RemoveAdsViewController(), animated: true)
                }
                return
            }
        #endif

        let row = indexPath.row

        if row == 0 {
            navigationController?.pushViewController(CurrencyViewController(), animated: true)
        }

        if row == 1 {
            navigationController?.pushViewController(CategoryListViewController(isSelectMode: false), animated: true)
        }

        if row == 2 {
            navigationController?.pushViewController(BackupDataViewController(), animated: true)
        }

        if row == 3 {
            navigationController?.pushViewController(FeedbackViewController(), animated: true)
        }

        if row == 4 {
            if let reviewURL = URL(string: "https://itunes.apple.com/app/id\(Constants.AppID.moneyTrackerAppID)?action=write-review"),
               UIApplication.shared.canOpenURL(reviewURL) {
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
            }
        }

        if row == 5 {
            let textToShare = "Money Tracker".localized()
            let image = UIImage(named: "appIcon_money_tracker")!
            if let myWebsite = URL(string: "http://itunes.apple.com/app/id\(Constants.appID)") {
                let objectsToShare = [textToShare, myWebsite, image] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                    popover.sourceView = view
                    popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
                present(activityVC, animated: true)
            }
        }

        #if !targetEnvironment(macCatalyst)
            if row == 6 {
                let alertController = UIAlertController(
                    title: "Support this App".localized(),
                    message: "\("Do you want to watch an advertisement to support this App".localized())?",
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Yes".localized(), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    ProgressHUD.show("Loading the advertisement".localized())
                    GADRewardedAd.load(withAdUnitID: Constants.rewardAdUnitID, request: GADRequest()) { [weak self] ad, error in
                        guard let self = self else { return }
                        ProgressHUD.dismiss()
                        if let error = error {
                            print("Failed to load rewarded ad: \(error)")
                            return
                        }
                        guard let ad = ad else { return }
                        ad.fullScreenContentDelegate = self
                        ad.present(fromRootViewController: self, userDidEarnRewardHandler: {
                            self.userDidEarn = true
                        })
                        self.rewardedAd = ad
                    }
                })
                alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                present(alertController, animated: true)
            }

            if row == 7 {
                navigationController?.pushViewController(MoreAppsViewController(), animated: true)
            }
        #else
            if row == 6 {
                navigationController?.pushViewController(MoreAppsViewController(), animated: true)
            }
        #endif
    }
}

// MARK: - Remove Ads (handled by RemoveAdsViewController)

#if !targetEnvironment(macCatalyst)
    extension MenuViewController: GADFullScreenContentDelegate {
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
            if userDidEarn {
                let ac = UIAlertController(
                    title: "\("Thanks for Your Support".localized())!",
                    message: "\("We will constantly optimize and maintain our App and make sure users have the best experience".localized()).",
                    preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                present(ac, animated: true)
            }
            userDidEarn = false
            rewardedAd = nil
        }

        func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
            print("Rewarded ad failed to present: \(error)")
            rewardedAd = nil
        }
    }
#endif
