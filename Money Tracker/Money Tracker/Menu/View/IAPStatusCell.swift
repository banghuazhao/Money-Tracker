//
//  IAPStatusCell.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

class IAPStatusCell: UITableViewCell {

    private lazy var iconContainer = UIView().then { v in
        v.layer.cornerRadius = 8
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
    }

    private lazy var iconImageView = UIImageView().then { iv in
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
    }

    private lazy var titleLabel = UILabel().then { l in
        l.numberOfLines = 1
    }

    private lazy var subtitleLabel = UILabel().then { l in
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
    }

    private lazy var accessoryImageView = UIImageView().then { iv in
        iv.contentMode = .scaleAspectFit
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        iconContainer.addSubview(iconImageView)
        contentView.addSubview(iconContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(accessoryImageView)

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
            make.right.equalTo(accessoryImageView.snp.left).offset(-8)
            make.bottom.equalTo(contentView.snp.centerY).offset(-1)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconContainer.snp.right).offset(14)
            make.right.equalTo(accessoryImageView.snp.left).offset(-8)
            make.top.equalTo(contentView.snp.centerY).offset(1)
        }
        accessoryImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(purchased: Bool, price: String?) {
        if purchased {
            selectionStyle = .none
            iconContainer.backgroundColor = .systemYellow
            iconImageView.image = UIImage(systemName: "crown.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
            titleLabel.text = "Ad-Free Pro".localized()
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            subtitleLabel.text = "All ads removed • Thank you!".localized()
            accessoryImageView.image = UIImage(systemName: "checkmark.seal.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold))
            accessoryImageView.tintColor = .systemYellow
        } else {
            selectionStyle = .default
            iconContainer.backgroundColor = .systemRed
            iconImageView.image = UIImage(systemName: "hand.raised.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
            titleLabel.text = "Remove Ads Forever".localized()
            titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
            if let price = price {
                subtitleLabel.text = "\("One-time purchase".localized()) · \(price)"
            } else {
                subtitleLabel.text = "One-time purchase".localized()
            }
            accessoryImageView.image = UIImage(systemName: "chevron.right",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
            accessoryImageView.tintColor = .tertiaryLabel
        }
    }
}
