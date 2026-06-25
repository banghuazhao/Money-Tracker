//
//  HomeViewController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif

import AAInfographics
import Localize_Swift
import Sheeeeeeeeet
import SnapKit
import SwiftDate
import Then
import UIKit

class HomeViewController: UIViewController {
    #if !targetEnvironment(macCatalyst)
        var interstitialAd: GADInterstitialAd?

        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()
    #endif
    var transactions: [Transaction] = [] {
        didSet {
            selectedTransactions = transactions
            selectedDateInMonthUnit = "All".localized()
            reloadChartView = true
        }
    }

    var reloadChartView: Bool = false

    var selectedTransactions: [Transaction] = []
    var selectedDateInMonthUnit: String = ""

    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(AmountCell.self, forCellReuseIdentifier: "AmountCell")
        tv.register(ChartCell.self, forCellReuseIdentifier: "ChartCell")
        tv.register(TitleCell.self, forCellReuseIdentifier: "TitleCell")
        tv.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tv.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        return tv
    }()

    private lazy var sampleBanner: UIView = {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground

        let iconLabel = UILabel()
        iconLabel.text = "👋"
        iconLabel.font = .systemFont(ofSize: 22)

        let textLabel = UILabel()
        textLabel.text = "These are sample transactions to show you around. Clear them when you're ready.".localized()
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.textColor = .secondaryLabel
        textLabel.numberOfLines = 2

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear".localized(), for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        clearButton.addTarget(self, action: #selector(tapClearSampleData), for: .touchUpInside)
        clearButton.setContentHuggingPriority(.required, for: .horizontal)

        container.addSubview(iconLabel)
        container.addSubview(textLabel)
        container.addSubview(clearButton)

        iconLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        clearButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        textLabel.snp.makeConstraints { make in
            make.left.equalTo(iconLabel.snp.right).offset(12)
            make.right.equalTo(clearButton.snp.left).offset(-12)
            make.centerY.equalToSuperview()
        }
        return container
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        #if !targetEnvironment(macCatalyst)
            loadInterstitialAd()
        #endif
        setupNavigationBar()
        setupViews()
        fetchTransactions()
        updateSampleBanner()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep the table header (sample banner) width in sync with the table.
        if let header = tableView.tableHeaderView, header.frame.width != tableView.bounds.width {
            header.frame.size.width = tableView.bounds.width
            tableView.tableHeaderView = header
        }
    }

    private func updateSampleBanner() {
        let showBanner = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSampleData)
        if showBanner {
            if tableView.tableHeaderView !== sampleBanner {
                sampleBanner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 64)
                tableView.tableHeaderView = sampleBanner
            }
        } else if tableView.tableHeaderView != nil {
            tableView.tableHeaderView = nil
        }
    }

    @objc private func tapClearSampleData() {
        let alert = UIAlertController(
            title: "Clear sample data?".localized(),
            message: "This removes the example transactions so you can start fresh.".localized(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clear".localized(), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            CoreDataManager.shared.deleteAllTransactions()
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.hasSampleData)
            self.fetchTransactions()
            self.updateSampleBanner()
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }

    private func setupNavigationBar() {
        title = "Net Worth".localized()
        navigationItem.largeTitleDisplayMode = .always

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig),
            style: .plain,
            target: self,
            action: #selector(tapAddButton(_:)))
    }

    private func setupViews() {
        view.backgroundColor = .systemGroupedBackground
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl

        view.addSubview(tableView)

        #if !targetEnvironment(macCatalyst)
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide)
                make.left.right.equalToSuperview()
                make.height.equalTo(50)
            }
            tableView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(bannerView.snp.top)
            }
        #else
            tableView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        #endif
    }

    private func fetchTransactions() {
        transactions = CoreDataManager.shared.fetchLocalTransactions()
        if transactions.count > 1 {
            transactions.sort { (t1, t2) -> Bool in
                guard let date1 = t1.date, let date2 = t2.date else { return true }
                return date1 > date2
            }
        }
    }

    #if !targetEnvironment(macCatalyst)
        private func loadInterstitialAd() {
            GADInterstitialAd.load(
                withAdUnitID: Constants.interstitialAdID,
                request: GADRequest()
            ) { [weak self] ad, error in
                if let error = error {
                    print("Failed to load interstitial ad: \(error)")
                    return
                }
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
            }
        }
    #endif
}

