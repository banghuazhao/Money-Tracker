//
//  ChartCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import AAInfographics
import SwiftDate
import UIKit

class ChartCell: UITableViewCell {
    var transactions: [Transaction]? {
        didSet {
            refreshChartView()
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
    
    func refreshChartView() {
        guard let transactions = transactions else { return }
        var dates = transactions.map { $0.date }
        dates.reverse()
        var amounts = transactions.map { $0.amount }
        amounts.reverse()
        var datesInMonths = Set<String>()
        for date in dates {
            guard let dateString = date?.toFormat("yyyy-MM") else { return }
            datesInMonths.insert(dateString)
        }
        let xDatas = Array(datesInMonths).sorted { (dateString1, dateString2) -> Bool in
            guard let date1 = dateString1.toDate(), let date2 = dateString2.toDate() else { return true }
            return date1 < date2
        }
        var yDatas: [Double] = Array(repeating: 0, count: xDatas.count)
        for (i, date) in dates.enumerated() {
            guard let dateString = date?.toFormat("yyyy-MM") else { return }
            let index = xDatas.firstIndex(of: dateString) ?? 0
            yDatas[index] += amounts[i]
        }
        if yDatas.count >= 1 {
            for i in 1 ..< yDatas.count {
                yDatas[i] += yDatas[i - 1]
            }
        }
        
        let aaChartModel = AAChartModel()
            .chartType(.areaspline) // Can be any of the chart types listed under `AAChartType`.
            .backgroundColor(AAColor.clear)
            .animationDuration(0)
            .xAxisLabelsEnabled(true)
            .yAxisLabelsEnabled(false)
            .xAxisVisible(true)
            .yAxisVisible(false)
            .dataLabelsEnabled(false)
            .legendEnabled(false)
            .touchEventEnabled(true)
            .markerRadius(8)
            .scrollablePlotArea(
                AAScrollablePlotArea()
                    .minWidth(680)
                    .scrollPositionX(1)
            )
            .categories(xDatas)
            .series([
                AASeriesElement()
                    .name("Net Worth".localized())
                    .lineWidth(6)
                    .data(yDatas),
            ])
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
    }
}
