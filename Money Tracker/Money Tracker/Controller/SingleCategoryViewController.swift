//
//  SingleCategoryViewController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/6/20.
//

import Localize_Swift
import Sheeeeeeeeet
import SnapKit
import SwiftDate
import UIKit

protocol SingleCategoryViewControllerDelegate: class {
    func didEditOrDeleteUserTransactionFromSingleCategory()
}

class SingleCategoryViewController: UIViewController {
    weak var delegate: SingleCategoryViewControllerDelegate?

    var category: String = ""
    var transactions: [Transaction] = []

    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tv.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupNavigationBar()
        setupViews()
        fetchTransactions()
    }

    private func setupNavigationBar() {
        title = category.localized()
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func fetchTransactions() {
        transactions = CoreDataManager.shared.fetchLocalTransactions().filter({ (transaction) -> Bool in
            transaction.category == category
        })
        if transactions.count > 1 {
            transactions.sort { (t1, t2) -> Bool in
                guard let date1 = t1.date, let date2 = t2.date else { return true }
                return date1 > date2
            }
        }
    }
}

// MARK: - tableView

extension SingleCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
        cell.transaction = transactions[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let addOrEditTransactionViewController = AddOrEditTransactionViewController()
        addOrEditTransactionViewController.isAdd = false
        addOrEditTransactionViewController.transaction = transactions[indexPath.row]
        addOrEditTransactionViewController.delegate = self
        navigationController?.pushViewController(addOrEditTransactionViewController, animated: true)
    }
}

// MARK: - AddOrEditTransactionViewControllerDelegate

extension SingleCategoryViewController: AddOrEditTransactionViewControllerDelegate {
    func didAddOrEditUserTransaction() {
        fetchTransactions()
        tableView.reloadData()
        delegate?.didEditOrDeleteUserTransactionFromSingleCategory()
    }

    func didDeleteUserTransaction() {
        didAddOrEditUserTransaction()
    }
}
