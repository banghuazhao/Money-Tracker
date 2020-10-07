//
//  CurrencyCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/7/20.
//

import UIKit

class CurrencyCell: UITableViewCell {
    var currencyCode: String? {
        didSet {
            guard let currencyCode = currencyCode else { return }
            currencyCodeLabel.text = currencyCode
            if let identifier = Locale.availableIdentifiers.first(where: { Locale(identifier: $0).currencyCode == currencyCode }) {
                currencySymbol.text = Locale(identifier: identifier).currencySymbol
            }

            accessoryType = .none

            if let currentCurrencyCode = UserDefaults.standard.value(forKey: UserDefaultsKeys.CURRENCY) as? String, currentCurrencyCode == currencyCode {
                accessoryType = .checkmark
            }
        }
    }

    lazy var currencySymbol = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 18)
    }

    lazy var currencyCodeLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)

        addSubview(currencySymbol)
        addSubview(currencyCodeLabel)

        currencySymbol.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.width.equalTo(100)
            make.centerY.equalToSuperview()
        }

        currencyCodeLabel.snp.makeConstraints { make in
            make.left.equalTo(currencySymbol.snp.right).offset(32)
            make.right.equalToSuperview().inset(32)
            make.centerY.equalTo(currencySymbol)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
