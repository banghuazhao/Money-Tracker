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

    private lazy var shareButton = UIBarButtonItem(
        image: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
        style: .plain, target: self, action: #selector(tapShare))

    private lazy var clearButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.counterclockwise"),
        style: .plain, target: self, action: #selector(clearAll))

    private lazy var resultStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        return sv
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
        navigationItem.rightBarButtonItems = [shareButton, clearButton]
        setupViews()

        incomeField.text = "5000"
        incomeField.addTarget(self, action: #selector(recalculate), for: .editingChanged)
        recalculate()
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
        let tapOverlay = UIButton()
        tapOverlay.addTarget(incomeField, action: #selector(UIResponder.becomeFirstResponder), for: .touchUpInside)
        inputCard.addSubview(monthlyLabel)
        inputCard.addSubview(unitLabel)
        inputCard.addSubview(incomeField)
        inputCard.addSubview(tapOverlay)
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
        tapOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }
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
        resultStack.snp.makeConstraints { make in
            make.top.equalTo(inputCard.snp.bottom).offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalToSuperview().offset(-32)
        }
    }

    // MARK: - Actions

    @objc private func recalculate() {
        guard let text = incomeField.text, let income = Double(text), income > 0 else {
            [needsAmountLabel, wantsAmountLabel, savingsAmountLabel].forEach { $0.text = "—" }
            shareButton.isEnabled = false
            return
        }

        needsAmountLabel.text = convertDoubleToCurrency(amount: income * 0.50)
        wantsAmountLabel.text = convertDoubleToCurrency(amount: income * 0.30)
        savingsAmountLabel.text = convertDoubleToCurrency(amount: income * 0.20)
        shareButton.isEnabled = true
    }

    @objc private func clearAll() {
        incomeField.text = "5000"
        recalculate()
    }

    @objc private func tapShare() {
        let income = convertDoubleToCurrency(amount: Double(incomeField.text ?? "") ?? 0)
        let text = """
        \("Budget Planner".localized()) (50/30/20)

        \("Monthly Income".localized()): \(income)

        \("Needs (50%)".localized()): \(needsAmountLabel.text ?? "")
        \("Wants (30%)".localized()): \(wantsAmountLabel.text ?? "")
        \("Savings & Debt (20%)".localized()): \(savingsAmountLabel.text ?? "")

        via Money Tracker
        """
        let avc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = avc.popoverPresentationController { popover.barButtonItem = shareButton }
        present(avc, animated: true)
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        UIView().then { v in
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 20
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
            v.layer.cornerRadius = 20
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
