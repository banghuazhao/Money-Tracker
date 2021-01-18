//
//  MoreAppsViewController.swift
//  Financial Statements Go
//
//  Created by Banghua Zhao on 1/1/21.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif
import UIKit

class MoreAppsViewController: UIViewController {
    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()

        let appItems = [
            AppItem(
                title: "Countdown Days".localized(),
                detail: "Events, Anniversary & Big Days".localized(),
                icon: UIImage(named: "appIcon_countdown_days"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.countdownDaysAppID)")),
            AppItem(
                title: "Finance Go".localized(),
                detail: "Financial Reports & Investing".localized(),
                icon: UIImage(named: "appIcon_finance_go"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.financeGoAppID)")),
            AppItem(
                title: "Financial Ratios Go".localized(),
                detail: "Finance, Ratios, Investing".localized(),
                icon: UIImage(named: "appIcon_financial_ratios_go"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.financialRatiosGoAppID)")),
            AppItem(
                title: "More Apps".localized(),
                detail: "Check out more Apps made by us".localized(),
                icon: UIImage(named: "appIcon_appStore"),
                url: URL(string: "https://apps.apple.com/developer/banghua-zhao/id1288052561#see-all")),
        ]
    #else
        let appItems = [
            AppItem(
                title: "Ratios Go (macOS App)".localized(),
                detail: "Finance, Ratios, Investing".localized(),
                icon: UIImage(named: "appIcon_financial_ratios_go"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.finanicalRatiosGoMacOSAppID)")),
            AppItem(
                title: "Countdown Days".localized(),
                detail: "Events, Anniversary & Big Days".localized(),
                icon: UIImage(named: "appIcon_countdown_days"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.countdownDaysAppID)")),
            AppItem(
                title: "Finance Go".localized(),
                detail: "Financial Reports & Investing".localized(),
                icon: UIImage(named: "appIcon_finance_go"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.financeGoAppID)")),
            AppItem(
                title: "Financial Ratios Go".localized(),
                detail: "Finance, Ratios, Investing".localized(),
                icon: UIImage(named: "appIcon_financial_ratios_go"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.financialRatiosGoAppID)")),
            AppItem(
                title: "More Apps".localized(),
                detail: "Check out more Apps made by us".localized(),
                icon: UIImage(named: "appIcon_appStore"),
                url: URL(string: "https://apps.apple.com/developer/banghua-zhao/id1288052561#see-all")),
        ]

    #endif

    lazy var tableView = UITableView().then { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(AppItemCell.self, forCellReuseIdentifier: "AppItemCell")
        tv.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tv.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "More Apps".localized()

        view.addSubview(tableView)

        #if !targetEnvironment(macCatalyst)
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide)
                make.left.right.equalToSuperview()
                make.height.equalTo(50)
            }
        #endif

        tableView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
}

extension MoreAppsViewController {
    @objc func backToHome() {
        dismiss(animated: true, completion: nil)
    }
}

extension MoreAppsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 + 16 + 16
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppItemCell", for: indexPath) as! AppItemCell
        cell.appItem = appItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let appItem = appItems[indexPath.row]
        if let url = appItem.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
