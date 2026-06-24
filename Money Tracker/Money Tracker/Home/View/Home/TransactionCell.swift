//
//  TransactionCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import SnapKit
import SwiftDate
import Then
import UIKit

class TransactionCell: UITableViewCell {
    var transaction: Transaction? {
        didSet {
            guard let transaction = transaction, let category = transaction.category else { return }

            let color = UIColor.categoryColor(for: category)
            iconBackground.backgroundColor = color.withAlphaComponent(0.15)
            categoryImageView.image = UIImage(named: category)

            categoryLabel.attributedText = nil
            titleLabel.attributedText = nil

            categoryLabel.text = transaction.category?.localized()
            titleLabel.text = transaction.title

            let hasTitle = !(transaction.title ?? "").isEmpty
            titleLabel.isHidden = !hasTitle
            categoryLabelCenterConstraint?.isActive = !hasTitle
            categoryLabelTopConstraint?.isActive = hasTitle

            let isExpense = categoryExpenses.contains(category)
            let amount = transaction.amount
            amountLabel.text = convertDoubleToCurrency(amount: amount)
            amountLabel.textColor = isExpense ? .expenseRed : .incomeGreen

            dateLabel.text = transaction.date?.toFormat("MMM d, yyyy")
        }
    }

    var searchText: String = "" {
        didSet {
            if let category = transaction?.category?.localized() {
                let attrString = NSMutableAttributedString(string: category)
                let range = (category as NSString).range(of: searchText, options: .caseInsensitive)
                attrString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: range)
                categoryLabel.attributedText = attrString
            }
            if let title = transaction?.title {
                let attrString = NSMutableAttributedString(string: title)
                let range = (title as NSString).range(of: searchText, options: .caseInsensitive)
                attrString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: range)
                titleLabel.attributedText = attrString
            }
        }
    }

    // MARK: - Subviews

    lazy var iconBackground = UIView().then { v in
        v.layer.cornerRadius = 14
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
    }

    lazy var categoryImageView = UIImageView().then { iv in
        iv.contentMode = .scaleAspectFit
    }

    lazy var categoryLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor.label
        label.numberOfLines = 1
    }

    lazy var titleLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 1
    }

    lazy var amountLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 1
        label.textAlignment = .right
    }

    lazy var dateLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor.tertiaryLabel
        label.numberOfLines = 1
        label.textAlignment = .right
    }

    private var categoryLabelCenterConstraint: Constraint?
    private var categoryLabelTopConstraint: Constraint?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
        selectedBackgroundView = UIView().then {
            $0.backgroundColor = UIColor.systemGray5
        }

        iconBackground.addSubview(categoryImageView)
        contentView.addSubview(iconBackground)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(dateLabel)

        iconBackground.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(50)
            make.left.equalToSuperview().offset(16)
        }

        categoryImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(28)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackground)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(110)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(110)
        }

        categoryLabel.snp.makeConstraints { make in
            categoryLabelTopConstraint = make.top.equalTo(iconBackground).constraint
            categoryLabelCenterConstraint = make.centerY.equalTo(iconBackground).constraint
            make.left.equalTo(iconBackground.snp.right).offset(12)
            make.right.equalTo(amountLabel.snp.left).offset(-8)
        }
        categoryLabelTopConstraint?.isActive = true
        categoryLabelCenterConstraint?.isActive = false

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.left.equalTo(iconBackground.snp.right).offset(12)
            make.right.equalTo(amountLabel.snp.left).offset(-8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