// MARK: - tableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return selectedTransactions.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return UITableView.automaticDimension
            } else if indexPath.row == 1 {
                return 200
            } else {
                return 52
            }
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 { return 110 }
        return 74
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AmountCell") as! AmountCell
                cell.transactions = transactions
                cell.detailButton.addTarget(self, action: #selector(tapDetailButton(_:)), for: .touchUpInside)
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCell") as! ChartCell
                if reloadChartView {
                    cell.transactions = transactions
                    cell.aaChartView.delegate = self
                }
                reloadChartView = false
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") as! TitleCell
                cell.repeatButton.addTarget(self, action: #selector(tapRepeatButton(_:)), for: .touchUpInside)
                cell.rangeLabel.text = selectedDateInMonthUnit
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
            cell.transaction = selectedTransactions[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let addOrEditTransactionViewController = AddOrEditTransactionViewController()
            addOrEditTransactionViewController.isAdd = false
            addOrEditTransactionViewController.transaction = selectedTransactions[indexPath.row]
            addOrEditTransactionViewController.delegate = self
            navigationController?.pushViewController(addOrEditTransactionViewController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 else { return nil }
        let transaction = selectedTransactions[indexPath.row]

        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return completion(false) }
            let context = CoreDataManager.shared.persistentContainer.viewContext
            context.delete(transaction)
            do {
                try context.save()
                self.fetchTransactions()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.reloadSections(IndexSet(integer: 0), with: .none)
            } catch {
                print("Failed to delete transaction:", error)
            }
            completion(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .expenseRed

        let edit = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return completion(false) }
            let vc = AddOrEditTransactionViewController()
            vc.isAdd = false
            vc.transaction = transaction
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            completion(true)
        }
        edit.image = UIImage(systemName: "pencil")
        edit.backgroundColor = .themeColor

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}

// MARK: - actions

extension HomeViewController {
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        fetchTransactions()
        tableView.reloadData()
        sender.endRefreshing()
    }

    @objc func tapAddButton(_ sender: UIBarButtonItem) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let addOrEditTransactionViewController = AddOrEditTransactionViewController()
        addOrEditTransactionViewController.isAdd = true
        addOrEditTransactionViewController.delegate = self
        navigationController?.pushViewController(addOrEditTransactionViewController, animated: true)
    }

    @objc func tapDetailButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let myItems = [
            MyMenuItem(title: "List".localized(), icon: UIImage(systemName: "list.bullet")),
            MyMenuItem(title: "Pie Chart (Expense)".localized(), icon: UIImage(systemName: "chart.pie")),
            MyMenuItem(title: "Pie Chart (Income)".localized(), icon: UIImage(systemName: "chart.pie")),
            MyMenuItem(title: "Bar Chart (Expense)".localized(), icon: UIImage(systemName: "chart.bar")),
            MyMenuItem(title: "Bar Chart (Income)".localized(), icon: UIImage(systemName: "chart.bar")),
        ]

        var items: [MenuItem] = []

        for myItem in myItems {
            let item = MenuItem(title: myItem.title, subtitle: nil, value: nil, image: myItem.icon, isEnabled: true, tapBehavior: .dismiss)
            items.append(item)
        }

        let cancelButton = CancelButton(title: "Cancel".localized())
        items.append(cancelButton)
        let menu = Menu(title: "Choose a Transcation Detail".localized(), items: items)

        let sheet = menu.toActionSheet { [weak self] _, item in
            guard let self = self else { return }
            guard item.title != "Cancel".localized() && item.title != "Choose a Transcation Detail".localized() else { return }
            let title = item.title
            if title == "List".localized() {
                let listViewController = ListViewController()
                listViewController.delegate = self
                self.navigationController?.pushViewController(listViewController, animated: true)
            } else if title == "Pie Chart (Expense)".localized() {
                let pieChartViewController = PieChartViewController()
                pieChartViewController.isExpense = true
                pieChartViewController.delegate = self
                pieChartViewController.title = title
                self.navigationController?.pushViewController(pieChartViewController, animated: true)
            } else if title == "Pie Chart (Income)".localized() {
                let pieChartViewController = PieChartViewController()
                pieChartViewController.isExpense = false
                pieChartViewController.delegate = self
                pieChartViewController.title = title
                self.navigationController?.pushViewController(pieChartViewController, animated: true)
            } else if title == "Bar Chart (Expense)".localized() {
                let barChartViewController = BarChartViewController()
                barChartViewController.isExpense = true
                barChartViewController.title = title
                self.navigationController?.pushViewController(barChartViewController, animated: true)
            } else if title == "Bar Chart (Income)".localized() {
                let barChartViewController = BarChartViewController()
                barChartViewController.isExpense = false
                barChartViewController.title = title
                self.navigationController?.pushViewController(barChartViewController, animated: true)
            }
        }
        sheet.present(in: self, from: sender)
    }

    @objc func tapRepeatButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        selectedTransactions = transactions
        selectedDateInMonthUnit = "All".localized()
        tableView.reloadData()
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ChartCell {
            cell.refreshChartView()
        }
    }
}

