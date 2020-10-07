//
//  BudgetCalculatorViewController.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

class BudgetCalculatorViewController: UIViewController {
    // MARK: - Input

    private lazy var incomeField = UITextField().then { tf in
        tf.placeholder = "5000"
        tf.keyboardType = .decimalPad
        tf.textAlignment = .right
        tf.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
    }

    // MARK: - Result labels

    private lazy var needsAmountLabel = makeResultAmount(color: .systemBlue)
    private lazy var wantsAmountLabel = makeResultAmount(color: .systemPurple)
    private lazy var savingsAmountLabel = makeResultAmount(color: .systemGreen)

    private lazy var resultStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.isHidden = true
        return sv
    }()

    private lazy var calculateButton: UIButton = {
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Calculate".localized()
        cfg.image = UIImage(systemName: "chart.pie.fill")
        cfg.imagePadding = 8
        cfg.baseBackgroundColor = .systemOrange
        cfg.cornerStyle = .large
        let btn = UIButton(configuration: cfg)
        btn.addTarget(self, action: #selector(tapCalculate), for: .touchUpInside)
        return btn
    }()

    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Budget Planner".localized()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        hideKeyboardWhenTappedAround()
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // Info header card
        let infoCard = makeCard()
        let infoLabel = UILabel().then { l in
            l.text = "The 50/30/20 rule divides your after-tax income into three categories: 50% for needs, 30% for wants, and 20% for savings & debt repayment.".localized()
            l.font = UIFont.systemFont(ofSize: 14)
            l.textColor = .secondaryLabel
            l.numberOfLines = 0
        }
        infoCard.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16))
        }

        // Income input card
        let inputCard = makeCard()
        let monthlyLabel = UILabel().then { l in
            l.text = "Monthly Income".localized()
            l.font = UIFont.systemFont(ofSize: 16)
        }
        let unitLabel = UILabel().then { l in
            l.text = "$"
            l.font = UIFont.systemFont(ofSize: 16)
            l.textColor = .secondaryLabel
        }
        inputCard.addSubview(monthlyLabel)
        inputCard.addSubview(unitLabel)
        inputCard.addSubview(incomeField)
        monthlyLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        unitLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        incomeField.snp.makeConstraints { make in
            make.right.equalTo(unitLabel.snp.left).offset(-6)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(monthlyLabel.snp.right).offset(8)
            make.width.greaterThanOrEqualTo(100)
        }
        inputCard.snp.makeConstraints { $0.height.equalTo(54) }

        // Build result bucket cards
        let needsCard = makeBucketCard(
            percentage: "50%",
            title: "Needs".localized(),
            subtitle: "Housing, food, transportation, utilities, insurance".localized(),
            color: .systemBlue,
            amountLabel: needsAmountLabel
        )
        let wantsCard = makeBucketCard(
            percentage: "30%",
            title: "Wants".localized(),
            subtitle: "Dining out, entertainment, shopping, travel".localized(),
            color: .systemPurple,
            amountLabel: wantsAmountLabel
        )
        let savingsCard = makeBucketCard(
            percentage: "20%",
            title: "Savings & Debt".localized(),
            subtitle: "Emergency fund, investments, debt repayment".localized(),
            color: .systemGreen,
            amountLabel: savingsAmountLabel
        )
        resultStack.addArrangedSubview(needsCard)
        resultStack.addArrangedSubview(wantsCard)
        resultStack.addArrangedSubview(savingsCard)

        // Assemble in contentView
        contentView.addSubview(infoCard)
        contentView.addSubview(inputCard)
        contentView.addSubview(calculateButton)
        contentView.addSubview(resultStack)

        infoCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
        }
        inputCard.snp.makeConstraints { make in
            make.top.equalTo(infoCard.snp.bottom).offset(16)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
        }
        calculateButton.snp.makeConstraints { make in
            make.top.equalTo(inputCard.snp.bottom).offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(52)
        }
        resultStack.snp.makeConstraints { make in
            make.top.equalTo(calculateButton.snp.bottom).offset(24)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalToSuperview().offset(-32)
        }
    }

    // MARK: - Actions

    @objc private func tapCalculate() {
        view.endEditing(true)
        guard
            let text = incomeField.text, let income = Double(text), income > 0
        else {
            let ac = UIAlertController(
                title: "Invalid Input".localized(),
                message: "Please enter a valid monthly income greater than zero.".localized(),
                preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
            present(ac, animated: true)
            return
        }

        needsAmountLabel.text = convertDoubleToCurrency(amount: income * 0.50)
        wantsAmountLabel.text = convertDoubleToCurrency(amount: income * 0.30)
        savingsAmountLabel.text = convertDoubleToCurrency(amount: income * 0.20)

        if resultStack.isHidden {
            resultStack.isHidden = false
            scrollView.layoutIfNeeded()
            let bottom = resultStack.frame.maxY + 32
            let offset = bottom - scrollView.bounds.height
            if offset > 0 {
                scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        UIView().then { v in
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 16
            v.layer.cornerCurve = .continuous
        }
    }

    private func makeResultAmount(color: UIColor) -> UILabel {
        UILabel().then { l in
            l.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
            l.textColor = color
            l.adjustsFontSizeToFitWidth = true
        }
    }

    private func makeBucketCard(
        percentage: String,
        title: String,
        subtitle: String,
        color: UIColor,
        amountLabel: UILabel
    ) -> UIView {
        let card = UIView().then { v in
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 16
            v.layer.cornerCurve = .continuous
        }

        let badge = UILabel().then { l in
            l.text = percentage
            l.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            l.textColor = .white
            l.textAlignment = .center
            l.backgroundColor = color
            l.layer.cornerRadius = 14
            l.layer.masksToBounds = true
        }

        let titleLabel = UILabel().then { l in
            l.text = title
            l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        }

        let subtitleLabel = UILabel().then { l in
            l.text = subtitle
            l.font = UIFont.systemFont(ofSize: 12)
            l.textColor = .secondaryLabel
            l.numberOfLines = 2
        }

        card.addSubview(badge)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(amountLabel)

        badge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(CGSize(width: 52, height: 28))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(badge.snp.right).offset(12)
            make.centerY.equalTo(badge)
            make.right.equalToSuperview().offset(-16)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(badge.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }

        return card
    }
}
