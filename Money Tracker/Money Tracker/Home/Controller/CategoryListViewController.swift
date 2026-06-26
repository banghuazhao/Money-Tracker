//
//  CategoryListViewController.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

protocol CategoryListViewControllerDelegate: AnyObject {
    func categoryList(_ vc: CategoryListViewController, didSelect name: String)
}

class CategoryListViewController: UIViewController {
    weak var delegate: CategoryListViewControllerDelegate?

    // When true, the VC is used for selection inside AddOrEditTransaction
    private let isSelectMode: Bool
    // Tracks which tab is active
    private var showingUser = false
    // Filter: nil = all (used in manage mode), false = expense, true = income
    private var filterIncome: Bool?

    private lazy var segmentControl = UISegmentedControl(items: [
        "Common".localized(), "User".localized(),
    ]).then { sc in
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then { tv in
        tv.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = 58
        tv.tableFooterView = UIView()
    }

    private lazy var addButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain, target: self, action: #selector(tapAdd)
    )


    // MARK: - Data

    private var commonItems: [String] = []
    private var userItems: [UserCategory] = []

    init(isSelectMode: Bool, filterIncome: Bool? = nil) {
        self.isSelectMode = isSelectMode
        self.filterIncome = filterIncome
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Category".localized()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        let titleView = UIView()
        titleView.addSubview(segmentControl)
        segmentControl.snp.makeConstraints { $0.edges.equalToSuperview() }
        navigationItem.titleView = titleView

        updateBarButtons()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    // MARK: - Data

    private func reloadData() {
        if showingUser {
            let all = UserCategoryManager.shared.fetchAll()
            if let income = filterIncome {
                userItems = all.filter { $0.isIncome == income }
            } else {
                userItems = all
            }
        } else {
            if filterIncome == true {
                commonItems = categoryIncomes
            } else if filterIncome == false {
                commonItems = categoryExpenses
            } else {
                commonItems = categoryExpenses + categoryIncomes
            }
        }
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        showingUser = segmentControl.selectedSegmentIndex == 1
        updateBarButtons()
        reloadData()
    }

    private func updateBarButtons() {
        navigationItem.rightBarButtonItems = showingUser ? [addButton] : []
    }

    @objc private func tapAdd() {
        let vc = CreateOrEditCategoryViewController(existing: nil, defaultIncome: filterIncome ?? false)
        vc.onSave = { [weak self] in self?.reloadData() }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showingUser ? userItems.count : commonItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        if showingUser {
            cell.configureUser(userItems[indexPath.row])
        } else {
            cell.configureCommon(name: commonItems[indexPath.row])
        }
        cell.accessoryType = isSelectMode ? .none : .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let name: String
        if showingUser {
            guard let catName = userItems[indexPath.row].name else { return }
            name = catName
        } else {
            name = commonItems[indexPath.row]
        }

        if isSelectMode {
            delegate?.categoryList(self, didSelect: name)
            navigationController?.popViewController(animated: true)
        } else if showingUser {
            let cat = userItems[indexPath.row]
            let vc = CreateOrEditCategoryViewController(existing: cat, defaultIncome: cat.isIncome)
            vc.onSave = { [weak self] in self?.reloadData() }
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        showingUser
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let cat = userItems[indexPath.row]
        UserCategoryManager.shared.delete(cat)
        userItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
