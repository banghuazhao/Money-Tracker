//
//  ListViewController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/6/20.
//

import Localize_Swift
import Sheeeeeeeeet
import SnapKit
import SwiftDate
import UIKit

protocol ListViewControllerDelegate: class {
    func didEditOrDeleteUserTransactionFromList()
}

class ListViewController: UIViewController {
    weak var delegate: ListViewControllerDelegate?

    var transactions: [Transaction] = []
    var selectedTransctions: [Transaction] = []
    var isSearching: Bool = false
    var searchText: String = ""
    var searchedTransactions: [Transaction] = []
    var sortIndex: Int = 0

    lazy var searchController = UISearchController().then { sc in
        sc.searchBar.delegate = self
        sc.searchBar.placeholder = "Search a transaction".localized()
        sc.searchBar.searchBarStyle = .minimal
    }

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
        title = "List".localized()
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
            style: .plain,
            target: self,
            action: #selector(tapSortButton(_:)))
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
        selectedTransctions = transactions
        sortTransactions()
    }

    private func sortTransactions() {
        switch sortIndex {
        case 0:
            if transactions.count > 1 {
                transactions.sort { (t1, t2) -> Bool in
                    guard let date1 = t1.date, let date2 = t2.date else { return true }
                    return date1 > date2
                }
            }
            if selectedTransctions.count > 1 {
                selectedTransctions.sort { (t1, t2) -> Bool in
                    guard let date1 = t1.date, let date2 = t2.date else { return true }
                    return date1 > date2
                }
            }
            if searchedTransactions.count > 1 {
                searchedTransactions.sort { (t1, t2) -> Bool in
                    guard let date1 = t1.date, let date2 = t2.date else { return true }
                    return date1 > date2
                }
            }
        case 1:
            if transactions.count > 1 {
                transactions.sort { (t1, t2) -> Bool in
                    guard let date1 = t1.date, let date2 = t2.date else { return true }
                    return date1 < date2
                }
            }
            if selectedTransctions.count > 1 {
                selectedTransctions.sort { (t1, t2) -> Bool in
                    guard let date1 = t1.date, let date2 = t2.date else { return true }
                    return date1 < date2
                }
            }
            if searchedTransactions.count > 1 {
                searchedTransactions.sort { (t1, t2) -> Bool in
                    guard let date1 = t1.date, let date2 = t2.date else { return true }
                    return date1 < date2
                }
            }
        case 2:
            if transactions.count > 1 {
                transactions.sort { (t1, t2) -> Bool in
                    t1.amount > t2.amount
                }
            }
            if selectedTransctions.count > 1 {
                selectedTransctions.sort { (t1, t2) -> Bool in
                    t1.amount > t2.amount
                }
            }
            if searchedTransactions.count > 1 {
                searchedTransactions.sort { (t1, t2) -> Bool in
                    t1.amount > t2.amount
                }
            }
        case 3:
            if transactions.count > 1 {
                transactions.sort { (t1, t2) -> Bool in
                    t1.amount < t2.amount
                }
            }
            if selectedTransctions.count > 1 {
                selectedTransctions.sort { (t1, t2) -> Bool in
                    t1.amount < t2.amount
                }
            }
            if searchedTransactions.count > 1 {
                searchedTransactions.sort { (t1, t2) -> Bool in
                    t1.amount < t2.amount
                }
            }
        default:
            break
        }
    }
}

// MARK: - tableView

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchedTransactions.count
        } else {
            return selectedTransctions.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
            cell.transaction = searchedTransactions[indexPath.row]
            cell.searchText = searchText
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
            cell.transaction = selectedTransctions[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearching {
            let addOrEditTransactionViewController = AddOrEditTransactionViewController()
            addOrEditTransactionViewController.isAdd = false
            addOrEditTransactionViewController.transaction = searchedTransactions[indexPath.row]
            addOrEditTransactionViewController.delegate = self
            navigationController?.pushViewController(addOrEditTransactionViewController, animated: true)
        } else {
            let addOrEditTransactionViewController = AddOrEditTransactionViewController()
            addOrEditTransactionViewController.isAdd = false
            addOrEditTransactionViewController.transaction = selectedTransctions[indexPath.row]
            addOrEditTransactionViewController.delegate = self
            navigationController?.pushViewController(addOrEditTransactionViewController, animated: true)
        }
    }
}

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if searchText != "" {
            searchedTransactions = selectedTransctions.filter({ (selectedTransction) -> Bool in
                if let category = selectedTransction.category?.localized(),
                   category.lowercased().contains(searchText.lowercased()) {
                    return true
                }
                if let title = selectedTransction.title, title.lowercased().contains(searchText.lowercased()) {
                    return true
                }
                return false
            })

            isSearching = true
        } else {
            isSearching = false
        }
        tableView.reloadData()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchText
        if searchBar.text == "" {
            isSearching = false
            tableView.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchText = ""
        searchBar.text = ""
        tableView.reloadData()
    }
}

// MARK: - actions

extension ListViewController {
    @objc func tapSortButton(_ sender: UIBarButtonItem) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let itemTitles = [
            "Date: New to Old".localized(),
            "Date: Old to New".localized(),
            "Amount: High to Low".localized(),
            "Amount: Low to High".localized(),
        ]
        var items: [MenuItem] = []
        for (i, itemTitle) in itemTitles.enumerated() {
            let item = SingleSelectItem(title: itemTitle, isSelected: i == sortIndex, image: nil)
            items.append(item)
        }

        let cancelButton = CancelButton(title: "Cancel".localized())
        items.append(cancelButton)
        let menu = Menu(title: "Sort By".localized(), items: items)

        let sheet = menu.toActionSheet { [weak self] _, item in
            guard let self = self else { return }
            guard item.title != "Cancel".localized() && item.title != "Sort By".localized() else { return }
            let title = item.title
            self.sortIndex = itemTitles.firstIndex(of: title)!
            self.sortTransactions()
            self.tableView.reloadData()
        }

        sheet.present(in: self, from: sender)
    }
}

// MARK: - AddOrEditTransactionViewControllerDelegate

extension ListViewController: AddOrEditTransactionViewControllerDelegate {
    func didAddUserTransaction() {
        fetchTransactions()
        isSearching = false
        searchText = ""
        searchController.searchBar.text = ""
        tableView.reloadData()
        delegate?.didEditOrDeleteUserTransactionFromList()
    }

    func didEditUserTransaction() {
        fetchTransactions()
        isSearching = false
        searchText = ""
        searchController.searchBar.text = ""
        tableView.reloadData()
        delegate?.didEditOrDeleteUserTransactionFromList()
    }

    func didDeleteUserTransaction() {
        fetchTransactions()
        isSearching = false
        searchText = ""
        searchController.searchBar.text = ""
        tableView.reloadData()
        delegate?.didEditOrDeleteUserTransactionFromList()
    }
}
