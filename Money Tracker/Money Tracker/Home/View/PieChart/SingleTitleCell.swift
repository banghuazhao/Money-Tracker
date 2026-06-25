//
//  SingleTitleCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/6/20.
//

import SnapKit
import Then
import UIKit

class SingleTitleCell: UITableViewCell {
    private lazy var titleLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = "Categories".localized()
    }

    private lazy var totalLabel = UILabel().then { label in
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .right
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        contentView.addSubview(titleLabel)
        contentView.addSubview(totalLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        totalLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(8)
        }
    }

    /// Shows the summed total of all categories, tinted by income/expense.
    func configure(total: Double, isExpense: Bool) {
        totalLabel.text = "\("Total".localized()): \(convertDoubleToCurrency(amount: total))"
        totalLabel.textColor = isExpense ? .expenseRed : .incomeGreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
