//
//  TitleCel.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import UIKit

class TitleCell: UITableViewCell {
        
    private lazy var titleLabel = UILabel().then { (label) in
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = "Transactions".localized()
    }
    
    lazy var rangeLabel = UILabel().then { (label) in
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = "All".localized()
    }
    
    lazy var repeatButton: UIButtonLargerArea = {
        let button = UIButtonLargerArea.systemButton(
            with: UIImage(
                systemName: "repeat",
                withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!,
            target: nil,
            action: nil)
        button.tintColor = UIColor.themeColor
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        contentView.addSubview(titleLabel)
        contentView.addSubview(rangeLabel)
        contentView.addSubview(repeatButton)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        repeatButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        rangeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(repeatButton.snp.left).offset(-10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
