//
//  TransactionCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import SwiftDate
import UIKit

class TransactionCell: UITableViewCell {
    var transaction: Transaction? {
        didSet {
            guard let transaction = transaction, let category = transaction.category else { return }
            categoryImageView.image = UIImage(named: category)
            categoryLabel.text = transaction.category?.localized()
            titleLabel.text = transaction.title
            if transaction.title == "" {
                categoryLabel.snp.remakeConstraints { make in
                    make.centerY.equalTo(categoryImageView)
                    make.left.equalTo(categoryImageView.snp.right).offset(15)
                    make.right.equalTo(amountLabel.snp.left)
                }
                titleLabel.snp.remakeConstraints { make in
                    make.centerY.equalTo(categoryImageView)
                    make.left.equalTo(categoryImageView.snp.right).offset(15)
                    make.right.equalTo(amountLabel.snp.left)
                }
            } else {
                categoryLabel.snp.remakeConstraints { make in
                    make.top.equalTo(categoryImageView)
                    make.left.equalTo(categoryImageView.snp.right).offset(15)
                    make.right.equalTo(amountLabel.snp.left)
                }

                titleLabel.snp.remakeConstraints { make in
                    make.top.equalTo(categoryLabel.snp.bottom).offset(5)
                    make.left.equalTo(categoryImageView.snp.right).offset(15)
                    make.right.equalTo(amountLabel.snp.left)
                }
            }

            amountLabel.text = convertDoubleToCurrency(amount: transaction.amount)
            if categoryExpenses.contains(category) {
                amountLabel.textColor = UIColor.label
            } else {
                amountLabel.textColor = UIColor.incomeGreen
            }
            dateLabel.text = transaction.date?.toFormat("yyyy-MM-dd")
        }
    }

    lazy var categoryImageView = UIImageView().then { _ in
    }

    lazy var categoryLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.label
        label.numberOfLines = 1
    }

    lazy var titleLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 1
    }

    lazy var amountLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.label
        label.numberOfLines = 1
        label.textAlignment = .right
    }

    lazy var dateLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 1
        label.textAlignment = .right
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        contentView.addSubview(categoryImageView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(dateLabel)

        categoryImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
            make.left.equalToSuperview().offset(15)
        }

        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryImageView)
            make.left.equalTo(categoryImageView.snp.right).offset(15)
            make.right.equalTo(amountLabel.snp.left)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(5)
            make.left.equalTo(categoryImageView.snp.right).offset(15)
            make.right.equalTo(amountLabel.snp.left)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryImageView)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(100)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(100)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
