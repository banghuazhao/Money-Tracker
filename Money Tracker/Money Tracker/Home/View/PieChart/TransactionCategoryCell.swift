//
//  TransactionCategoryCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import SwiftDate
import UIKit

class TransactionCategoryCell: UITableViewCell {
    var transactionCategory: TransactionCategory? {
        didSet {
            guard let transactionCategory = transactionCategory else { return }
            categoryLabel.text = transactionCategory.category.localized()
            amountLabel.text = convertDoubleToCurrency(amount: transactionCategory.amount)
            categoryImageView.image = UIImage(named: transactionCategory.category)
            if categoryExpenses.contains(transactionCategory.category) {
                amountLabel.textColor = UIColor.label
            } else {
                amountLabel.textColor = UIColor.incomeGreen
            }
        }
    }

    lazy var categoryImageView = UIImageView().then { _ in
    }

    lazy var categoryLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.label
        label.numberOfLines = 1
    }

    lazy var amountLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.label
        label.numberOfLines = 1
        label.textAlignment = .right
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        accessoryType = .disclosureIndicator

        contentView.addSubview(categoryImageView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(amountLabel)

        categoryImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
            make.left.equalToSuperview().offset(15)
        }

        categoryLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(categoryImageView)
            make.left.equalTo(categoryImageView.snp.right).offset(15)
            make.right.equalTo(amountLabel.snp.left)
        }

        amountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(categoryImageView)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(100)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
