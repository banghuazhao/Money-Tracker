//
//  DebtPayoffCalculatorViewController.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

class DebtPayoffCalculatorViewController: UIViewController {
    // MARK: - Input fields

    private lazy var balanceField = makeTextField(placeholder: "10000", keyboard: .decimalPad)
    private lazy var rateField = makeTextField(placeholder: "18", keyboard: .decimalPad)
    private lazy var paymentField = makeTextField(placeholder: "300", keyboard: .decimalPad)

    // MARK: - Result labels

    private lazy var payoffTimeLabel = makeResultValue(color: .themeColor)
    private lazy var totalInterestLabel = makeResultValue(color: .expenseRed)
    private lazy var totalPaidLabel = makeResultValue(color: .label)

    private lazy var shareButton = UIBarButtonItem(
        image: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
        style: .plain, target: self, action: #selector(tapShare))

    private lazy var clearButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.counterclockwise"),
        style: .plain, target: self, action: #selector(clearAll))

    private lazy var resultCard: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.cornerCurve = .continuous
        return v
    }()

    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Debt Payoff".localized()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        hideKeyboardWhenTappedAround()
        navigationItem.rightBarButtonItems = [shareButton, clearButton]
        setupViews()

        balanceField.text = "10000"
        rateField.text = "18"
        paymentField.text = "300"
        [balanceField, rateField, paymentField].forEach {
            $0.addTarget(self, action: #selector(recalculate), for: .editingChanged)
        }
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

        // Input card
        let inputCard = makeCard()
        let r1 = makeInputRow(title: "Current Balance".localized(), field: balanceField, unit: "$")
        let d1 = makeDivider()
        let r2 = makeInputRow(title: "Annual Rate (APR %)".localized(), field: rateField, unit: "%")
        let d2 = makeDivider()
        let r3 = makeInputRow(title: "Monthly Payment".localized(), field: paymentField, unit: "$")

        for sub in [r1, d1, r2, d2, r3] { inputCard.addSubview(sub) }
        r1.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview(); make.height.equalTo(54)
        }
        d1.snp.makeConstraints { make in
            make.top.equalTo(r1.snp.bottom); make.left.equalToSuperview().offset(16); make.right.equalToSuperview(); make.height.equalTo(0.5)
        }
        r2.snp.makeConstraints { make in
            make.top.equalTo(d1.snp.bottom); make.left.right.equalToSuperview(); make.height.equalTo(54)
        }
        d2.snp.makeConstraints { make in
            make.top.equalTo(r2.snp.bottom); make.left.equalToSuperview().offset(16); make.right.equalToSuperview(); make.height.equalTo(0.5)
        }
        r3.snp.makeConstraints { make in
            make.top.equalTo(d2.snp.bottom); make.left.right.bottom.equalToSuperview(); make.height.equalTo(54)
        }

        // Result card
        let rr1 = makeResultRow(title: "Time to Pay Off".localized(), value: payoffTimeLabel)
        let rd1 = makeDivider()
        let rr2 = makeResultRow(title: "Total Interest".localized(), value: totalInterestLabel)
        let rd2 = makeDivider()
        let rr3 = makeResultRow(title: "Total Paid".localized(), value: totalPaidLabel)