// MARK: - AAChartViewDelegate

extension HomeViewController: AAChartViewDelegate {
    func aaChartView(_ aaChartView: AAChartView, moveOverEventMessage: AAMoveOverEventMessageModel) {
        guard let dateString = moveOverEventMessage.category else { return }
        selectedTransactions = transactions.filter({ (transaction) -> Bool in
            guard let tempDateString = transaction.date?.toFormat("yyyy-MM") else { return false }
            return dateString == tempDateString
        })
        selectedDateInMonthUnit = dateString
        tableView.reloadData()
    }
}

// MARK: - AddOrEditTransactionViewControllerDelegate

extension HomeViewController: AddOrEditTransactionViewControllerDelegate {
    func didAddUserTransaction() {
        fetchTransactions()
        updateSampleBanner()
        tableView.reloadData()

        #if !targetEnvironment(macCatalyst)
            if InterstitialAdsRequestHelper.increaseRequestAndCheckLoadInterstitialAd() {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.5))
                    guard let ad = interstitialAd else {
                        print("interstitial Ad wasn't ready")
                        return
                    }
                    ad.present(fromRootViewController: self)
                    print("interstitial Ad is ready")
                    InterstitialAdsRequestHelper.resetRequestCount()
                }
            }
        #endif
    }

    func didEditUserTransaction() {
        fetchTransactions()
        tableView.reloadData()
    }

    func didDeleteUserTransaction() {
        fetchTransactions()
        tableView.reloadData()
    }
}

// MARK: - ListViewControllerDelegate

extension HomeViewController: ListViewControllerDelegate {
    func didEditOrDeleteUserTransactionFromList() {
        fetchTransactions()
        tableView.reloadData()
    }
}

// MARK: - PieChartViewControllerDelegate

extension HomeViewController: PieChartViewControllerDelegate {
    func didEditOrDeleteUserTransactionFromPieChart() {
        fetchTransactions()
        tableView.reloadData()
    }
}

// MARK: - GADFullScreenContentDelegate

#if !targetEnvironment(macCatalyst)
    extension HomeViewController: GADFullScreenContentDelegate {
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
            interstitialAd = nil
            loadInterstitialAd()
        }

        func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
            print("Interstitial ad failed to present: \(error)")
            interstitialAd = nil
            loadInterstitialAd()
        }
    }
#endif
