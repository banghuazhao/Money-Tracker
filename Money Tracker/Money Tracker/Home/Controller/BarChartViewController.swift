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

protocol BarChartViewControllerDelegate: AnyObject {
    func didEditOrDeleteUserTransactionFromPieChart()
}

class BarChartViewController: UIViewController {
    weak var delegate: BarChartViewControllerDelegate?

    var transactionCategories: [TransactionCategory] = []
    var transactions: [Transaction] = []
    var currentTransactions: [Transaction] = []

    var isExpense: Bool = true

    var selectedTime = "All".localized()

    private var barChartView = AAChartView()

    // 0 = group by category, 1 = group by day (daily spending statistics)
    private lazy var modeSegment = UISegmentedControl(items: ["By Category".localized(), "By Day".localized()]).then { sc in
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(tapModeSegment), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        fetchTransactionCategories()
        drawChart()
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
        view.addSubview(modeSegment)
        view.addSubview(barChartView)
        modeSegment.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        barChartView.snp.makeConstraints { make in
            make.top.equalTo(modeSegment.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }

    @objc private func tapModeSegment() {
        UISelectionFeedbackGenerator().selectionChanged()
        drawChart()
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
    
    private func drawChart() {
        if modeSegment.selectedSegmentIndex == 1 {
            drawDailyChart()
        } else {
            drawCategoryChart()
        }
    }

    private func drawCategoryChart() {
        var datas: [[Any]] = []
        for transactionCategory in transactionCategories {
            let name = transactionCategory.category.localized()
            datas.append([name, fabs(transactionCategory.amount)])
        }

        let total = transactionCategories.reduce(0) { $0 + fabs($1.amount) }

        let aaOptions = AAOptions()
            .chart(AAChart()
                .type(AAChartType.bar))
            .title(AATitle()
                .text("\("Date".localized()): \(selectedTime)"))
            .subtitle(AASubtitle()
                .text("\("Total".localized()): \(convertDoubleToCurrency(amount: total))"))
            .xAxis(AAXAxis()
                .type("category"))
            .series([
                AASeriesElement()
                    .name(isExpense ? "Expense".localized() : "Income".localized())
                    .data(datas)])
        barChartView.aa_drawChartWithChartOptions(aaOptions)
    }

    /// Daily spending statistics: sums each day's amount across the selected period.
    private func drawDailyChart() {
        var totalsByDay: [String: Double] = [:]
        for transaction in currentTransactions {
            guard let category = transaction.category, let date = transaction.date else { continue }
            let isExpenseCategory = categoryExpenses.contains(category)
            guard isExpenseCategory == isExpense else { continue }
            let day = date.toFormat("yyyy-MM-dd")
            totalsByDay[day, default: 0] += fabs(transaction.amount)
        }

        let sortedDays = totalsByDay.keys.sorted { ($0.toDate()?.date ?? Date()) < ($1.toDate()?.date ?? Date()) }
        let datas: [[Any]] = sortedDays.map { [$0, totalsByDay[$0] ?? 0] }
        let total = totalsByDay.values.reduce(0, +)

        let aaOptions = AAOptions()
            .chart(AAChart()
                .type(AAChartType.column)
                .scrollablePlotArea(
                    AAScrollablePlotArea()
                        .minWidth(max(sortedDays.count * 44, Int(view.bounds.width)))
                        .scrollPositionX(1)))
            .title(AATitle()
                .text("\("Daily".localized()) · \(selectedTime)"))
            .subtitle(AASubtitle()
                .text("\("Total".localized()): \(convertDoubleToCurrency(amount: total))"))
            .xAxis(AAXAxis()
                .type("category"))
            .series([
                AASeriesElement()
                    .name(isExpense ? "Expense".localized() : "Income".localized())
                    .data(datas)])
        barChartView.aa_drawChartWithChartOptions(aaOptions)
    }
}

// MARK: - actions

extension BarChartViewController {
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
            self.drawChart()
        }
        sheet.present(in: self, from: sender)
    }
}
