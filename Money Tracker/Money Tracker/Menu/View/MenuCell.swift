//
//  MenuCell.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 6/25/20.
//

import SnapKit
import Then
import UIKit

class MenuCell: UITableViewCell {
    // SF Symbol name → background color mapping (Settings-app style)
    private static let iconColors: [String: UIColor] = [
        "dollarsign.circle":   .systemGreen,
        "function":            .systemIndigo,
        "bubble.left":         .systemBlue,
        "star":                .systemYellow,
        "square.and.arrow.up": .systemOrange,
        "hand.thumbsup":       .systemPurple,
        "ellipsis":            .systemGray,
    ]

    var menuItem: MyMenuItem? {
        didSet {
            guard let menuItem = menuItem else { return }
            let symbolName = menuItem.icon?.description ?? ""
            let bgColor = Self.iconColors.first(where: { symbolName.contains($0.key) })?.value ?? .themeColor

            iconContainer.backgroundColor = bgColor
            iconImageView.image = menuItem.icon?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = .white
            titleLabel.text = menuItem.title
        }
    }

    lazy var iconContainer = UIView().then { v in
        v.layer.cornerRadius = 8
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
        v.backgroundColor = .themeColor
    }

    lazy var iconImageView = UIImageView().then { iv in
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
    }

    lazy var titleLabel = UILabel().then { label in
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
    }

    lazy var chevron = UIImageView().then { iv in
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        iconContainer.addSubview(iconImageView)
        contentView.addSubview(iconContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(chevron)

        iconContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(18)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconContainer.snp.right).offset(14)
            make.right.equalTo(chevron.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }

        chevron.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
