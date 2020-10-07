//
//  SingleTitleCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/6/20.
//

import UIKit

class SingleTitleCell: UITableViewCell {
    private lazy var titleLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = "Categories".localized()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
