//
//  AppItemCell.swift
//  Financial Statements Go
//
//  Created by Banghua Zhao on 1/1/21.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import UIKit

class AppItemCell: UITableViewCell {
    var appItem: AppItem? {
        didSet {
            guard let appItem = appItem else { return }
            iconView.image = appItem.icon
            titleLabel.text = appItem.title
            detailLabel.text = appItem.detail
        }
    }

    lazy var iconView = UIImageView().then { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 9
        imageView.layer.masksToBounds = true
    }

    lazy var titleLabel = UILabel().then { label in
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.title
    }

    lazy var detailLabel = UILabel().then { label in
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = UIColor.systemGray
        label.font = UIFont.normal
    }
    
    lazy var rightArrowImageView = UIImageView().then { (imageView) in
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.image = UIImage(systemName: "chevron.right")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(rightArrowImageView)

        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(50)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView).offset(2)
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalTo(rightArrowImageView.snp.left).offset(-12)
        }

        detailLabel.snp.makeConstraints { make in
            make.bottom.equalTo(iconView).offset(-2)
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalTo(rightArrowImageView.snp.left).offset(-12)
        }
        
        rightArrowImageView.snp.makeConstraints { (make) in
            make.width.equalTo(12)
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
