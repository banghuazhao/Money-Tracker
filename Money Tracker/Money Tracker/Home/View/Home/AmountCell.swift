//
//  AmountCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import SnapKit
import Then
import UIKit

class AmountCell: UITableViewCell {
    var transactions: [Transaction]? {
        didSet {
            guard let transactions = transactions else { return }
            let total   = transactions.map { $0.amount }.reduce(0, +)
            let income  = transactions.filter { $0.amount > 0 }.map { $0.amount }.reduce(0, +)
            let expense = transactions.filter { $0.amount < 0 }.map { $0.amount }.reduce(0, +)

            netWorthLabel.text = convertDoubleToCurrency(amount: total)
            netWorthLabel.textColor = total >= 0 ? .label : .expenseRed

            incomeValueLabel.text = convertDoubleToCurrency(amount: income)
            expenseValueLabel.text = convertDoubleToCurrency(amount: expense)
        }
    }

    // MARK: - Subviews

    lazy var netWorthLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.numberOfLines = 1
    }

    lazy var detailButton: UIButtonLargerArea = {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let img = UIImage(systemName: "ellipsis.circle.fill", withConfiguration: config)!
        let button = UIButtonLargerArea(type: .system)
        button.setImage(img, for: .normal)
        button.tintColor = .themeColor
        return button
    }()

    private lazy var incomePill = makePill(color: .incomeGreen)
    private lazy var expensePill = makePill(color: .expenseRed)

    private lazy var incomeArrow = makeArrowLabel(symbol: "arrow.up", color: .incomeGreen)
    private lazy var expenseArrow = makeArrowLabel(symbol: "arrow.down", color: .expenseRed)

    private lazy var incomeValueLabel = makeSummaryLabel(color: .incomeGreen)
    private lazy var expenseValueLabel = makeSummaryLabel(color: .expenseRed)

    private lazy var summaryStack: UIStackView = {
        let incomeStack = UIStackView(arrangedSubviews: [incomeArrow, incomeValueLabel])
        incomeStack.axis = .horizontal
        incomeStack.spacing = 4
        incomeStack.alignment = .center

        let expenseStack = UIStackView(arrangedSubviews: [expenseArrow, expenseValueLabel])
        expenseStack.axis = .horizontal
        expenseStack.spacing = 4
        expenseStack.alignment = .center

        let stack = UIStackView(arrangedSubviews: [incomeStack, expenseStack])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        return stack
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .systemBackground
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2

        contentView.addSubview(netWorthLabel)
        contentView.addSubview(detailButton)
        contentView.addSubview(summaryStack)

        netWorthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(detailButton.snp.left).offset(-8)
        }

        detailButton.snp.makeConstraints { make in
            make.centerY.equalTo(netWorthLabel)
            make.right.equalToSuperview().offset(-16)
            make.size.equalTo(36)
        }

        summaryStack.snp.makeConstraints { make in
            make.top.equalTo(netWorthLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    private func makePill(color: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = color.withAlphaComponent(0.12)
        v.layer.cornerRadius = 10
        v.layer.cornerCurve = .continuous
        return v
    }

    private func makeArrowLabel(symbol: String, color: UIColor) -> UIImageView {
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let iv = UIImageView(image: UIImage(systemName: symbol, withConfiguration: config))
        iv.tintColor = color
        iv.contentMode = .scaleAspectFit
        return iv
    }

    private func makeSummaryLabel(color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = color
        return label
    }
}
