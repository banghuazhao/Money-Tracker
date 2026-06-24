//
//  CalculatorsViewController.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

struct CalculatorItem {
    let title: String
    let subtitle: String
    let icon: UIImage?
    let color: UIColor
}

class CalculatorsViewController: UIViewController {
    private let items: [CalculatorItem] = [
        CalculatorItem(
            title: "Loan Calculator".localized(),
            subtitle: "Monthly payment & total interest".localized(),
            icon: UIImage(systemName: "house.fill"),
            color: .systemBlue
        ),
        CalculatorItem(
            title: "Compound Interest".localized(),
            subtitle: "Investment growth over time".localized(),
            icon: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            color: .systemGreen
        ),
        CalculatorItem(
            title: "Budget Planner".localized(),
            subtitle: "50/30/20 rule breakdown".localized(),
            icon: UIImage(systemName: "chart.pie.fill"),
            color: .systemOrange
        ),
    ]

    lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).then { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(CalculatorListCell.self, forCellReuseIdentifier: "CalculatorListCell")
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 70
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Financial Calculators".localized()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CalculatorsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tools".localized()
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Use these calculators to plan your finances and make informed decisions.".localized()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorListCell", for: indexPath) as! CalculatorListCell
        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(LoanCalculatorViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(CompoundInterestCalculatorViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(BudgetCalculatorViewController(), animated: true)
        default:
            break
        }
    }
}

// MARK: - CalculatorListCell

final class CalculatorListCell: UITableViewCell {
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
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        l.numberOfLines = 1
    }

    private lazy var subtitleLabel = UILabel().then { l in
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
    }

    private lazy var chevron = UIImageView().then { iv in
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(iconContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(chevron)

        iconContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(34)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(18)
        }
        chevron.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconContainer.snp.right).offset(14)
            make.right.equalTo(chevron.snp.left).offset(-8)
            make.bottom.equalTo(contentView.snp.centerY).offset(-1)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.top.equalTo(contentView.snp.centerY).offset(2)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with item: CalculatorItem) {
        iconContainer.backgroundColor = item.color
        iconImageView.image = item.icon?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
    }
}
