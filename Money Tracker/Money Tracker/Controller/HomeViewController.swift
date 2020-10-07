//
//  HomeViewController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import AAInfographics
import GoogleMobileAds
import Localize_Swift
import Sheeeeeeeeet
import SnapKit
import SwiftDate
import Then
import UIKit

class HomeViewController: UIViewController {
    var interstitial = GADInterstitial(adUnitID: Constants.interstitialAdID)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        interstitial = GADInterstitial(adUnitID: Constants.interstitialAdID)
        interstitial.load(GADRequest())
        setupNavigationBar()
        setupViews()
        fetchTransactions()
    }

    private func setupNavigationBar() {
        title = "Net Worth".localized()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
            style: .plain,
            target: self,
            action: #selector(tapMenuButton(_:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.square.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
            style: .plain,
            target: self,
            action: #selector(tapAddButton(_:)))
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
                return 70
            } else if indexPath.row == 1 {
                return 280
            } else {
                return 50
            }
        } else {
            return 70
        }
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
}

// MARK: - actions

extension HomeViewController {
    @objc func tapMenuButton(_ sender: UIBarButtonItem) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        navigationController?.pushViewController(MenuViewController(), animated: true)
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
            guard item.title != "Cancel".localized() else { return }
            let title = item.title
            if title == "List".localized() {
                let listViewController = ListViewController()
                listViewController.delegate = self
                self.navigationController?.pushViewController(listViewController, animated: true)
            } else if title == "Pie Chart (Expense)".localized() {
                let pieChartViewController = PieChartViewController()
                pieChartViewController.isExpense = true
                pieChartViewController.delegate = self
                self.navigationController?.pushViewController(pieChartViewController, animated: true)
            } else if title == "Pie Chart (Income)".localized() {
                let pieChartViewController = PieChartViewController()
                pieChartViewController.isExpense = false
                pieChartViewController.delegate = self
                self.navigationController?.pushViewController(pieChartViewController, animated: true)
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
    func didAddOrEditUserTransaction() {
        fetchTransactions()
        tableView.reloadData()
        let randomNum = Int.random(in: 0 ... 1)
        if randomNum == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.interstitial.isReady {
                    self.interstitial.present(fromRootViewController: self)
                    print("interstitial Ad is ready")
                } else {
                    print("interstitial Ad wasn't ready")
                }
                self.interstitial = GADInterstitial(adUnitID: Constants.interstitialAdID)
                self.interstitial.load(GADRequest())
            }
        }
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
