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
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.text = "Transactions".localized()
    }

    lazy var rangeLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .themeColor
        label.text = "All".localized()
    }

    lazy var repeatButton: UIButtonLargerArea = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let img = UIImage(systemName: "arrow.clockwise", withConfiguration: config)!
        let button = UIButtonLargerArea(type: .system)
        button.setImage(img, for: .normal)
        button.tintColor = .themeColor
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        backgroundColor = .systemGroupedBackground

        contentView.addSubview(titleLabel)
        contentView.addSubview(rangeLabel)
        contentView.addSubview(repeatButton)

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        repeatButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.size.equalTo(36)
        }
        rangeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(repeatButton.snp.left).offset(-6)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
