//
//  CategoryCell.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

class CategoryCell: UITableViewCell {
    private lazy var iconBackground = UIView().then { v in
        v.layer.cornerRadius = 20
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
    }

    private lazy var iconImageView = UIImageView().then { iv in
        iv.contentMode = .scaleAspectFit
    }

    private lazy var nameLabel = UILabel().then { l in
        l.font = .systemFont(ofSize: 16)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconBackground)
        iconBackground.addSubview(iconImageView)
        contentView.addSubview(nameLabel)

        iconBackground.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(40)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconBackground.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    /// Configure for a common (built-in) category.
    func configureCommon(name: String) {
        let color = UIColor.categoryColor(for: name)
        iconBackground.backgroundColor = color.withAlphaComponent(0.15)
        iconImageView.image = UIImage.categoryIcon(for: name)
        nameLabel.text = name.localized()
    }

    /// Configure for a user-defined category.
    func configureUser(_ category: UserCategory) {
        let color: UIColor = category.isIncome ? .incomeGreen : .expenseRed
        iconBackground.backgroundColor = color.withAlphaComponent(0.15)
        if let emoji = category.iconName {
            iconImageView.image = UIImage.emoji(emoji, size: 36)
        }
        nameLabel.text = category.name
    }
}
