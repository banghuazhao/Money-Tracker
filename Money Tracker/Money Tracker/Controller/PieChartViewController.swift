//
//  PieChartViewController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/6/20.
//

import AAInfographics
import Localize_Swift
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

    var reloadChartView: Bool = true
    var isExpense: Bool = true

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
        title = "Pie Chart".localized()
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
        if isExpense {
            transactionCategories = categoryExpenses.map({ (category) -> TransactionCategory in
                TransactionCategory(category: category)
            })

            for transaction in transactions {
                if let category = transaction.category, let index = categoryExpenses.firstIndex(of: category) {
                    transactionCategories[index].amount += transaction.amount
                }
            }
        } else {
            transactionCategories = categoryIncomes.map({ (category) -> TransactionCategory in
                TransactionCategory(category: category)
            })
            for transaction in transactions {
                if let category = transaction.category, let index = categoryIncomes.firstIndex(of: category) {
                    transactionCategories[index].amount += transaction.amount
                }
            }
        }
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
