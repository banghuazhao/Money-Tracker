//
//  RemoveAdsViewController.swift
//  Money Tracker
//

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
    import ProgressHUD
#endif
import SnapKit
import Then
import UIKit

#if !targetEnvironment(macCatalyst)
    class RemoveAdsViewController: UIViewController {
        private enum Row: Int, CaseIterable {
            case removeAds
            case restorePurchase
        }

        private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).then { tv in
            tv.delegate = self
            tv.dataSource = self
            tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Remove Ads".localized()
            view.backgroundColor = .systemGroupedBackground
            view.addSubview(tableView)
            tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

            IAPManager.shared.prefetchProduct()
            IAPManager.shared.onProductFetched = { [weak self] in
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
    }

    // MARK: - UITableViewDataSource / Delegate

    extension RemoveAdsViewController: UITableViewDataSource, UITableViewDelegate {
        func numberOfSections(in tableView: UITableView) -> Int { 2 }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            section == 0 ? Row.allCases.count : 0
        }

        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            section == 1 ? "Purchase Notes".localized() : nil
        }

        func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            guard section == 1 else { return nil }
            return [
                "•" + " " + "After purchase, all of the Ads will be removed immediately.".localized(),
                "•" + " " + "The purchase is valid across different devices (iPhone, iPad, Mac) for the same Apple ID.".localized(),
                "•" + " " + "If users change a device or reinstall this App, restore purchase will store their previous purchase.".localized(),
            ].joined(separator: "\n")
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            switch Row(rawValue: indexPath.row)! {
            case .removeAds:
                config.text = "Remove Ads forever".localized()
                if let price = IAPManager.shared.localizedPrice {
                    config.secondaryText = price
                    config.secondaryTextProperties.color = .secondaryLabel
                }
            case .restorePurchase:
                config.text = "Restore purchase".localized()
            }
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            switch Row(rawValue: indexPath.row)! {
            case .removeAds:
                startPurchase()
            case .restorePurchase:
                startRestore()
            }
        }

        // MARK: - IAP

        private func startPurchase() {
            ProgressHUD.show("Processing...".localized())
            IAPManager.shared.onPurchaseComplete = { [weak self] in
                ProgressHUD.dismiss()
                self?.adsRemovedDidSucceed()
            }
            IAPManager.shared.onFailed = { [weak self] message in
                ProgressHUD.dismiss()
                self?.showError(message)
            }
            IAPManager.shared.purchaseRemoveAds()
        }

        private func startRestore() {
            ProgressHUD.show("Restoring...".localized())
            IAPManager.shared.onRestoreComplete = { [weak self] in
                ProgressHUD.dismiss()
                self?.adsRemovedDidSucceed()
            }
            IAPManager.shared.onRestoreEmpty = { [weak self] in
                ProgressHUD.dismiss()
                self?.showError("No previous purchase found for this Apple ID.".localized())
            }
            IAPManager.shared.onFailed = { [weak self] message in
                ProgressHUD.dismiss()
                self?.showError(message)
            }
            IAPManager.shared.restorePurchases()
        }

        private func adsRemovedDidSucceed() {
            let ac = UIAlertController(
                title: "Ads Removed!".localized(),
                message: "Thank you! All ads have been removed.".localized(),
                preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK".localized(), style: .cancel) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(ac, animated: true)
        }

        private func showError(_ message: String) {
            let ac = UIAlertController(title: "Purchase Failed".localized(), message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
            present(ac, animated: true)
        }
    }
#endif
