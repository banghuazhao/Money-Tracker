//
//  LoanCalculatorViewController.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

class LoanCalculatorViewController: UIViewController {
    // MARK: - Input fields

    private lazy var principalField = makeTextField(placeholder: "200000", keyboard: .decimalPad)
    private lazy var rateField = makeTextField(placeholder: "5.5", keyboard: .decimalPad)
    private lazy var termField = makeTextField(placeholder: "30", keyboard: .numberPad)

    // MARK: - Result labels

    private lazy var monthlyPaymentValue = makeResultValue()
    private lazy var totalInterestValue = makeResultValue()
    private lazy var totalAmountValue = makeResultValue()

    private lazy var resultCard: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.cornerCurve = .continuous
        v.isHidden = true
        return v
    }()

    private lazy var calculateButton: UIButton = {
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Calculate".localized()
        cfg.image = UIImage(systemName: "equal.circle.fill")
        cfg.imagePadding = 8
        cfg.baseBackgroundColor = .themeColor
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
        title = "Loan Calculator".localized()
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

        // Input card
        let inputCard = makeCard()
        let principalRow = makeInputRow(title: "Principal Amount".localized(), field: principalField, unit: "$")
        let div1 = makeDivider()
        let rateRow = makeInputRow(title: "Annual Rate (%)".localized(), field: rateField, unit: "%")
        let div2 = makeDivider()
        let termRow = makeInputRow(title: "Loan Term (Years)".localized(), field: termField, unit: "yr")

        inputCard.addSubview(principalRow)
        inputCard.addSubview(div1)
        inputCard.addSubview(rateRow)
        inputCard.addSubview(div2)
        inputCard.addSubview(termRow)

        principalRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(54)
        }
        div1.snp.makeConstraints { make in
            make.top.equalTo(principalRow.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        rateRow.snp.makeConstraints { make in
            make.top.equalTo(div1.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(54)
        }
        div2.snp.makeConstraints { make in
            make.top.equalTo(rateRow.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        termRow.snp.makeConstraints { make in
            make.top.equalTo(div2.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(54)
        }

        // Result card
        let monthlyRow = makeResultRow(title: "Monthly Payment".localized(), value: monthlyPaymentValue)
        let rdiv1 = makeDivider()
        let interestRow = makeResultRow(title: "Total Interest".localized(), value: totalInterestValue)
        let rdiv2 = makeDivider()
        let totalRow = makeResultRow(title: "Total Payment".localized(), value: totalAmountValue)

        resultCard.addSubview(monthlyRow)
        resultCard.addSubview(rdiv1)
        resultCard.addSubview(interestRow)
        resultCard.addSubview(rdiv2)
        resultCard.addSubview(totalRow)

        monthlyRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(54)
        }
        rdiv1.snp.makeConstraints { make in
            make.top.equalTo(monthlyRow.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        interestRow.snp.makeConstraints { make in
            make.top.equalTo(rdiv1.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(54)
        }
        rdiv2.snp.makeConstraints { make in
            make.top.equalTo(interestRow.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        totalRow.snp.makeConstraints { make in
            make.top.equalTo(rdiv2.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(54)
        }

        // Arrange in content view
        contentView.addSubview(inputCard)
        contentView.addSubview(calculateButton)
        contentView.addSubview(resultCard)

        inputCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
        }
        calculateButton.snp.makeConstraints { make in
            make.top.equalTo(inputCard.snp.bottom).offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(52)
        }
        resultCard.snp.makeConstraints { make in
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
            let principalText = principalField.text, let principal = Double(principalText), principal > 0,
            let rateText = rateField.text, let annualRate = Double(rateText), annualRate >= 0,
            let termText = termField.text, let termYears = Double(termText), termYears > 0
        else {
            showInputError()
            return
        }

        let n = termYears * 12
        let monthlyPayment: Double
        if annualRate == 0 {
            monthlyPayment = principal / n
        } else {
            let r = annualRate / 100.0 / 12.0
            monthlyPayment = principal * r * pow(1 + r, n) / (pow(1 + r, n) - 1)
        }

        let totalAmount = monthlyPayment * n
        let totalInterest = totalAmount - principal

        monthlyPaymentValue.text = convertDoubleToCurrency(amount: monthlyPayment)
        totalInterestValue.text = convertDoubleToCurrency(amount: totalInterest)
        totalAmountValue.text = convertDoubleToCurrency(amount: totalAmount)

        totalAmountValue.textColor = .expenseRed

        if resultCard.isHidden {
            resultCard.isHidden = false
            scrollView.layoutIfNeeded()
            let bottom = resultCard.frame.maxY + 32
            let offset = bottom - scrollView.bounds.height
            if offset > 0 {
                scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
    }

    private func showInputError() {
        let ac = UIAlertController(
            title: "Invalid Input".localized(),
            message: "Please enter valid positive numbers for all fields.".localized(),
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
        present(ac, animated: true)
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        UIView().then { v in
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 16
            v.layer.cornerCurve = .continuous
        }
    }

    private func makeDivider() -> UIView {
        UIView().then { v in v.backgroundColor = .separator }
    }

    private func makeTextField(placeholder: String, keyboard: UIKeyboardType) -> UITextField {
        UITextField().then { tf in
            tf.placeholder = placeholder
            tf.keyboardType = keyboard
            tf.textAlignment = .right
            tf.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        }
    }

    private func makeInputRow(title: String, field: UITextField, unit: String) -> UIView {
        let row = UIView()
        let titleLabel = UILabel().then { l in
            l.text = title
            l.font = UIFont.systemFont(ofSize: 16)
        }
        let unitLabel = UILabel().then { l in
            l.text = unit
            l.font = UIFont.systemFont(ofSize: 16)
            l.textColor = .secondaryLabel
        }
        row.addSubview(titleLabel)
        row.addSubview(unitLabel)
        row.addSubview(field)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        unitLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        field.snp.makeConstraints { make in
            make.right.equalTo(unitLabel.snp.left).offset(-6)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(8)
            make.width.greaterThanOrEqualTo(80)
        }
        return row
    }

    private func makeResultValue() -> UILabel {
        UILabel().then { l in
            l.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
            l.textColor = .label
            l.textAlignment = .right
        }
    }

    private func makeResultRow(title: String, value: UILabel) -> UIView {
        let row = UIView()
        let titleLabel = UILabel().then { l in
            l.text = title
            l.font = UIFont.systemFont(ofSize: 15)
            l.textColor = .secondaryLabel
        }
        row.addSubview(titleLabel)
        row.addSubview(value)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        value.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(8)
        }
        return row
    }
}
