//
//  PieChartViewController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/6/20.
//

import AAInfographics
import Localize_Swift
import Sheeeeeeeeet
import SnapKit
import Then
import UIKit

protocol PieChartViewControllerDelegate: class {
    func didEditOrDeleteUserTransactionFromPieChart()
}

class PieChartViewController: UIViewController {
    weak var delegate: PieChartViewControllerDelegate?

    var transactionCategories: [TransactionCategory] = []
    var transactions: [Transaction] = []
    var currentTransactions: [Transaction] = []

    var reloadChartView: Bool = true
    var isExpense: Bool = true

    var selectedTime = "All".localized()

    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(PieChartCell.self, forCellReuseIdentifier: "PieChartCell")
        tv.register(SingleTitleCell.self, forCellReuseIdentifier: "SingleTitleCell")
        tv.register(TransactionCategoryCell.self, forCellReuseIdentifier: "TransactionCategoryCell")
        tv.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        fetchTransactionCategories()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
            style: .plain,
            target: self,
            action: #selector(tapDetailButton(_:)))
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func fetchTransactionCategories() {
        transactions = CoreDataManager.shared.fetchLocalTransactions()
        currentTransactions = transactions
        if selectedTime == "All".localized() {
            currentTransactions = transactions
        } else {
            currentTransactions = []
            for transaction in transactions {
                if let dateString = transaction.date?.toFormat("yyyy-MM"), dateString == selectedTime {
                    currentTransactions.append(transaction)
                }
            }
        }

        if isExpense {
            transactionCategories = categoryExpenses.map({ (category) -> TransactionCategory in
                TransactionCategory(category: category)
            })

            for transaction in currentTransactions {
                if let category = transaction.category, let index = categoryExpenses.firstIndex(of: category) {
                    transactionCategories[index].amount += transaction.amount
                }
            }
        } else {
            transactionCategories = categoryIncomes.map({ (category) -> TransactionCategory in
                TransactionCategory(category: category)
            })
            for transaction in currentTransactions {
                if let category = transaction.category, let index = categoryIncomes.firstIndex(of: category) {
                    transactionCategories[index].amount += transaction.amount
                }
            }
        }

        transactionCategories = transactionCategories.filter { fabs($0.amount) > 0 }
        transactionCategories.sort { fabs($0.amount) > fabs($1.amount) }
    }
}

// MARK: - actions

extension PieChartViewController {
    @objc func tapDetailButton(_ sender: UIBarButtonItem) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        var items: [MenuItem] = []

        let item = SingleSelectItem(title: "All".localized(), isSelected: selectedTime == "All".localized(), image: nil)
        items.append(item)

        var dates = [Date]()
        if isExpense {
            dates = transactions.compactMap { transaction in
                if let category = transaction.category, categoryExpenses.contains(category) {
                    return transaction.date
                }
                return nil
            }

        } else {
            dates = transactions.compactMap { transaction in
                if let category = transaction.category, categoryIncomes.contains(category) {
                    return transaction.date
                }
                return nil
            }
        }

        var datesInMonthsSet = Set<String>()
        for date in dates {
            let dateString = date.toFormat("yyyy-MM")
            datesInMonthsSet.insert(dateString)
        }
        let datesInMonths = Array(datesInMonthsSet).sorted { (dateString1, dateString2) -> Bool in
            if let date1 = dateString1.toDate(), let date2 = dateString2.toDate() {
                return date1 > date2
            }
            return true
        }

        for dateString in datesInMonths {
            let item = SingleSelectItem(title: dateString, isSelected: selectedTime == dateString, image: nil)
            items.append(item)
        }

        let cancelButton = CancelButton(title: "Cancel".localized())
        items.append(cancelButton)
        let menu = Menu(title: "Select a Date".localized(), items: items)

        let sheet = menu.toActionSheet { [weak self] _, item in
            guard let self = self else { return }
            guard item.title != "Cancel".localized() && item.title != "Select a Date".localized() else { return }
            let title = item.title
            self.selectedTime = title
            self.fetchTransactionCategories()
            self.reloadChartView = true
            self.tableView.reloadData()
        }
        sheet.present(in: self, from: sender)
    }
}

// MARK: - tableView

extension PieChartViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return transactionCategories.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 400
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "PieChartCell") as! PieChartCell
                if reloadChartView {
                    cell.selectedTime = selectedTime
                    cell.transactionCategories = transactionCategories
                }
                reloadChartView = false
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SingleTitleCell") as! SingleTitleCell
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCategoryCell") as! TransactionCategoryCell
            cell.transactionCategory = transactionCategories[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let singleCategoryViewController = SingleCategoryViewController()
            singleCategoryViewController.category = transactionCategories[indexPath.row].category
            singleCategoryViewController.delegate = self
            navigationController?.pushViewController(singleCategoryViewController, animated: true)
        }
    }
}

// MARK: - SingleCategoryViewControllerDelegate

extension PieChartViewController: SingleCategoryViewControllerDelegate {
    func didEditOrDeleteUserTransactionFromSingleCategory() {
        fetchTransactionCategories()
        reloadChartView = true
        tableView.reloadData()
        delegate?.didEditOrDeleteUserTransactionFromPieChart()
    }
}