        for sub in [rr1, rd1, rr2, rd2, rr3] { resultCard.addSubview(sub) }
        rr1.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview(); make.height.equalTo(54)
        }
        rd1.snp.makeConstraints { make in
            make.top.equalTo(rr1.snp.bottom); make.left.equalToSuperview().offset(16); make.right.equalToSuperview(); make.height.equalTo(0.5)
        }
        rr2.snp.makeConstraints { make in
            make.top.equalTo(rd1.snp.bottom); make.left.right.equalToSuperview(); make.height.equalTo(54)
        }
        rd2.snp.makeConstraints { make in
            make.top.equalTo(rr2.snp.bottom); make.left.equalToSuperview().offset(16); make.right.equalToSuperview(); make.height.equalTo(0.5)
        }
        rr3.snp.makeConstraints { make in
            make.top.equalTo(rd2.snp.bottom); make.left.right.bottom.equalToSuperview(); make.height.equalTo(54)
        }

        // Assemble
        contentView.addSubview(inputCard)
        contentView.addSubview(resultCard)

        inputCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
        }
        resultCard.snp.makeConstraints { make in
            make.top.equalTo(inputCard.snp.bottom).offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalToSuperview().offset(-32)
        }
    }

    // MARK: - Actions

    @objc private func recalculate() {
        guard
            let bText = balanceField.text, let balance = Double(bText), balance > 0,
            let rText = rateField.text, let annualRate = Double(rText), annualRate >= 0,
            let pText = paymentField.text, let payment = Double(pText), payment > 0
        else {
            [payoffTimeLabel, totalInterestLabel, totalPaidLabel].forEach { $0.text = "—" }
            shareButton.isEnabled = false
            return
        }

        let r = annualRate / 100.0 / 12.0

        // Payment doesn't cover monthly interest — debt never paid off
        if r > 0 && payment <= balance * r {
            payoffTimeLabel.text = "∞"
            totalInterestLabel.text = "—"
            totalPaidLabel.text = "—"
            shareButton.isEnabled = false
            return
        }

        let months: Double
        if r == 0 {
            months = ceil(balance / payment)
        } else {
            months = ceil(-log(1 - balance * r / payment) / log(1 + r))
        }

        let totalPaid = payment * months
        let totalInterest = totalPaid - balance

        payoffTimeLabel.text = formatMonths(months)
        totalInterestLabel.text = convertDoubleToCurrency(amount: totalInterest)
        totalPaidLabel.text = convertDoubleToCurrency(amount: totalPaid)
        shareButton.isEnabled = true
    }

    @objc private func clearAll() {
        balanceField.text = "10000"
        rateField.text = "18"
        paymentField.text = "300"
        recalculate()
    }

    @objc private func tapShare() {
        let balance = convertDoubleToCurrency(amount: Double(balanceField.text ?? "") ?? 0)
        let rate = "\(rateField.text ?? "")%"
        let payment = convertDoubleToCurrency(amount: Double(paymentField.text ?? "") ?? 0)
        let text = """
        \("Debt Payoff".localized())

        \("Current Balance".localized()): \(balance)
        \("Annual Rate (APR %)".localized()): \(rate)
        \("Monthly Payment".localized()): \(payment)

        \("Time to Pay Off".localized()): \(payoffTimeLabel.text ?? "")
        \("Total Interest".localized()): \(totalInterestLabel.text ?? "")
        \("Total Paid".localized()): \(totalPaidLabel.text ?? "")

        via Money Tracker
        """
        let avc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = avc.popoverPresentationController { popover.barButtonItem = shareButton }
        present(avc, animated: true)
    }

    private func formatMonths(_ months: Double) -> String {
        let total = Int(months)
        let years = total / 12
        let remMonths = total % 12
        var parts: [String] = []
        if years > 0 {
            parts.append("\(years) " + (years == 1 ? "yr".localized() : "yrs".localized()))
        }
        if remMonths > 0 || years == 0 {
            parts.append("\(remMonths) " + (remMonths == 1 ? "mo".localized() : "mos".localized()))
        }
        return parts.joined(separator: " ")
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
        let lbl = UILabel().then { l in l.text = title; l.font = .systemFont(ofSize: 16) }
        let unitLbl = UILabel().then { l in l.text = unit; l.font = .systemFont(ofSize: 16); l.textColor = .secondaryLabel }
        let tapOverlay = UIButton()
        tapOverlay.addTarget(field, action: #selector(UIResponder.becomeFirstResponder), for: .touchUpInside)
        row.addSubview(lbl)
        row.addSubview(unitLbl)
        row.addSubview(field)
        row.addSubview(tapOverlay)
        lbl.snp.makeConstraints { $0.left.equalToSuperview().offset(16); $0.centerY.equalToSuperview() }
        unitLbl.snp.makeConstraints { $0.right.equalToSuperview().offset(-16); $0.centerY.equalToSuperview() }
        field.snp.makeConstraints { make in
            make.right.equalTo(unitLbl.snp.left).offset(-6)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(lbl.snp.right).offset(8)
            make.width.greaterThanOrEqualTo(80)
        }
        tapOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }
        return row
    }

    private func makeResultValue(color: UIColor) -> UILabel {
        UILabel().then { l in
            l.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
            l.textColor = color
            l.textAlignment = .right
        }
    }

    private func makeResultRow(title: String, value: UILabel) -> UIView {
        let row = UIView()
        let lbl = UILabel().then { l in l.text = title; l.font = .systemFont(ofSize: 15); l.textColor = .secondaryLabel }
        row.addSubview(lbl)
        row.addSubview(value)
        lbl.snp.makeConstraints { $0.left.equalToSuperview().offset(16); $0.centerY.equalToSuperview() }
        value.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(lbl.snp.right).offset(8)
        }
        return row
    }
}
