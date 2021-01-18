//
//  CurrencyViewController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/7/20.
//

import UIKit
#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif

class CurrencyViewController: UIViewController {
    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()
    #endif

    var currencyCodes = [String]()

    lazy var tableView = UITableView().then { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(CurrencyCell.self, forCellReuseIdentifier: "CurrencyCell")
        tv.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Currencies".localized()

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
            make.edges.equalToSuperview()
        }

        let curr = Locale
            .availableIdentifiers
            .map { Locale(identifier: $0) }
            .filter { $0.currencyCode != nil && $0.currencySymbol != nil }
            .filter { $0.currencyCode! != $0.currencySymbol! }
            .map { $0.currencyCode! }

        currencyCodes = Array(Set(curr))
        currencyCodes.sort()
    }
}

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyCodes.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        cell.currencyCode = currencyCodes[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UserDefaults.standard.set(currencyCodes[indexPath.row], forKey: UserDefaultsKeys.CURRENCY)
        tableView.reloadData()
        (navigationController?.viewControllers[0] as? HomeViewController)?.tableView.reloadData()
    }
}
