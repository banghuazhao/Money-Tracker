//
//  RetirementCalculatorViewController.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

class RetirementCalculatorViewController: UIViewController {
    // MARK: - Input fields

    private lazy var currentAgeField = makeTextField(placeholder: "30", keyboard: .numberPad)
    private lazy var retireAgeField = makeTextField(placeholder: "65", keyboard: .numberPad)
    private lazy var savingsField = makeTextField(placeholder: "20000", keyboard: .decimalPad)
    private lazy var contributionField = makeTextField(placeholder: "500", keyboard: .decimalPad)
    private lazy var rateField = makeTextField(placeholder: "7", keyboard: .decimalPad)

    // MARK: - Result labels

    private lazy var nestEggLabel = makeResultValue(color: .incomeGreen)
    private lazy var contributionsLabel = makeResultValue(color: .label)
    private lazy var interestLabel = makeResultValue(color: .themeColor)

    private lazy var shareButton = UIBarButtonItem(
        image: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
        style: .plain, target: self, action: #selector(tapShare))

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
        cfg.image = UIImage(systemName: "arrow.up.right.circle.fill")
        cfg.imagePadding = 8
        cfg.baseBackgroundColor = .systemTeal
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
        title = "Retirement".localized()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        hideKeyboardWhenTappedAround()
        shareButton.isEnabled = false
        navigationItem.rightBarButtonItem = shareButton
        setupViews()
        calculateButton.isEnabled = false
        [currentAgeField, retireAgeField, rateField].forEach {
            $0.addTarget(self, action: #selector(updateButtonState), for: .editingChanged)
        }
    }

    @objc private func updateButtonState() {
        calculateButton.isEnabled = [currentAgeField, retireAgeField, rateField].allSatisfy {
            !($0.text?.isEmpty ?? true)
        }
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
        let r1 = makeInputRow(title: "Current Age".localized(), field: currentAgeField, unit: "yr")
        let d1 = makeDivider()
        let r2 = makeInputRow(title: "Retirement Age".localized(), field: retireAgeField, unit: "yr")
        let d2 = makeDivider()
        let r3 = makeInputRow(title: "Current Savings".localized(), field: savingsField, unit: "$")
        let d3 = makeDivider()
        let r4 = makeInputRow(title: "Monthly Contribution".localized(), field: contributionField, unit: "$")
        let d4 = makeDivider()
        let r5 = makeInputRow(title: "Annual Rate (%)".localized(), field: rateField, unit: "%")

        for sub in [r1, d1, r2, d2, r3, d3, r4, d4, r5] { inputCard.addSubview(sub) }
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
            make.top.equalTo(d2.snp.bottom); make.left.right.equalToSuperview(); make.height.equalTo(54)
        }
        d3.snp.makeConstraints { make in
            make.top.equalTo(r3.snp.bottom); make.left.equalToSuperview().offset(16); make.right.equalToSuperview(); make.height.equalTo(0.5)
        }
        r4.snp.makeConstraints { make in
            make.top.equalTo(d3.snp.bottom); make.left.right.equalToSuperview(); make.height.equalTo(54)
        }
        d4.snp.makeConstraints { make in
            make.top.equalTo(r4.snp.bottom); make.left.equalToSuperview().offset(16); make.right.equalToSuperview(); make.height.equalTo(0.5)
        }
        r5.snp.makeConstraints { make in
            make.top.equalTo(d4.snp.bottom); make.left.right.bottom.equalToSuperview(); make.height.equalTo(54)
        }

        // Result card
        let rr1 = makeResultRow(title: "Nest Egg at Retirement".localized(), value: nestEggLabel)
        let rd1 = makeDivider()
        let rr2 = makeResultRow(title: "Total Contributions".localized(), value: contributionsLabel)
        let rd2 = makeDivider()
        let rr3 = makeResultRow(title: "Interest Earned".localized(), value: interestLabel)

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
            let caText = currentAgeField.text, let currentAge = Double(caText), currentAge > 0,
            let raText = retireAgeField.text, let retireAge = Double(raText), retireAge > currentAge,
            let rText = rateField.text, let annualRate = Double(rText), annualRate >= 0
        else {
            showInputError()
            return
        }

        let savings = Double(savingsField.text ?? "") ?? 0
        let pmt = Double(contributionField.text ?? "") ?? 0
        let years = retireAge - currentAge
        let n = 12.0 * years
        let r = annualRate / 100.0 / 12.0

        let fvSavings = savings * pow(1 + r, n)
        let fvContributions: Double
        if r == 0 {
            fvContributions = pmt * n
        } else {
            fvContributions = pmt * (pow(1 + r, n) - 1) / r
        }
        let nestEgg = fvSavings + fvContributions
        let totalContributions = savings + pmt * n
        let interestEarned = nestEgg - totalContributions

        nestEggLabel.text = convertDoubleToCurrency(amount: nestEgg)
        contributionsLabel.text = convertDoubleToCurrency(amount: totalContributions)
        interestLabel.text = convertDoubleToCurrency(amount: interestEarned)

        shareButton.isEnabled = true
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

    @objc private func tapShare() {
        let savings = convertDoubleToCurrency(amount: Double(savingsField.text ?? "") ?? 0)
        let contribution = convertDoubleToCurrency(amount: Double(contributionField.text ?? "") ?? 0)
        let rate = "\(rateField.text ?? "")%"
        let text = """
        \("Retirement".localized())

        \("Current Age".localized()): \(currentAgeField.text ?? "")
        \("Retirement Age".localized()): \(retireAgeField.text ?? "")
        \("Annual Rate (%)".localized()): \(rate)
        \("Current Savings".localized()): \(savings)
        \("Monthly Contribution".localized()): \(contribution)

        \("Nest Egg at Retirement".localized()): \(nestEggLabel.text ?? "")
        \("Total Contributions".localized()): \(contributionsLabel.text ?? "")
        \("Interest Earned".localized()): \(interestLabel.text ?? "")

        via Money Tracker
        """
        let avc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = avc.popoverPresentationController { popover.barButtonItem = shareButton }
        present(avc, animated: true)
    }

    private func showInputError() {
        let ac = UIAlertController(
            title: "Invalid Input".localized(),
            message: "Please enter valid numbers. Retirement age must be greater than current age.".localized(),
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
        let lbl = UILabel().then { l in l.text = title; l.font = .systemFont(ofSize: 16) }
        let unitLbl = UILabel().then { l in l.text = unit; l.font = .systemFont(ofSize: 16); l.textColor = .secondaryLabel }
        row.addSubview(lbl)
        row.addSubview(unitLbl)
        row.addSubview(field)
        lbl.snp.makeConstraints { $0.left.equalToSuperview().offset(16); $0.centerY.equalToSuperview() }
        unitLbl.snp.makeConstraints { $0.right.equalToSuperview().offset(-16); $0.centerY.equalToSuperview() }
        field.snp.makeConstraints { make in
            make.right.equalTo(unitLbl.snp.left).offset(-6)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(lbl.snp.right).offset(8)
            make.width.greaterThanOrEqualTo(80)
        }
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
