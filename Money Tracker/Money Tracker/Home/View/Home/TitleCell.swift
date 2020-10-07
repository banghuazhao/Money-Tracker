//
//  TitleCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import SnapKit
import Then
import UIKit

class TitleCell: UITableViewCell {
    private lazy var titleLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.text = "Transactions".localized()
    }

    lazy var rangeLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = ""
    }

    lazy var repeatButton: UIButtonLargerArea = {
        let button = UIButtonLargerArea(type: .system)
        button.setTitle("Show All".localized(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.tintColor = .themeColor
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        backgroundColor = .clear

        contentView.addSubview(titleLabel)
        contentView.addSubview(rangeLabel)
        contentView.addSubview(repeatButton)

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        rangeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(8)
        }
        repeatButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
