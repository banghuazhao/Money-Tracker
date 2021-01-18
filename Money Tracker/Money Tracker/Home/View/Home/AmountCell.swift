//
//  AmountCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import Then
import UIKit

class AmountCell: UITableViewCell {
    var transactions: [Transaction]? {
        didSet {
            guard let transactions = transactions else { return }
            let total = transactions
                .map { $0.amount }
                .reduce(0, +)
            netWorthLabel.text = convertDoubleToCurrency(amount: total)
        }
    }

    lazy var netWorthLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.numberOfLines = 1
    }

    lazy var detailButton: UIButtonLargerArea = {
        let button = UIButtonLargerArea.systemButton(
            with: UIImage(
                systemName: "ellipsis.circle",
                withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!,
            target: nil,
            action: nil)
        button.tintColor = UIColor.themeColor
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        contentView.addSubview(netWorthLabel)
        contentView.addSubview(detailButton)
        netWorthLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(15)
        }
        detailButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
