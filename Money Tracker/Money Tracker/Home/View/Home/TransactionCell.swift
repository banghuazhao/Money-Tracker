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

            let userCat = UserCategoryManager.shared.category(forName: category)
            let color: UIColor = userCat != nil
                ? (transaction.amount < 0 ? .expenseRed : .incomeGreen)
                : UIColor.categoryColor(for: category)
            iconBackground.backgroundColor = color.withAlphaComponent(0.15)
            if let emoji = userCat?.iconName {
                categoryImageView.image = UIImage.emoji(emoji, size: 36)
            } else {
                categoryImageView.image = UIImage.categoryIcon(for: category)
            }

            categoryLabel.attributedText = nil
            titleLabel.attributedText = nil

            categoryLabel.text = userCat != nil ? category : category.localized()
            titleLabel.text = transaction.title

            let hasTitle = !(transaction.title ?? "").isEmpty
            titleLabel.isHidden = !hasTitle
            categoryLabelCenterConstraint?.isActive = !hasTitle
            categoryLabelTopConstraint?.isActive = hasTitle

            let amount = transaction.amount
            amountLabel.text = convertDoubleToCurrency(amount: amount)
            amountLabel.textColor = amount < 0 ? .expenseRed : .incomeGreen

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

    lazy var containerView = UIView().then { v in
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 14
        v.layer.cornerCurve = .continuous
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowOffset = CGSize(width: 0, height: 1)
        v.layer.shadowRadius = 4
    }

    lazy var iconBackground = UIView().then { v in
        v.layer.cornerRadius = 13
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
        backgroundColor = .clear
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)

        contentView.addSubview(containerView)
        containerView.addSubview(iconBackground)
        iconBackground.addSubview(categoryImageView)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(dateLabel)

        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        iconBackground.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().offset(-13)
            make.size.equalTo(48)
            make.left.equalToSuperview().offset(12)
        }

        categoryImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(26)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackground)
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(110)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-12)
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

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: animated ? 0.15 : 0) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            self.containerView.alpha = highlighted ? 0.85 : 1
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
