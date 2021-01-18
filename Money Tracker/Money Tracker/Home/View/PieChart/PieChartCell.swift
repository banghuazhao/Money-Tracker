//
//  PieChartCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/6/20.
//

import AAInfographics
import SwiftDate
import UIKit

class PieChartCell: UITableViewCell {
    var selectedTime = "All".localized()

    private let shortWords = [
        "Grocery": "Grocery",
        "Transportation": "Transport",
        "Entertainment": "Entertain",
        "Restaurant": "Restaurant",
        "House Rent": "Rent",
        "Insurance": "Insurance",
        "Travel": "Travel",
        "Education": "Education",
        "Consumer Electronics": "Electronics",
        "Gift": "Gift",
        "Medicine": "Medicine",
        "Other Expense": "Other",
        "Other Income": "Other",
        "Investment Income": "Investment",
    ]

    var transactionCategories: [TransactionCategory]? {
        didSet {
            guard let transactionCategories = transactionCategories else { return }
            var datas: [[Any]] = []
            for transactionCategory in transactionCategories {
                var name = transactionCategory.category.localized()
                if shortWords.keys.contains(name) {
                    name = shortWords[name] ?? name
                }
                datas.append([name, fabs(transactionCategory.amount)])
            }

            var name = "Expense".localized()
            if transactionCategories.count < 10 {
                name = "Income".localized()
            }

            let aaChartModel = AAChartModel()
                .chartType(.pie)
                .backgroundColor(AAColor.clear)
                .title("\("Date".localized()): \(selectedTime)")
                .dataLabelsEnabled(true) // 是否直接显示扇形图数据
                .legendEnabled(false)
                .dataLabelsFontSize(8)
                .series([
                    AASeriesElement()
                        .name(name)
                        .innerSize("20%") // 内部圆环半径大小占比(内部圆环半径/扇形图半径),
                        .allowPointSelect(true)
                        .states(AAStates()
                            .hover(AAHover()
                                .enabled(false) // 禁用点击区块之后出现的半透明遮罩层
                            ))
                        .data(datas)
                    ,
                ])
            aaChartView.aa_drawChartWithChartModel(aaChartModel)
        }
    }

    lazy var aaChartView = AAChartView().then { chartView in
        chartView.isClearBackgroundColor = true
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        contentView.addSubview(aaChartView)
        aaChartView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
