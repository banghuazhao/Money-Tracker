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

protocol BarChartViewControllerDelegate: class {
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


    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        fetchTransactionCategories()
        drawBarChart()
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
        view.addSubview(barChartView)
        barChartView.snp.makeConstraints { (make) in
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
    
    private func drawBarChart() {
        
        var datas: [[Any]] = []
        for transactionCategory in transactionCategories {
            let name = transactionCategory.category.localized()
            datas.append([name, fabs(transactionCategory.amount)])
        }
        
        let aaOptions = AAOptions()
            .chart(AAChart()
                .type(AAChartType.bar)
//                .scrollablePlotArea(
//                    AAScrollablePlotArea()
//                        .minHeight(1300)
//            )
            )
            .title(AATitle()
                .text("\("Date".localized()): \(selectedTime)"))
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
            self.drawBarChart()
        }
        sheet.present(in: self, from: sender)
    }
}
