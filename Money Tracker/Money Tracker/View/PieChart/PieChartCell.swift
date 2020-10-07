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
    var transactionCategories: [TransactionCategory]? {
        didSet {
            guard let transactionCategories = transactionCategories else { return }
            var datas: [[Any]] = []
            for transactionCategory in transactionCategories {
                datas.append([transactionCategory.category.localized(), fabs(transactionCategory.amount)])
            }

            var name = "Expense".localized()
            if transactionCategories.count < 10 {
                name = "Income".localized()
            }

            let aaChartModel = AAChartModel()
                .chartType(.pie)
                .backgroundColor(AAColor.clear)
//                .title("Shares")
//                .dataLabelsEnabled(true) // 是否直接显示扇形图数据
                .yAxisTitle("℃")
                .legendEnabled(false)
                .series([
                    AASeriesElement()
                        .name(name)
                        .dataLabels(
                            AADataLabels()
                                .enabled(false))
                        .innerSize("38.2%") // 内部圆环半径大小占比(内部圆环半径/扇形图半径),
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

    lazy var aaChartView = AAChartView().then { (chartView) in
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
